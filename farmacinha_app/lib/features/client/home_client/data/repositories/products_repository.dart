import 'package:farmacia_app/features/client/home_client/data/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductsRepository {
  ProductsRepository._();

  static final ProductsRepository instance = ProductsRepository._();

  SupabaseClient get _client => Supabase.instance.client;

  Future<List<Product>> fetchActiveProducts() async {
    final response = await _client
        .from('products')
        .select(
          'id, name, description, price, category, image_url, is_controlled, is_active',
        )
        .eq('is_active', true)
        .order('name');

    return response
        .map<Product>(
          (product) => Product.fromSupabaseMap(product as Map<String, dynamic>),
        )
        .toList();
  }
}
