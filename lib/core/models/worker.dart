class Worker {
  final String id;
  final String name;
  final String jobTitle;
  final String description;
  final double rating;
  final String image;
  final int experienceYears;
  final int clients;
  final bool isVerified;
  final List<String> galleryImages;
  final List<String> serviceIds;
  final String workingDays; // "Mon - Fri"
  final String workingTime; // "9:00 AM - 5:00 PM"
  final String location; // "Hanoi, Vietnam"

  Worker({
    required this.id,
    required this.name,
    required this.jobTitle,
    required this.description,
    required this.rating,
    required this.image,
    this.experienceYears = 0,
    this.clients = 0,
    this.isVerified = false,
    this.galleryImages = const [],
    this.serviceIds = const [],
    this.workingDays = "Mon - Fri",
    this.workingTime = "9:00 AM - 5:00 PM",
    this.location = "",
  });

  /// Parse from Supabase response (workers joined with profiles).
  factory Worker.fromMap(Map<String, dynamic> map) {
    // Support flat map or nested profile join
    final profile = map['profile'] as Map<String, dynamic>? ?? map;

    return Worker(
      id: map['id'] as String? ?? map['user_id'] as String? ?? '',
      name: profile['full_name'] as String? ?? 'Worker',
      jobTitle: map['specialization'] as String? ?? '',
      description: map['bio'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      image: profile['avatar_url'] as String? ?? '',
      experienceYears: map['experience_years'] as int? ?? 0,
      clients: map['total_clients'] as int? ?? 0,
      isVerified: map['is_verified'] as bool? ?? false,
      galleryImages: (map['gallery_images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      serviceIds: (map['service_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      workingDays: map['working_days'] as String? ?? 'Mon - Fri',
      workingTime: map['working_time'] as String? ?? '9:00 AM - 5:00 PM',
      location: profile['address'] as String? ?? '',
    );
  }
}

final List<Worker> demoWorkers = [
  Worker(
    id: "w1",
    name: "Duc Anh",
    jobTitle: "Cleaning",
    description:
        "Duc Anh is a highly experienced home cleaner with over 10 years in the industry.",
    rating: 4.9,
    image: "https://picsum.photos/id/1027/500/500",
    experienceYears: 10,
    clients: 1200,
    isVerified: true,
    galleryImages: [
      "https://picsum.photos/id/200/500/300",
      "https://picsum.photos/id/201/500/300",
      "https://picsum.photos/id/202/500/300",
    ],
    serviceIds: ["1", "2", "6"],
    workingDays: "Mon - Fri",
    workingTime: "9:00 AM - 5:00 PM",
    location: "Hanoi, Vietnam",
  ),
  Worker(
    id: "w2",
    name: "Tu Anh",
    jobTitle: "Plumbing",
    description:
        "Tu Anh is a professional plumber with 8+ years of experience in pipe repair and installation.",
    rating: 4.8,
    image: "https://picsum.photos/id/1012/500/500",
    experienceYears: 8,
    clients: 950,
    isVerified: true,
    galleryImages: [
      "https://picsum.photos/id/210/500/300",
      "https://picsum.photos/id/211/500/300",
      "https://picsum.photos/id/212/500/300",
    ],
    serviceIds: ["3", "4", "5"],
    workingDays: "Mon - Fri",
    workingTime: "9:00 AM - 5:00 PM",
    location: "Hanoi, Vietnam",
  ),
];
