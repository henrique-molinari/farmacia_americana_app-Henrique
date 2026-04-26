import 'package:farmacia_app/features/auth/view_models/auth_session_view_model.dart';
import 'package:farmacia_app/features/client/cart/view_model/cart_view_model.dart';
import 'package:farmacia_app/features/client/home_client/data/models/product_model.dart';
import 'package:farmacia_app/features/client/home_client/data/repositories/products_repository.dart';
import 'package:flutter/material.dart';

class SearchResultViewModel extends ChangeNotifier {
  SearchResultViewModel({
    String? initialQuery,
    AuthSessionViewModel? authSession,
  }) : _authSession = authSession ?? AuthSessionViewModel.instance {
    if (initialQuery != null && initialQuery.isNotEmpty) {
      search(initialQuery);
    }
  }

  final AuthSessionViewModel _authSession;
  List<Product> filteredProducts = [];
  List<Product> similarProducts = [];
  String searchQuery = '';
  bool isLoading = false;

  Future<void> search(String query) async {
    isLoading = true;
    searchQuery = query;
    notifyListeners();

    try {
      final allProducts = await ProductsRepository.instance
          .fetchActiveProducts();

      filteredProducts = allProducts.where((product) {
        final normalizedQuery = query.toLowerCase();
        final matchesName = product.name.toLowerCase().contains(
          normalizedQuery,
        );
        final matchesCategory =
            product.category.toLowerCase() == normalizedQuery;
        return matchesName || matchesCategory;
      }).toList();

      if (filteredProducts.isNotEmpty) {
        final category = filteredProducts.first.category;
        similarProducts = allProducts.where((product) {
          return product.category == category &&
              !filteredProducts.any((filtered) => filtered.id == product.id);
        }).toList();
      } else {
        similarProducts = [];
      }
    } catch (error) {
      debugPrint('Erro ao buscar produtos no Supabase: $error');
      filteredProducts = [];
      similarProducts = [];
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
}
