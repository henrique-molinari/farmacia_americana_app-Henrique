import 'package:farmacia_app/core/utils/date_time_utils.dart';

class AttendantStockProduct {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int stockQuantity;
  final String imageUrl;
  final bool isControlled;
  final bool isActive;
  final DateTime? registrationDate;

  const AttendantStockProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.stockQuantity,
    required this.imageUrl,
    required this.isControlled,
    required this.isActive,
    this.registrationDate,
  });

  factory AttendantStockProduct.fromSupabaseMap(Map<String, dynamic> map) {
    final rawPrice = map['price'];
    final parsedPrice = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '0') ?? 0;

    final rawStock = map['stock_quantity'];
    final parsedStock = rawStock is num
        ? rawStock.toInt()
        : int.tryParse(rawStock?.toString() ?? '0') ?? 0;

    return AttendantStockProduct(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      category: (map['category'] ?? 'geral').toString(),
      price: parsedPrice,
      stockQuantity: parsedStock,
      imageUrl: (map['image_url'] ?? '').toString(),
      isControlled: map['is_controlled'] == true,
      isActive: map['is_active'] != false,
      registrationDate: tryParseUtcToLocal(
        map['registration_date']?.toString(),
      ),
    );
  }
}
