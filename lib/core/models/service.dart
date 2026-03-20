  class Service {
    final String id;
    final String name;
    final String description;
    final double price;
    final String categoryId;
    final String image;
    final double rating;
    final int reviewCount;
    final int bookingCount;
    final List<String> images;
    final List<String> features;
    final bool isFeatured;
    final bool isPopular;
    final int durationMinutes; 
    final List<String> serviceTags; 
    final List<String> workerIds; 

    Service({
      required this.id,
      required this.name,
      required this.description,
      required this.price,
      required this.categoryId,
      required this.image,
      required this.rating,
      required this.reviewCount,
      required this.bookingCount,
      required this.images,
      required this.features,
      this.isFeatured = false,
      this.isPopular = false,
      this.durationMinutes = 0,
      this.serviceTags = const [],
      this.workerIds = const [],
    });

    factory Service.fromJson(Map<String, dynamic> json) {
      return Service(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        price: (json['price'] as num).toDouble(),
        categoryId: json['categoryId'] as String,
        image: json['image'] as String,
        rating: (json['rating'] as num).toDouble(),
        reviewCount: json['reviewCount'] as int,
        bookingCount: json['bookingCount'] as int,
        images: (json['images'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        features: (json['features'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        isFeatured: json['isFeatured'] as bool? ?? false,
        isPopular: json['isPopular'] as bool? ?? false,
        durationMinutes: json['durationMinutes'] as int? ?? 0,
        serviceTags: (json['serviceTags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        workerIds: (json['workerIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
      );
    }

    /// Parse from Supabase response (snake_case columns).
    factory Service.fromMap(Map<String, dynamic> map) {
      return Service(
        id: map['id'] as String,
        name: map['name'] as String? ?? '',
        description: map['description'] as String? ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0,
        categoryId: map['category'] as String? ?? '',
        image: map['image_url'] as String? ?? '',
        rating: (map['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: (map['review_count'] as int?) ?? 0,
        bookingCount: (map['booking_count'] as int?) ?? 0,
        images: const [],
        features: const [],
        isFeatured: map['is_featured'] as bool? ?? false,
        isPopular: map['is_popular'] as bool? ?? false,
        durationMinutes: (map['duration_minutes'] as num?)?.toInt() ?? 0,
        serviceTags: (map['service_tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        workerIds: const [],
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'categoryId': categoryId,
        'image': image,
        'rating': rating,
        'reviewCount': reviewCount,
        'bookingCount': bookingCount,
        'images': images,
        'features': features,
        'isFeatured': isFeatured,
        'isPopular': isPopular,
        'durationMinutes': durationMinutes,
        'serviceTags': serviceTags,
        'workerIds': workerIds,
      };
    }
  }

  // Example services for demo
  List<Service> demoServices = [
    Service(
      id: '1',
      name: 'Standard Home Cleaning',
      description:
          'Professional cleaning service to make your home spotless and fresh. Our team uses eco-friendly products and advanced cleaning techniques.',
      price: 120,
      categoryId: '1',
      image: 'https://picsum.photos/id/10/500/300',
      rating: 4.8,
      reviewCount: 245,
      bookingCount: 1250,
      images: [
        'https://picsum.photos/id/11/500/300',
        'https://picsum.photos/id/12/500/300',
        'https://picsum.photos/id/13/500/300',
      ],
      features: [
        'Dusting all accessible surfaces',
        'Vacuuming carpets and floors',
        'Mopping all floors',
        'Cleaning kitchen surfaces',
        'Cleaning bathrooms',
        'Waste removal',
      ],
      isFeatured: true,
      isPopular: true,
      durationMinutes: 120,
      serviceTags: const ["Cleaning", "Repair"],
      workerIds: const ["w1", "w2"],
    ),
    Service(
      id: '2',
      name: 'Deep Cleaning Service',
      description:
          'A thorough cleaning service for homes that need extra attention. Includes cleaning inside appliances, behind furniture, and detailed scrubbing.',
      price: 220,
      categoryId: '1',
      image: 'https://picsum.photos/id/20/500/300',
      rating: 4.9,
      reviewCount: 189,
      bookingCount: 876,
      images: [
        'https://picsum.photos/id/21/500/300',
        'https://picsum.photos/id/22/500/300',
        'https://picsum.photos/id/23/500/300',
      ],
      features: [
        'All standard cleaning tasks',
        'Inside oven and refrigerator cleaning',
        'Cabinet interiors',
        'Window cleaning',
        'Baseboards and door frames',
        'Light fixtures and ceiling fans',
      ],
      isFeatured: true,
      durationMinutes: 180,
      serviceTags: const ["Cleaning"],
      workerIds: const ["w1"],
    ),
    Service(
      id: '3',
      name: 'Pipe Leak Repair',
      description:
          'Fast and reliable repair for any pipe leaks in your home. Our certified plumbers fix all types of pipe leaks to prevent water damage.',
      price: 90,
      categoryId: '2',
      image: 'https://picsum.photos/id/30/500/300',
      rating: 4.7,
      reviewCount: 156,
      bookingCount: 735,
      images: [
        'https://picsum.photos/id/31/500/300',
        'https://picsum.photos/id/32/500/300',
        'https://picsum.photos/id/33/500/300',
      ],
      features: [
        'Leak detection',
        'Pipe repair or replacement',
        'Water pressure testing',
        'Fixture inspection',
        'Joint sealing',
        '30-day guarantee',
      ],
      isPopular: true,
      durationMinutes: 120,
      serviceTags: const ["Repair"],
      workerIds: const ["w2"],
    ),
    Service(
      id: '4',
      name: 'Bathroom Installation',
      description:
          'Complete bathroom installation service including fixtures, plumbing, and finishing. Transform your bathroom with our expert plumbers.',
      price: 580,
      categoryId: '2',
      image: 'https://picsum.photos/id/40/500/300',
      rating: 4.9,
      reviewCount: 122,
      bookingCount: 450,
      images: [
        'https://picsum.photos/id/41/500/300',
        'https://picsum.photos/id/42/500/300',
        'https://picsum.photos/id/43/500/300',
      ],
      features: [
        'Fixture installation',
        'Plumbing connection',
        'Tile installation',
        'Waterproofing',
        'Vanity installation',
        'Final inspection and testing',
      ],
      isFeatured: true,
      durationMinutes: 240,
      serviceTags: const ["Installation", "Repair"],
      workerIds: const ["w2"],
    ),
    Service(
      id: '5',
      name: 'Electrical Wiring',
      description:
          'Professional electrical wiring service for new installations or rewiring existing systems. All work meets safety codes and regulations.',
      price: 150,
      categoryId: '3',
      image: 'https://picsum.photos/id/50/500/300',
      rating: 4.8,
      reviewCount: 178,
      bookingCount: 689,
      images: [
        'https://picsum.photos/id/51/500/300',
        'https://picsum.photos/id/52/500/300',
        'https://picsum.photos/id/53/500/300',
      ],
      features: [
        'Circuit installation',
        'Panel upgrades',
        'Outlet installation',
        'Safety inspection',
        'Compliance with electrical codes',
        '1-year warranty on work',
      ],
      isPopular: true,
      durationMinutes: 180,
      serviceTags: const ["Repair", "Installation"],
      workerIds: const ["w2"],
    ),
    Service(
      id: '6',
      name: 'Room Painting',
      description:
          'Transform your space with our professional painting services. We use high-quality paints and techniques for a perfect finish.',
      price: 320,
      categoryId: '4',
      image: 'https://picsum.photos/id/60/500/300',
      rating: 4.7,
      reviewCount: 205,
      bookingCount: 920,
      images: [
        'https://picsum.photos/id/61/500/300',
        'https://picsum.photos/id/62/500/300',
        'https://picsum.photos/id/63/500/300',
      ],
      features: [
        'Surface preparation',
        'Premium quality paint',
        'Edge protection',
        'Furniture protection',
        'Two coats of paint',
        'Clean-up after completion',
      ],
      isFeatured: true,
      isPopular: true,
      durationMinutes: 240,
      serviceTags: const ["Painting"],
      workerIds: const ["w1"],
    ),
  ];
