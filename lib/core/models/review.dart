class Review {
  final String id;
  final String serviceId;
  final String workerId;
  final String bookingId;
  final String userId;
  final String userName;
  final String userImage;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.serviceId,
    required this.workerId,
    required this.bookingId,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  /// Parse from Supabase response (snake_case keys).
  factory Review.fromMap(Map<String, dynamic> map) {
    // Support joined profile data for reviewer name/image
    final profile = map['profile'] as Map<String, dynamic>?;

    return Review(
      id: map['id'] as String,
      serviceId: map['service_id'] as String? ?? '',
      workerId: map['worker_id'] as String? ?? '',
      bookingId: map['booking_id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      userName: profile?['full_name'] as String? ??
          map['user_name'] as String? ??
          'User',
      userImage: profile?['avatar_url'] as String? ??
          map['user_image'] as String? ??
          '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      comment: map['comment'] as String? ?? '',
      createdAt: DateTime.parse(
          map['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  /// For legacy demo data compatibility.
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      serviceId: json['serviceId'] as String? ?? json['service_id'] as String? ?? '',
      workerId: json['workerId'] as String? ?? json['worker_id'] as String? ?? '',
      bookingId: json['bookingId'] as String? ?? json['booking_id'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      userName: json['userName'] as String? ?? json['user_name'] as String? ?? '',
      userImage: json['userImage'] as String? ?? json['user_image'] as String? ?? '',
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.parse(
          json['createdAt'] as String? ?? json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  /// Map for INSERT into reviews table.
  Map<String, dynamic> toInsertMap() => {
        'service_id': serviceId,
        'worker_id': workerId,
        'booking_id': bookingId,
        'user_id': userId,
        'rating': rating,
        'comment': comment,
      };

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'worker_id': workerId,
      'booking_id': bookingId,
      'user_id': userId,
      'user_name': userName,
      'user_image': userImage,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Example reviews for demo
List<Review> demoReviews = [
  Review(
    id: 'r1',
    serviceId: '1',
    workerId: 'w1',
    bookingId: 'b1',
    userId: 'user1',
    userName: 'Sarah Johnson',
    userImage: 'https://picsum.photos/id/1005/100/100',
    rating: 5.0,
    comment:
        'Excellent service! James did a thorough job cleaning our apartment and was very professional.',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  Review(
    id: 'r2',
    serviceId: '1',
    workerId: 'w1',
    bookingId: 'b2',
    userId: 'user2',
    userName: 'Michael Brown',
    userImage: 'https://picsum.photos/id/1006/100/100',
    rating: 4.5,
    comment:
        'Great cleaning service. Arrived on time and completed everything properly.',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  Review(
    id: 'r3',
    serviceId: '3',
    workerId: 'w2',
    bookingId: 'b3',
    userId: 'user3',
    userName: 'Emily Davis',
    userImage: 'https://picsum.photos/id/1008/100/100',
    rating: 4.8,
    comment:
        'Michael fixed the pipe leak quickly and explained everything clearly.',
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
];
