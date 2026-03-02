class Category {
  final String id;
  final String name;
  final String icon;
  final String image;
  final String description;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.image,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      image: json['image'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'image': image,
      'description': description,
    };
  }
}

// Example categories for demo
List<Category> demoCategories = [
  Category(
    id: '1',
    name: 'Cleaning',
    icon: 'assets/icons/cleaning.png',
    image: 'https://picsum.photos/id/71/500/300',
    description: 'Professional cleaning services for your home',
  ),
  Category(
    id: '2',
    name: 'Plumbing',
    icon: 'assets/icons/plumbing.png',
    image: 'https://picsum.photos/id/72/500/300',
    description: 'Expert plumbers for all your plumbing needs',
  ),
  Category(
    id: '3',
    name: 'Electrical',
    icon: 'assets/icons/electrical.png',
    image: 'https://picsum.photos/id/73/500/300',
    description: 'Certified electricians for installation and repairs',
  ),
  Category(
    id: '4',
    name: 'Painting',
    icon: 'assets/icons/painting.png',
    image: 'https://picsum.photos/id/74/500/300',
    description: 'Transform your space with professional painting services',
  ),
  Category(
    id: '5',
    name: 'Appliance Repair',
    icon: 'assets/icons/appliance.png',
    image: 'https://picsum.photos/id/75/500/300',
    description: 'Fixing all types of home appliances',
  ),
  Category(
    id: '6',
    name: 'Gardening',
    icon: 'assets/icons/gardening.png',
    image: 'https://picsum.photos/id/76/500/300',
    description: 'Professional garden maintenance and landscaping',
  ),
  Category(
    id: '7',
    name: 'Carpentry',
    icon: 'assets/icons/carpentry.png',
    image: 'https://picsum.photos/id/77/500/300',
    description: 'Custom woodwork and furniture repairs',
  ),
  Category(
    id: '8',
    name: 'Moving',
    icon: 'assets/icons/moving.png',
    image: 'https://picsum.photos/id/78/500/300',
    description: 'Efficient and safe relocation services',
  ),
];
