import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../models/wk_home_models.dart';

part 'wk_home_repository.g.dart';

@riverpod
WkHomeRepository wkHomeRepository(WkHomeRepositoryRef ref) {
  return WkHomeRepository(Supabase.instance.client);
}

class WkHomeRepository {
  static const Duration _utcPlus7 = Duration(hours: 7);

  final SupabaseClient _client;

  const WkHomeRepository(this._client);

  Future<WkHomeState> fetchHomeState() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('You are not signed in.');
    }

    await _autoRejectOverduePending(userId);
    await _autoCompleteOverdueInProgress(userId);

    final profileData = await _client
        .from(SupabaseTables.profiles)
        .select('full_name, avatar_url')
        .eq('id', userId)
        .maybeSingle();

    final workerData = await _client
        .from(SupabaseTables.workers)
        .select('is_available')
        .eq('profile_id', userId)
        .maybeSingle();

    final bookingRows = await _client
        .from(SupabaseTables.bookings)
        .select(
          'id, status, scheduled_at, address, notes, total_price, duration_minutes, contact_name, contact_phone, service:services(name, duration_minutes)',
        )
        .eq('worker_id', userId)
        .order('scheduled_at', ascending: true);

    final allBookings = bookingRows
        .map((row) => _toBookingCardData(row))
        .toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool isSameDay(DateTime date) {
      final d = DateTime(date.year, date.month, date.day);
      return d == today;
    }

    final pending = allBookings
        .where((b) => b.status == WkJobStatus.pending)
        .toList();

    final todaySchedule = allBookings.where((b) {
      final isToday = isSameDay(b.scheduledAt);
      final isVisibleState =
          b.status == WkJobStatus.upcoming ||
          b.status == WkJobStatus.inProgress ||
          b.status == WkJobStatus.completed;
      return isToday && isVisibleState;
    }).toList()..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    final expectedIncome = todaySchedule.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );

    final stats = WkQuickStats(
      pendingRequests: pending.length,
      todayJobs: todaySchedule.length,
      expectedIncome: expectedIncome,
    );

    return WkHomeState(
      workerName:
          (profileData?['full_name'] as String?)?.trim().isNotEmpty == true
          ? (profileData!['full_name'] as String)
          : 'Worker',
      avatarUrl: profileData?['avatar_url'] as String?,
      isOnline: workerData?['is_available'] as bool? ?? true,
      unreadMessages: 0,
      stats: stats,
      pendingRequests: pending,
      todaySchedule: todaySchedule,
    );
  }

  Future<void> setAvailability(bool isAvailable) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('You are not signed in.');

    await _client.from(SupabaseTables.workers).upsert({
      'profile_id': userId,
      'is_available': isAvailable,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'profile_id');
  }

  Future<void> acceptBooking(String bookingId) {
    return _updateBookingStatus(bookingId, 'accepted');
  }

  Future<void> declineBooking(String bookingId) {
    return _updateBookingStatus(bookingId, 'rejected');
  }

  Future<void> startBooking(String bookingId) {
    return _updateBookingStatus(bookingId, 'in_progress');
  }

  Future<void> completeBooking(String bookingId) {
    return _updateBookingStatus(bookingId, 'completed');
  }

  Future<void> _updateBookingStatus(String bookingId, String status) async {
    await _client
        .from(SupabaseTables.bookings)
        .update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId);

    await _appendSystemMessageForStatus(bookingId: bookingId, status: status);
  }

  WkBookingCardData _toBookingCardData(Map<String, dynamic> map) {
    final serviceMap = map['service'] as Map<String, dynamic>?;
    final scheduledAtRaw = DateTime.tryParse(
      map['scheduled_at']?.toString() ?? '',
    );
    final scheduledAtUtc7 = scheduledAtRaw == null
        ? DateTime.now().toUtc().add(_utcPlus7)
        : scheduledAtRaw.toUtc().add(_utcPlus7);

    return WkBookingCardData(
      id: map['id'] as String,
      serviceName: (serviceMap?['name'] as String?) ?? 'Home Service',
      scheduledAt: scheduledAtUtc7,
      durationMinutes:
          (map['duration_minutes'] as int?) ??
          (serviceMap?['duration_minutes'] as int?) ??
          60,
      customerName: (map['contact_name'] as String?)?.trim().isNotEmpty == true
          ? (map['contact_name'] as String)
          : 'Customer',
      address: (map['address'] as String?)?.trim().isNotEmpty == true
          ? (map['address'] as String)
          : 'No address provided',
      notes: (map['notes'] as String?)?.trim() ?? '',
      totalPrice: double.tryParse(map['total_price']?.toString() ?? '0') ?? 0,
      contactPhone: map['contact_phone'] as String?,
      status: wkJobStatusFromDb(map['status'] as String?),
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
