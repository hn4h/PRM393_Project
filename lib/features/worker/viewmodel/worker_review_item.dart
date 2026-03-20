class WorkerReviewItem {
  const WorkerReviewItem({
    required this.id,
    required this.customerName,
    required this.customerAvatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String customerName;
  final String customerAvatarUrl;
  final double rating;
  final String comment;
  final DateTime? createdAt;

  factory WorkerReviewItem.fromMap(
    Map<String, dynamic> map, {
    Map<String, dynamic>? customerProfile,
  }) {
    final customer = customerProfile ?? const {};

    return WorkerReviewItem(
      id: map['id'] as String? ?? '',
      customerName: customer['full_name'] as String? ?? 'Customer',
      customerAvatarUrl: customer['avatar_url'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      comment: map['comment'] as String? ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}
