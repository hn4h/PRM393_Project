class Worker {
  final String name;
  final String description;
  final double rating;
  final String image;

  Worker({
    required this.name,
    required this.description,
    required this.rating,
    required this.image,
  });
}

final List<Worker> demoWorkers = [
  Worker(
    name: "James Anderson",
    description:
        "James Anderson is a highly experienced home cleaner with over...",
    rating: 4.9,
    image: "https://picsum.photos/id/1027/500/500",
  ),
  Worker(
    name: "Michael C",
    description:
        "Michael is a professional plumber with a passion for fixing...",
    rating: 4.8,
    image: "https://picsum.photos/id/1012/500/500",
  ),
];
