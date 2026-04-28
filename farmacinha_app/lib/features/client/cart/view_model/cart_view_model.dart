import 'dart:math' as math;

import 'package:farmacia_app/features/auth/view_models/auth_session_view_model.dart';
import 'package:farmacia_app/features/client/account/data/mocks/mock_delivery_addresses.dart';
import 'package:farmacia_app/features/client/account/data/models/delivery_address_model.dart';
import 'package:farmacia_app/features/client/home_client/data/models/product_model.dart';
import 'package:farmacia_app/features/client/orders/data/models/order_model.dart';
import 'package:farmacia_app/features/client/orders/view_model/orders_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum CartFulfillmentType { delivery, pickup }

class CartViewModel extends ChangeNotifier {
  CartViewModel._();

  static final CartViewModel instance = CartViewModel._();

  final AuthSessionViewModel _authSession = AuthSessionViewModel.instance;
  final OrdersStore _ordersStore = OrdersStore.instance;

  final List<CartItem> _items = <CartItem>[];
  final List<DeliveryAddress> _addresses = MockDeliveryAddresses.getAddresses();

  String? _appliedCouponCode;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cardOnDelivery;
  CartFulfillmentType _selectedFulfillmentType = CartFulfillmentType.delivery;
  String _selectedAddressId = 'home-main';
  bool _isProcessingCheckout = false;
  Order? _lastPlacedOrder;

  List<CartItem> get items => List<CartItem>.unmodifiable(_items);
  List<DeliveryAddress> get addresses => List<DeliveryAddress>.unmodifiable(_addresses);
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;
  bool get isProcessingCheckout => _isProcessingCheckout;
  String? get appliedCouponCode => _appliedCouponCode;
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  CartFulfillmentType get selectedFulfillmentType => _selectedFulfillmentType;
  Order? get lastPlacedOrder => _lastPlacedOrder;

  DeliveryAddress get selectedAddress => _addresses.firstWhere(
        (address) => address.id == _selectedAddressId,
        orElse: () => _addresses.first,
      );

  String get customerName =>
      _authSession.currentUser?.name ?? selectedAddress.recipient;

  String get customerEmail =>
      _authSession.currentUser?.email ?? 'cliente@farmaciaamericana.com';

  int get itemCount =>
      _items.fold<int>(0, (total, item) => total + item.quantity);

  int get uniqueItemCount => _items.length;

  double get subtotal =>
      _items.fold<double>(0, (total, item) => total + item.subtotal);

  double get couponDiscount =>
      _appliedCouponCode == 'PROMO10' ? subtotal * 0.10 : 0;

  double get paymentDiscount {
    if (_selectedPaymentMethod != PaymentMethod.pix) {
      return 0;
    }

    final discountedSubtotal = math.max(0, subtotal - couponDiscount);
    return discountedSubtotal * 0.05;
  }

  double get shippingFee {
    if (_items.isEmpty || _selectedFulfillmentType == CartFulfillmentType.pickup) {
      return 0;
    }

    final discountedSubtotal = math.max(0, subtotal - couponDiscount - paymentDiscount);
    if (discountedSubtotal >= 120) {
      return 0;
    }

    return 8.90;
  }

  double get total =>
      math.max(0, subtotal - couponDiscount - paymentDiscount + shippingFee);

  String get shippingLabel {
    if (_selectedFulfillmentType == CartFulfillmentType.pickup) {
      return 'Retirada grátis';
    }

    return shippingFee == 0 ? 'Grátis' : _formatCurrency(shippingFee);
  }

  String get deliveryModeLabel =>
      _selectedFulfillmentType == CartFulfillmentType.delivery
          ? 'Entrega'
          : 'Retirada na farmácia';

  String get storePickupLabel => 'Drogaria Americana Paulista';

  String get storePickupAddress =>
      'Avenida Paulista, 1500 - Bela Vista, São Paulo - SP';

  void addProduct(Product product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.productId == product.id);
    final effectivePrice = _resolveProductPrice(product);
    final subtitle = _buildProductSubtitle(product);

    if (existingIndex >= 0) {
      final existingItem = _items[existingIndex];
      _items[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      _items.add(
        CartItem(
          productId: product.id,
          name: product.name,
          subtitle: subtitle,
          imageUrl: product.imageUrl,
          unitPrice: effectivePrice,
          originalUnitPrice: product.price,
          quantity: quantity,
        ),
      );
    }

    notifyListeners();
  }

  void addCustomItem({
    required String productId,
    required String name,
    required String subtitle,
    required String imageUrl,
    required double unitPrice,
    double? originalUnitPrice,
    int quantity = 1,
  }) {
    final existingIndex = _items.indexWhere((item) => item.productId == productId);

    if (existingIndex >= 0) {
      final existingItem = _items[existingIndex];
      _items[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      _items.add(
        CartItem(
          productId: productId,
          name: name,
          subtitle: subtitle,
          imageUrl: imageUrl,
          unitPrice: unitPrice,
          originalUnitPrice: originalUnitPrice ?? unitPrice,
          quantity: quantity,
        ),
      );
    }

    notifyListeners();
  }

  void incrementItem(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index < 0) {
      return;
    }

    final item = _items[index];
    _items[index] = item.copyWith(quantity: item.quantity + 1);
    notifyListeners();
  }

  void decrementItem(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index < 0) {
      return;
    }

    final item = _items[index];
    if (item.quantity <= 1) {
      _items.removeAt(index);
    } else {
      _items[index] = item.copyWith(quantity: item.quantity - 1);
    }

    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _appliedCouponCode = null;
    notifyListeners();
  }

  String applyCoupon(String rawCode) {
    final normalizedCode = rawCode.trim().toUpperCase();

    if (normalizedCode.isEmpty) {
      return 'Digite um cupom para aplicar.';
    }

    if (normalizedCode == 'PROMO10') {
      _appliedCouponCode = normalizedCode;
      notifyListeners();
      return 'Cupom PROMO10 aplicado com sucesso.';
    }

    return 'Cupom inválido. Tente usar PROMO10.';
  }

  void removeCoupon() {
    _appliedCouponCode = null;
    notifyListeners();
  }

  void selectPaymentMethod(PaymentMethod method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void selectFulfillmentType(CartFulfillmentType type) {
    _selectedFulfillmentType = type;
    notifyListeners();
  }

  void selectAddress(String addressId) {
    _selectedAddressId = addressId;
    notifyListeners();
  }

  Future<Order?> checkout() async {
    if (_items.isEmpty || _isProcessingCheckout) {
      return null;
    }

    _isProcessingCheckout = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 700));

    final now = DateTime.now();
    final order = Order(
      id: _buildOrderId(now),
      userId: _authSession.currentUser?.id ?? 'guest',
      items: _items
          .map(
            (item) => OrderItem(
              productId: item.productId,
              productName: item.name,
              productImageUrl: item.imageUrl,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
            ),
          )
          .toList(growable: false),
      status: OrderStatus.preparing,
      paymentMethod: _selectedPaymentMethod,
      totalAmount: total,
      deliveryAddress: _selectedFulfillmentType == CartFulfillmentType.delivery
          ? selectedAddress.singleLineAddress
          : storePickupAddress,
      createdAt: now,
      estimatedDelivery: _selectedFulfillmentType == CartFulfillmentType.delivery
          ? now.add(const Duration(minutes: 35))
          : now.add(const Duration(minutes: 20)),
      trackingCode: 'BR${now.millisecondsSinceEpoch.toString().substring(6)}',
    );

    _ordersStore.addOrder(order);
    _lastPlacedOrder = order;
    _items.clear();
    _appliedCouponCode = null;
    _isProcessingCheckout = false;
    notifyListeners();
    return order;
  }

  static double resolvePrice(Product product) => _resolveProductPrice(product);

  static String formatCurrency(double value) => _formatCurrency(value);

  static String _buildProductSubtitle(Product product) {
    final sentence = product.description.split('.').first.trim();
    if (sentence.isEmpty) {
      return product.category;
    }
    return sentence;
  }

  static double _resolveProductPrice(Product product) {
    if (!product.isOnPromotion || product.discountPercentage == null) {
      return product.price;
    }

    return product.price * (1 - product.discountPercentage! / 100);
  }

  static String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _buildOrderId(DateTime now) {
    final year = now.year;
    final sequence = now.millisecondsSinceEpoch.toString().substring(7);
    return 'PED-$year-$sequence';
  }
}

class CartItem {
  final String productId;
  final String name;
  final String subtitle;
  final String imageUrl;
  final double unitPrice;
  final double originalUnitPrice;
  final int quantity;

  const CartItem({
    required this.productId,
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    required this.unitPrice,
    required this.originalUnitPrice,
    required this.quantity,
  });

  double get subtotal => unitPrice * quantity;

  CartItem copyWith({
    String? productId,
    String? name,
    String? subtitle,
    String? imageUrl,
    double? unitPrice,
    double? originalUnitPrice,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      unitPrice: unitPrice ?? this.unitPrice,
      originalUnitPrice: originalUnitPrice ?? this.originalUnitPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}
