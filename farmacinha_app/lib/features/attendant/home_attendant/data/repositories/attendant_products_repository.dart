import 'dart:typed_data';

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
      'registration_date': registrationDate.toIso8601String(),
      'is_controlled': isControlled,
      'is_active': true,
      if (imageUrl != null) 'image_url': imageUrl,
      if (userId != null) 'registered_by': userId,
    };
  }
}

class AttendantProductsRepository {
  AttendantProductsRepository._();

  static final AttendantProductsRepository instance =
      AttendantProductsRepository._();

  static const String _productsTable = 'products';
  static const String _productImagesBucket = 'product-images';

  SupabaseClient get _client => Supabase.instance.client;

  Future<void> saveProduct({
    required AttendantProductPayload payload,
    Uint8List? imageBytes,
    String? imageExtension,
  }) async {
    final userId = _client.auth.currentUser?.id;
    final imageUrl = imageBytes == null
        ? null
        : await _uploadProductImage(
            bytes: imageBytes,
            extension: imageExtension ?? 'jpg',
            productId: payload.id,
          );

    final data = payload.toSupabaseMap(imageUrl: imageUrl, userId: userId);

    if (payload.id == null || payload.id!.isEmpty) {
      await _client.from(_productsTable).insert(data);
      return;
    }

    await _client.from(_productsTable).update(data).eq('id', payload.id!);
  }

  Future<String> _uploadProductImage({
    required Uint8List bytes,
    required String extension,
    String? productId,
  }) async {
    final normalizedExtension = extension.replaceAll('.', '').toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final owner = _client.auth.currentUser?.id ?? 'anonymous';
    final safeProductId = productId?.isNotEmpty == true ? productId : 'new';
    final filePath =
        '$owner/$safeProductId-$timestamp.$normalizedExtension';

    await _client.storage.from(_productImagesBucket).uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(
            contentType: _contentTypeFor(normalizedExtension),
            upsert: true,
          ),
        );

    return _client.storage.from(_productImagesBucket).getPublicUrl(filePath);
  }

  String _contentTypeFor(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpeg':
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }
}
