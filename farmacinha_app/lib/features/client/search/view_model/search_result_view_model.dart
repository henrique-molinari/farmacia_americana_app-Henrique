import 'package:farmacia_app/features/auth/view_models/auth_session_view_model.dart';
import 'package:farmacia_app/features/client/cart/view_model/cart_view_model.dart';
import 'package:farmacia_app/features/client/home_client/data/models/product_model.dart';
import 'package:farmacia_app/features/client/home_client/data/repositories/products_repository.dart';
import 'package:farmacia_app/features/client/search/data/services/search_ai_service.dart';
import 'package:flutter/material.dart';

class SearchResultViewModel extends ChangeNotifier {
  SearchResultViewModel({
    String? initialQuery,
    AuthSessionViewModel? authSession,
    SearchAiService? searchAiService,
  }) : _authSession = authSession ?? AuthSessionViewModel.instance,
       _searchAiService = searchAiService ?? SearchAiService() {
    if (initialQuery != null && initialQuery.isNotEmpty) {
      search(initialQuery);
    }
  }

  final AuthSessionViewModel _authSession;
  final SearchAiService _searchAiService;
  List<Product> filteredProducts = [];
  List<Product> similarProducts = [];
  String searchQuery = '';
  bool isLoading = false;
  bool usedAiSearch = false;

  Future<void> search(String query) async {
    final trimmedQuery = query.trim();

    isLoading = true;
    searchQuery = trimmedQuery;
    usedAiSearch = false;
    notifyListeners();

    if (trimmedQuery.isEmpty) {
      filteredProducts = [];
      similarProducts = [];
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final allProducts = await ProductsRepository.instance
          .fetchActiveProducts();

      final localResults = _searchLocally(trimmedQuery, allProducts);
      filteredProducts = localResults;

      try {
        final aiResult = await _searchAiService.searchProducts(
          query: trimmedQuery,
          products: allProducts,
        );
        final aiProducts = _filterRelevantAiProducts(
          query: trimmedQuery,
          products: _productsFromAiIds(aiResult.productIds, allProducts),
        );

        if (aiProducts.isNotEmpty) {
          filteredProducts = aiProducts;
          usedAiSearch = true;
        } else if (aiResult.terms.isNotEmpty) {
          final expandedLocalResults = _searchLocally(
            [trimmedQuery, ...aiResult.terms].join(' '),
            allProducts,
          );
          final relevantExpandedLocalResults = _filterRelevantAiProducts(
            query: trimmedQuery,
            products: expandedLocalResults,
          );

          if (relevantExpandedLocalResults.isNotEmpty) {
            filteredProducts = relevantExpandedLocalResults;
            usedAiSearch = true;
          }
        }
      } catch (error) {
        debugPrint('Erro na busca inteligente com IA: $error');
      }

      similarProducts = _buildSimilarProducts(
        query: trimmedQuery,
        results: filteredProducts,
        allProducts: allProducts,
      );
    } catch (error) {
      debugPrint('Erro ao buscar produtos no Supabase: $error');
      filteredProducts = [];
      similarProducts = [];
      usedAiSearch = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void addToCart(BuildContext context, Product product) {
    if (!_authSession.requireAuthentication(
      context,
      message: 'Entre com sua conta para adicionar produtos ao carrinho.',
    )) {
      return;
    }

    CartViewModel.instance.addProduct(product);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${product.name} adicionado ao carrinho.')),
      );
  }

  List<Product> _productsFromAiIds(List<String> ids, List<Product> products) {
    final productsById = {for (final product in products) product.id: product};

    return ids
        .map((id) => productsById[id])
        .whereType<Product>()
        .toList(growable: false);
  }

  List<Product> _filterRelevantAiProducts({
    required String query,
    required List<Product> products,
  }) {
    final normalizedQuery = _normalize(query);
    final queryTerms = _queryTermsFor(normalizedQuery);

    return products
        .where((product) {
          return _scoreProduct(
                product: product,
                normalizedQuery: normalizedQuery,
                queryTerms: queryTerms,
              ) >
              0;
        })
        .toList(growable: false);
  }

  List<Product> _buildSimilarProducts({
    required String query,
    required List<Product> results,
    required List<Product> allProducts,
  }) {
    if (results.isEmpty) {
      return [];
    }

    final category = results.first.category;
    final resultIds = results.map((product) => product.id).toSet();
    final normalizedQuery = _normalize(query);
    final queryTerms = _queryTermsFor(normalizedQuery);

    return allProducts.where((product) {
      final isSameCategory = product.category == category;
      final isNotInResults = !resultIds.contains(product.id);
      final isRelevantToQuery =
          _scoreProduct(
            product: product,
            normalizedQuery: normalizedQuery,
            queryTerms: queryTerms,
          ) >
          0;

      return isSameCategory && isNotInResults && isRelevantToQuery;
    }).toList();
  }

  List<Product> _searchLocally(String query, List<Product> products) {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) {
      return [];
    }

    final queryTerms = _queryTermsFor(normalizedQuery);

    if (queryTerms.isEmpty) {
      return [];
    }

    final scoredProducts = <_ScoredProduct>[];

    for (final product in products) {
      final score = _scoreProduct(
        product: product,
        normalizedQuery: normalizedQuery,
        queryTerms: queryTerms,
      );

      if (score > 0) {
        scoredProducts.add(_ScoredProduct(product, score));
      }
    }

    scoredProducts.sort((a, b) {
      final scoreComparison = b.score.compareTo(a.score);
      if (scoreComparison != 0) {
        return scoreComparison;
      }

      return a.product.name.compareTo(b.product.name);
    });

    return scoredProducts
        .map((scoredProduct) => scoredProduct.product)
        .toList(growable: false);
  }

  int _scoreProduct({
    required Product product,
    required String normalizedQuery,
    required Set<String> queryTerms,
  }) {
    final name = _normalize(product.name);
    final category = _normalize(product.category);
    final description = _normalize(product.description);
    var score = 0;

    if (name.contains(normalizedQuery)) {
      score += 80;
    }

    if (category == normalizedQuery || category.contains(normalizedQuery)) {
      score += 60;
    }

    if (description.contains(normalizedQuery)) {
      score += 35;
    }

    for (final term in queryTerms) {
      if (name.contains(term)) {
        score += 24;
      }
      if (category.contains(term)) {
        score += 18;
      }
      if (description.contains(term)) {
        score += 10;
      }
    }

    return score;
  }

  Set<String> _queryTermsFor(String normalizedQuery) {
    return {
      ...normalizedQuery
          .split(' ')
          .where((term) => term.length > 2)
          .where((term) => !_ignoredSearchTerms.contains(term)),
      ..._expandedTermsFor(normalizedQuery),
    };
  }

  Set<String> _expandedTermsFor(String normalizedQuery) {
    const relatedTerms = <String, List<String>>{
      'dor cabeca': [
        'dor',
        'dores',
        'analgesico',
        'antitermico',
        'dipirona',
        'paracetamol',
        'ibuprofeno',
        'dorflex',
        'novalgina',
      ],
      'dor': [
        'dor',
        'dores',
        'analgesico',
        'dipirona',
        'paracetamol',
        'ibuprofeno',
      ],
      'febre': [
        'febre',
        'antitermico',
        'dipirona',
        'paracetamol',
        'ibuprofeno',
        'novalgina',
      ],
      'azia': [
        'azia',
        'antiacido',
        'refluxo',
        'estomago',
        'estomacal',
        'queimacao',
        'omeprazol',
        'pantoprazol',
      ],
      'queimacao': [
        'azia',
        'antiacido',
        'refluxo',
        'estomago',
        'estomacal',
        'omeprazol',
        'pantoprazol',
      ],
      'refluxo': [
        'azia',
        'antiacido',
        'refluxo',
        'estomago',
        'estomacal',
        'omeprazol',
        'pantoprazol',
      ],
      'estomago': [
        'estomago',
        'estomacal',
        'antiacido',
        'refluxo',
        'omeprazol',
      ],
      'barriga': ['barriga', 'estomago', 'colica', 'intestinal'],
      'alergia': [
        'alergia',
        'antialergico',
        'loratadina',
        'desloratadina',
        'cetirizina',
        'loratamed',
      ],
      'rinite': [
        'rinite',
        'alergia',
        'antialergico',
        'loratadina',
        'desloratadina',
        'cetirizina',
      ],
      'enjoo': ['enjoo', 'nausea', 'vomito', 'dimenidrinato', 'dramin'],
      'nausea': ['enjoo', 'nausea', 'vomito', 'dimenidrinato', 'dramin'],
      'vomito': ['enjoo', 'nausea', 'vomito', 'dimenidrinato', 'dramin'],
      'colica': ['colica', 'dor', 'analgesico', 'butilbrometo', 'escopolamina'],
      'garganta': ['garganta', 'pastilha', 'spray', 'mel', 'propolis'],
      'tosse': ['tosse', 'xarope', 'expectorante'],
      'diarreia': ['diarreia', 'intestinal', 'soro', 'hidratacao'],
      'prisao ventre': ['intestino', 'laxante', 'constipacao'],
      'constipacao': ['intestino', 'laxante', 'constipacao'],
      'gripe': ['gripe', 'resfriado', 'vitamina', 'imunologico'],
      'resfriado': ['gripe', 'resfriado', 'vitamina', 'imunologico'],
      'pele': ['pele', 'facial', 'hidratante', 'protetor'],
      'sol': ['solar', 'protetor', 'fps'],
      'dente': ['dental', 'dente', 'creme'],
      'higiene': ['higiene', 'limpeza', 'alcool', 'sabonete'],
    };

    final expandedTerms = <String>{};

    for (final entry in relatedTerms.entries) {
      if (normalizedQuery.contains(entry.key)) {
        expandedTerms.addAll(entry.value);
      }
    }

    return expandedTerms;
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp('[\u00e1\u00e0\u00e2\u00e3\u00e4]'), 'a')
        .replaceAll(RegExp('[\u00e9\u00e8\u00ea\u00eb]'), 'e')
        .replaceAll(RegExp('[\u00ed\u00ec\u00ee\u00ef]'), 'i')
        .replaceAll(RegExp('[\u00f3\u00f2\u00f4\u00f5\u00f6]'), 'o')
        .replaceAll(RegExp('[\u00fa\u00f9\u00fb\u00fc]'), 'u')
        .replaceAll('\u00e7', 'c')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  void dispose() {
    _searchAiService.dispose();
    super.dispose();
  }
}

class _ScoredProduct {
  const _ScoredProduct(this.product, this.score);

  final Product product;
  final int score;
}

const _ignoredSearchTerms = <String>{
  'algo',
  'alguma',
  'algum',
  'com',
  'contra',
  'de',
  'do',
  'dos',
  'da',
  'das',
  'em',
  'eu',
  'me',
  'meu',
  'medicamento',
  'medicamentos',
  'minha',
  'na',
  'nas',
  'no',
  'nos',
  'o',
  'os',
  'a',
  'as',
  'ou',
  'para',
  'por',
  'pra',
  'pro',
  'qual',
  'quero',
  'preciso',
  'produto',
  'produtos',
  'remedio',
  'remedinho',
  'remedios',
  'remedrio',
  'tomar',
  'um',
  'uma',
};
