import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../../../core/providers/settings_provider.dart';
import '../models/wk_profile_models.dart';

part 'wk_profile_repository.g.dart';

@riverpod
WkProfileRepository wkProfileRepository(WkProfileRepositoryRef ref) {
  return WkProfileRepository(
    Supabase.instance.client,
    ref.read(sharedPreferencesProvider),
  );
}

class WkProfileRepository {
  static const Duration _utcPlus7 = Duration(hours: 7);

  final SupabaseClient _client;
  final SharedPreferences _prefs;

  const WkProfileRepository(this._client, this._prefs);

  Future<WkProfileData> loadProfileData() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('You are not signed in.');
    }

    await _autoCompleteOverdueInProgress(user.id);

    final profile = await _client
        .from(SupabaseTables.profiles)
        .select('id, full_name, avatar_url')
        .eq('id', user.id)
        .maybeSingle();

    final worker = await _client
        .from(SupabaseTables.workers)
        .select('bio')
        .eq('profile_id', user.id)
        .maybeSingle();

    final allServicesRows = await _client
        .from(SupabaseTables.services)
        .select('id, name')
        .order('name', ascending: true);

    final selectedServiceRows = await _client
        .from('worker_services')
        .select('service_id, service:services(id, name)')
        .eq('worker_id', user.id);

    final bookingRows = await _client
        .from(SupabaseTables.bookings)
        .select('id, status, total_price, scheduled_at, service:services(name)')
        .eq('worker_id', user.id)
        .order('scheduled_at', ascending: false);

    final reviewRows = await _client
        .from(SupabaseTables.reviews)
        .select('id, booking_id, rating, comment, created_at')
        .eq('worker_id', user.id)
        .order('created_at', ascending: false);

    final allServices = allServicesRows
        .map(
          (row) => WkServiceItem(
            id: row['id'] as String,
            name: (row['name'] as String?) ?? 'Service',
          ),
        )
        .toList(growable: false);

    final selectedServices = selectedServiceRows
        .map((row) {
          final service = row['service'] as Map<String, dynamic>?;
          return WkServiceItem(
            id: (service?['id'] as String?) ?? (row['service_id'] as String),
            name: (service?['name'] as String?) ?? 'Service',
          );
        })
        .toList(growable: false);

    final completedBookings = bookingRows
        .where((b) => b['status'] == 'completed')
        .toList(growable: false);

    final acceptedLike = bookingRows.where((b) {
      final s = b['status'] as String?;
      return s == 'accepted' || s == 'in_progress' || s == 'completed';
    }).length;

    final considered = bookingRows.where((b) {
      final s = b['status'] as String?;
      return s == 'pending' ||
          s == 'accepted' ||
          s == 'in_progress' ||
          s == 'completed' ||
          s == 'rejected';
    }).length;

    final acceptanceRate = considered == 0
        ? 0.0
        : (acceptedLike / considered) * 100.0;

    final nowUtc7 = DateTime.now().toUtc().add(_utcPlus7);
    final monthlyEarnings = completedBookings.fold<double>(0, (sum, b) {
      final time = DateTime.tryParse(
        b['scheduled_at']?.toString() ?? '',
      )?.toUtc().add(_utcPlus7);
      if (time == null ||
          time.month != nowUtc7.month ||
          time.year != nowUtc7.year) {
        return sum;
      }
      return sum + (double.tryParse(b['total_price']?.toString() ?? '0') ?? 0);
    });

    final incomeHistory = completedBookings
        .map((b) {
          final service = b['service'] as Map<String, dynamic>?;
          final dt =
              DateTime.tryParse(
                b['scheduled_at']?.toString() ?? '',
              )?.toUtc().add(_utcPlus7) ??
              nowUtc7;
          return WkIncomeItem(
            bookingId: b['id'] as String,
            serviceName: (service?['name'] as String?) ?? 'Service',
            amountUsd:
                double.tryParse(b['total_price']?.toString() ?? '0') ?? 0,
            completedAtUtc7: dt,
          );
        })
        .toList(growable: false);

    final reviews = reviewRows
        .map((r) {
          return WkReviewItem(
            id: r['id'] as String,
            bookingId: r['booking_id'] as String?,
            rating: (r['rating'] as num?)?.toInt() ?? 0,
            comment: (r['comment'] as String?) ?? '',
            createdAtUtc7:
                DateTime.tryParse(
                  r['created_at']?.toString() ?? '',
                )?.toUtc().add(_utcPlus7) ??
                nowUtc7,
          );
        })
        .toList(growable: false);

    final avgRating = reviews.isEmpty
        ? 0.0
        : reviews.fold<int>(0, (sum, r) => sum + r.rating) / reviews.length;

    final notifySound = _prefs.getBool('wk_notify_sound_${user.id}') ?? true;
    final notifyVibration =
        _prefs.getBool('wk_notify_vibration_${user.id}') ?? true;

    final weekly = _loadWeeklyAvailability(user.id);
    final timeOff = _loadTimeOffDates(user.id);

    return WkProfileData(
      userId: user.id,
      name: (profile?['full_name'] as String?)?.trim().isNotEmpty == true
          ? (profile!['full_name'] as String)
          : (user.email?.split('@').first ?? 'Worker'),
      avatarUrl: profile?['avatar_url'] as String?,
      email: user.email,
      bio: (worker?['bio'] as String?)?.trim() ?? '',
      rating: avgRating,
      completedJobs: completedBookings.length,
      acceptanceRate: acceptanceRate,
      selectedServices: selectedServices,
      allServices: allServices,
      monthlyEarningsUsd: monthlyEarnings,
      incomeHistory: incomeHistory,
      reviews: reviews,
      notificationSound: notifySound,
      notificationVibration: notifyVibration,
      weeklyAvailability: weekly,
      timeOffDates: timeOff,
    );
  }

  Future<void> updateBio(String userId, String bio) async {
    await _client.from(SupabaseTables.workers).upsert({
      'profile_id': userId,
      'bio': bio.trim(),
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'profile_id');
  }

  Future<void> updateWorkerServices(
    String userId,
    List<String> serviceIds,
  ) async {
    await _client.from('worker_services').delete().eq('worker_id', userId);

    if (serviceIds.isEmpty) return;

    final rows = serviceIds
      .map((id) => {'worker_id': userId, 'service_id': id})
        .toList(growable: false);

    await _client.from('worker_services').insert(rows);
  }

  Future<void> saveNotificationSettings(
    String userId, {
    required bool sound,
    required bool vibration,
  }) async {
    await _prefs.setBool('wk_notify_sound_$userId', sound);
    await _prefs.setBool('wk_notify_vibration_$userId', vibration);
  }

  Future<void> saveAvailability(
    String userId,
    List<WkDayAvailability> weekly,
  ) async {
    final encoded = jsonEncode(
      weekly.map((d) => d.toJson()).toList(growable: false),
    );
    await _prefs.setString('wk_availability_$userId', encoded);
  }

  Future<void> saveTimeOffDates(String userId, List<DateTime> dates) async {
    final encoded = jsonEncode(
      dates.map((d) => d.toIso8601String()).toList(growable: false),
    );
    await _prefs.setString('wk_timeoff_$userId', encoded);
  }

  List<WkDayAvailability> _loadWeeklyAvailability(String userId) {
    final raw = _prefs.getString('wk_availability_$userId');
    if (raw == null || raw.isEmpty) {
      return const [
        WkDayAvailability(
          day: 'Mon',
          enabled: true,
          start: '08:00',
          end: '17:00',
        ),
        WkDayAvailability(
          day: 'Tue',
          enabled: true,
          start: '08:00',
          end: '17:00',
        ),
        WkDayAvailability(
          day: 'Wed',
          enabled: true,
          start: '08:00',
          end: '17:00',
        ),
        WkDayAvailability(
          day: 'Thu',
          enabled: true,
          start: '08:00',
          end: '17:00',
        ),
        WkDayAvailability(
          day: 'Fri',
          enabled: true,
          start: '08:00',
          end: '17:00',
        ),
        WkDayAvailability(
          day: 'Sat',
          enabled: false,
          start: '08:00',
          end: '17:00',
        ),
        WkDayAvailability(
          day: 'Sun',
          enabled: false,
          start: '08:00',
          end: '17:00',
        ),
      ];
    }

    final list = (jsonDecode(raw) as List)
        .map(
          (item) => WkDayAvailability.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(growable: false);

    return list;
  }

  List<DateTime> _loadTimeOffDates(String userId) {
    final raw = _prefs.getString('wk_timeoff_$userId');
    if (raw == null || raw.isEmpty) return const [];

    return (jsonDecode(raw) as List)
        .map((s) => DateTime.tryParse(s.toString()))
        .whereType<DateTime>()
        .toList(growable: false);
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
}
