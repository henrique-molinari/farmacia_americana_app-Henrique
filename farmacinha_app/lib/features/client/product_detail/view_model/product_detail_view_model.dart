import 'package:flutter/material.dart';
import 'package:farmacia_app/app/app_routes.dart';
import 'package:farmacia_app/features/auth/view_models/auth_session_view_model.dart';
import 'package:farmacia_app/features/client/cart/view_model/cart_view_model.dart';
import 'package:farmacia_app/features/client/home_client/data/models/product_model.dart';

class ProductDetailViewModel extends ChangeNotifier {
  final AuthSessionViewModel _authSession;
  final Product product;
  bool _isAdding = false;

  ProductDetailViewModel({
    required this.product,
    AuthSessionViewModel? authSession,
  }) : _authSession = authSession ?? AuthSessionViewModel.instance;

  bool get isAdding => _isAdding;

  Future<void> addToCart(BuildContext context) async {
    if (!_authSession.requireAuthentication(
      context,
      message: 'Entre com sua conta para adicionar este produto ao carrinho.',
    )) {
      return;
    }

    if (_isAdding) return;

    _isAdding = true;
    notifyListeners();

    // Simula uma pequena espera de envio.
    await Future.delayed(const Duration(milliseconds: 500));

    CartViewModel.instance.addProduct(product);

    _isAdding = false;
    notifyListeners();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${product.name} adicionado ao carrinho.')),
      );
  }

  void buyNow(BuildContext context) {
    if (!_authSession.requireAuthentication(
      context,
      message: 'Entre com sua conta para comprar este produto.',
    )) {
      return;
    }

    CartViewModel.instance.addProduct(product);
    Navigator.of(context).pushNamed(AppRoutes.cart);
  }
}
