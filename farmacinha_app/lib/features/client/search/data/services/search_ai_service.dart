import 'dart:convert';

import 'package:farmacia_app/core/config/api_config.dart';
import 'package:farmacia_app/features/client/home_client/data/models/product_model.dart';
import 'package:farmacia_app/features/client/search/data/models/search_ai_result.dart';
import 'package:http/http.dart' as http;

class SearchAiService {
  SearchAiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<SearchAiResult> searchProducts({
    required String query,
    required List<Product> products,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/buscar-produtos-inteligente');

    final response = await _client
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'consulta': query,
            'produtos': products
                .map(
                  (product) => {
                    'id': product.id,
                    'nome': product.name,
                    'categoria': product.category,
                    'descricao': product.description,
                  },
                )
                .toList(),
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw SearchAiServiceException(
        'Erro na busca inteligente. Status: ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const SearchAiServiceException(
        'Resposta invalida da busca inteligente.',
      );
    }

    return SearchAiResult.fromJson(decoded);
  }

  void dispose() {
    _client.close();
  }
}

class SearchAiServiceException implements Exception {
  const SearchAiServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
