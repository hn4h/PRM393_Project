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

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      serviceId: json['serviceId'] as String,
      workerId: json['workerId'] as String,
      bookingId: json['bookingId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userImage: json['userImage'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'workerId': workerId,
      'bookingId': bookingId,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
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
