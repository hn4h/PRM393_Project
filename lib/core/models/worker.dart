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
  });
}

final List<Worker> demoWorkers = [
  Worker(
    id: "w1",
    name: "James Anderson",
    jobTitle: "Cleaning",
    description:
        "James Anderson is a highly experienced home cleaner with over 10 years in the industry.",
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
  ),
  Worker(
    id: "w2",
    name: "Michael C",
    jobTitle: "Plumbing",
    description:
        "Michael is a professional plumber with 8+ years of experience in pipe repair and installation.",
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
  ),
];