import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../models/wk_schedule_models.dart';

part 'wk_schedule_repository.g.dart';

@riverpod
WkScheduleRepository wkScheduleRepository(WkScheduleRepositoryRef ref) {
  return WkScheduleRepository(Supabase.instance.client);
}

class WkScheduleRepository {
  static const Duration _utcPlus7 = Duration(hours: 7);

  final SupabaseClient _client;

  const WkScheduleRepository(this._client);

  Future<List<WkScheduleBooking>> fetchWorkerBookings() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('You are not signed in.');
    }

    await _autoRejectOverduePending(userId);
    await _autoCompleteOverdueInProgress(userId);

    final rows = await _client
        .from(SupabaseTables.bookings)
        .select(
          'id, status, scheduled_at, address, notes, total_price, duration_minutes, contact_name, contact_phone, service:services(name, duration_minutes)',
        )
        .eq('worker_id', userId)
        .order('scheduled_at', ascending: true);

    return rows.map((row) => _mapBooking(row)).toList(growable: false);
  }

  Future<WkScheduleBooking?> fetchBookingById(String bookingId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('You are not signed in.');
    }

    await _autoRejectOverduePending(userId);
    await _autoCompleteOverdueInProgress(userId);

    final row = await _client
        .from(SupabaseTables.bookings)
        .select(
          'id, status, scheduled_at, address, notes, total_price, duration_minutes, contact_name, contact_phone, service:services(name, duration_minutes)',
        )
        .eq('id', bookingId)
        .eq('worker_id', userId)
        .maybeSingle();

    if (row == null) return null;
    return _mapBooking(row);
  }

  Future<List<WkBookingReview>> fetchReviewsByBookingId(
    String bookingId,
  ) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('You are not signed in.');
    }

    final rows = await _client
        .from(SupabaseTables.reviews)
        .select('id, rating, comment, created_at')
        .eq('worker_id', userId)
        .eq('booking_id', bookingId)
        .order('created_at', ascending: false);

    return rows
        .map((row) {
          final created =
              DateTime.tryParse(row['created_at']?.toString() ?? '')?.toUtc() ??
              DateTime.now().toUtc();
          return WkBookingReview(
            id: row['id'] as String,
            rating: (row['rating'] as num?)?.toInt() ?? 0,
            comment: (row['comment'] as String?) ?? '',
            createdAtUtc7: created.add(_utcPlus7),
          );
        })
        .toList(growable: false);
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    await _client
        .from(SupabaseTables.bookings)
        .update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId);

    await _appendSystemMessageForStatus(bookingId: bookingId, status: status);
  }

  WkScheduleBooking _mapBooking(Map<String, dynamic> raw) {
    final service = raw['service'] as Map<String, dynamic>?;
    final parsedUtc =
        DateTime.tryParse(raw['scheduled_at']?.toString() ?? '')?.toUtc() ??
        DateTime.now().toUtc();

    return WkScheduleBooking(
      id: raw['id'] as String,
      serviceName: (service?['name'] as String?) ?? 'Home Service',
      scheduledAtUtc7: parsedUtc.add(_utcPlus7),
      durationMinutes:
          (raw['duration_minutes'] as int?) ??
          (service?['duration_minutes'] as int?) ??
          60,
      customerName: (raw['contact_name'] as String?)?.trim().isNotEmpty == true
          ? (raw['contact_name'] as String)
          : 'Customer',
      address: (raw['address'] as String?)?.trim().isNotEmpty == true
          ? (raw['address'] as String)
          : 'No address provided',
      notes: (raw['notes'] as String?)?.trim() ?? '',
      totalPriceUsd:
          double.tryParse(raw['total_price']?.toString() ?? '0') ?? 0,
      contactPhone: raw['contact_phone'] as String?,
      status: wkScheduleStatusFromDb(raw['status'] as String?),
    );
  }

  Future<void> _autoRejectOverduePending(String userId) async {
    await _client
        .from(SupabaseTables.bookings)
        .update({
          'status': 'rejected',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('worker_id', userId)
        .eq('status', 'pending')
        .lt('scheduled_at', DateTime.now().toUtc().toIso8601String());
  }

  Future<void> _autoCompleteOverdueInProgress(String userId) async {
    final cutoffUtc = DateTime.now().toUtc().subtract(
      const Duration(hours: 12),
    );

    await _client
        .from(SupabaseTables.bookings)
        .update({
          'status': 'completed',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('worker_id', userId)
        .eq('status', 'in_progress')
        .lt('updated_at', cutoffUtc.toIso8601String());
  }

  Future<void> _appendSystemMessageForStatus({
    required String bookingId,
    required String status,
  }) async {
    final message = switch (status) {
      'accepted' => 'Worker accepted this booking.',
      'in_progress' => 'Worker started the job.',
      'completed' => 'Booking marked as completed.',
      'rejected' => 'Worker rejected this booking.',
      'cancelled' => 'Booking was cancelled.',
      _ => null,
    };

    if (message == null) return;

    final conversation = await _client
        .from(SupabaseTables.chatConversations)
        .select('id')
        .eq('booking_id', bookingId)
        .maybeSingle();

    final conversationId = conversation?['id'] as String?;
    if (conversationId == null) return;

    await _client.from(SupabaseTables.chatMessages).insert({
      'conversation_id': conversationId,
      'booking_id': bookingId,
      'sender_id': null,
      'sender_role': 'system',
      'message_type': 'system',
      'text': message,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'read_by_worker': true,
      'read_by_customer': true,
    });

    await _client
        .from(SupabaseTables.chatConversations)
        .update({
          'last_message_type': 'system',
          'last_message_text': message,
          'last_message_at': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', conversationId);
  }
}
