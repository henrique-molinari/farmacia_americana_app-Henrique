import 'package:farmacia_app/core/utils/date_time_utils.dart';
import 'package:farmacia_app/features/attendant/home_attendant/data/models/attendant_stock_product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendantProductPayload {
  final String? id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int stockQuantity;
  final DateTime registrationDate;
  final bool isControlled;

  const AttendantProductPayload({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.stockQuantity,
    required this.registrationDate,
    required this.isControlled,
  });

  Map<String, dynamic> toSupabaseMap({String? imageUrl, String? userId}) {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'stock_quantity': stockQuantity,
      'registration_date': localDateToUtcIso(registrationDate),
      'is_controlled': isControlled,
      'is_active': true,
      if (imageUrl != null) 'image_url': imageUrl,
      if (userId != null) 'registered_by': userId,
    };
  }
}

class AttendantProductsRepository {
  AttendantProductsRepository({SupabaseClient? client})
    : _clientOverride = client;

  static final AttendantProductsRepository instance =
      AttendantProductsRepository();

  static const String _productsTable = 'products';
  static const String _productImagesBucket = 'product-images';

  final SupabaseClient? _clientOverride;

  SupabaseClient get _client => _clientOverride ?? Supabase.instance.client;

  Future<List<AttendantStockProduct>> fetchProducts() async {
    final response = await _client
        .from(_productsTable)
        .select(
          'id, name, description, category, price, stock_quantity, image_url, is_controlled, is_active, registration_date',
        )
        .order('name');

    return response
        .map<AttendantStockProduct>(
          (product) => AttendantStockProduct.fromSupabaseMap(product),
        )
        .toList(growable: false);
  }

  Future<void> saveProduct({
    required AttendantProductPayload payload,
    String? imageUrl,
  }) async {
    final userId = _client.auth.currentUser?.id;
    final data = payload.toSupabaseMap(imageUrl: imageUrl, userId: userId);

    if (payload.id == null || payload.id!.isEmpty) {
      await _client.from(_productsTable).insert(data);
    } else {
      await _client.from(_productsTable).update(data).eq('id', payload.id!);
    }
  }

  Future<void> deleteProduct(String productId) async {
    await _client.from(_productsTable).delete().eq('id', productId);
  }
}
