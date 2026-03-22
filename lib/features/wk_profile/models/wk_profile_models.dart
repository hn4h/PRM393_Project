class WkServiceItem {
  final String id;
  final String name;

  const WkServiceItem({required this.id, required this.name});
}

class WkIncomeItem {
  final String bookingId;
  final String serviceName;
  final double amountUsd;
  final DateTime completedAtUtc7;

  const WkIncomeItem({
    required this.bookingId,
    required this.serviceName,
    required this.amountUsd,
    required this.completedAtUtc7,
  });
}

class WkReviewItem {
  final String id;
  final String? bookingId;
  final int rating;
  final String comment;
  final DateTime createdAtUtc7;

  const WkReviewItem({
    required this.id,
    required this.bookingId,
    required this.rating,
    required this.comment,
    required this.createdAtUtc7,
  });
}

class WkDayAvailability {
  final String day;
  final bool enabled;
  final String start;
  final String end;

  const WkDayAvailability({
    required this.day,
    required this.enabled,
    required this.start,
    required this.end,
  });

  WkDayAvailability copyWith({bool? enabled, String? start, String? end}) {
    return WkDayAvailability(
      day: day,
      enabled: enabled ?? this.enabled,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  Map<String, dynamic> toJson() => {
    'day': day,
    'enabled': enabled,
    'start': start,
    'end': end,
  };

  factory WkDayAvailability.fromJson(Map<String, dynamic> json) {
    return WkDayAvailability(
      day: (json['day'] as String?) ?? 'Mon',
      enabled: (json['enabled'] as bool?) ?? false,
      start: (json['start'] as String?) ?? '08:00',
      end: (json['end'] as String?) ?? '17:00',
    );
  }
}

class WkProfileData {
  final String userId;
  final String name;
  final String? avatarUrl;
  final String? email;
  final String bio;
  final double rating;
  final int completedJobs;
  final double acceptanceRate;
  final List<WkServiceItem> selectedServices;
  final List<WkServiceItem> allServices;
  final double monthlyEarningsUsd;
  final List<WkIncomeItem> incomeHistory;
  final List<WkReviewItem> reviews;
  final bool notificationSound;
  final bool notificationVibration;
  final List<WkDayAvailability> weeklyAvailability;
  final List<DateTime> timeOffDates;

  const WkProfileData({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.email,
    required this.bio,
    required this.rating,
    required this.completedJobs,
    required this.acceptanceRate,
    required this.selectedServices,
    required this.allServices,
    required this.monthlyEarningsUsd,
    required this.incomeHistory,
    required this.reviews,
    required this.notificationSound,
    required this.notificationVibration,
    required this.weeklyAvailability,
    required this.timeOffDates,
  });

  WkProfileData copyWith({
    String? bio,
    List<WkServiceItem>? selectedServices,
    bool? notificationSound,
    bool? notificationVibration,
    List<WkDayAvailability>? weeklyAvailability,
    List<DateTime>? timeOffDates,
  }) {
    return WkProfileData(
      userId: userId,
      name: name,
      avatarUrl: avatarUrl,
      email: email,
      bio: bio ?? this.bio,
      rating: rating,
      completedJobs: completedJobs,
      acceptanceRate: acceptanceRate,
      selectedServices: selectedServices ?? this.selectedServices,
      allServices: allServices,
      monthlyEarningsUsd: monthlyEarningsUsd,
      incomeHistory: incomeHistory,
      reviews: reviews,
      notificationSound: notificationSound ?? this.notificationSound,
      notificationVibration:
          notificationVibration ?? this.notificationVibration,
      weeklyAvailability: weeklyAvailability ?? this.weeklyAvailability,
      timeOffDates: timeOffDates ?? this.timeOffDates,
    );
  }
}
