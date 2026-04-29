import 'package:farmacia_app/features/attendant/home_attendant/services/product_ai_service.dart';

class ProductAiRepository {
  ProductAiRepository({ProductAiService? service})
      : _service = service ?? ProductAiService();

  final ProductAiService _service;

  Future<String> generateDescription(String productName) {
    return _service.generateDescription(productName);
  }

  void dispose() {
    _service.dispose();
  }
}
