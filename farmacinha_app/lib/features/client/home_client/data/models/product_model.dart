class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String category;
  final bool isOnPromotion;
  final int? discountPercentage;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.category,
    this.isOnPromotion = false,
    this.discountPercentage,
  });

  factory Product.fromSupabaseMap(Map<String, dynamic> map) {
    final rawPrice = map['price'];
    final parsedPrice = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '0') ?? 0;

    return Product(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      price: parsedPrice,
      imageUrl: (map['image_url'] ?? '').toString(),
      rating: 4.5,
      reviewCount: 0,
      category: (map['category'] ?? 'geral').toString(),
    );
  }
}
