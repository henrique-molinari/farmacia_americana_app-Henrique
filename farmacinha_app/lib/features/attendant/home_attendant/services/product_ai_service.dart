import 'dart:convert';

import 'package:farmacia_app/core/config/api_config.dart';
import 'package:http/http.dart' as http;

class ProductAiService {
  ProductAiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String> generateDescription(String productName) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/gerar-descricao');

    final response = await _client
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'nomeProduto': productName}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw ProductAiServiceException(
        'Erro ao gerar descrição. Status: ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || !decoded.containsKey('descricao')) {
      throw const ProductAiServiceException(
        'Resposta inválida: chave descricao não encontrada.',
      );
    }

    final description = decoded['descricao'];
    if (description is! String) {
      throw const ProductAiServiceException(
        'Resposta inválida: descricao deve ser texto.',
      );
    }

    final normalizedDescription = description.trim();
    if (normalizedDescription.isEmpty) {
      throw const ProductAiServiceException(
        'A IA não retornou uma descrição válida.',
      );
    }

    return normalizedDescription;
  }

  void dispose() {
    _client.close();
  }
}

class ProductAiServiceException implements Exception {
  final String message;

  const ProductAiServiceException(this.message);

  @override
  String toString() => message;
}
