import 'package:farmacia_app/core/utils/date_time_utils.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  transit,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  static OrderStatus fromDatabaseValue(String? value) {
    switch (value) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'transit':
        return OrderStatus.transit;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }

  String get databaseValue {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.preparing:
        return 'preparing';
      case OrderStatus.transit:
        return 'transit';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Aguardando confirmação';
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.preparing:
        return 'Em preparo';
      case OrderStatus.transit:
        return 'Em trânsito';
      case OrderStatus.delivered:
        return 'Entregue';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  bool get isActive =>
      this != OrderStatus.delivered && this != OrderStatus.cancelled;
}

enum PaymentMethod { pix, cashOnDelivery, cardOnDelivery }

extension PaymentMethodExtension on PaymentMethod {
  static PaymentMethod fromDatabaseValue(String? value) {
    switch (value) {
      case 'pix':
        return PaymentMethod.pix;
      case 'cash_on_delivery':
        return PaymentMethod.cashOnDelivery;
      case 'card_on_delivery':
      default:
        return PaymentMethod.cardOnDelivery;
    }
  }

  String get databaseValue {
    switch (this) {
      case PaymentMethod.pix:
        return 'pix';
      case PaymentMethod.cashOnDelivery:
        return 'cash_on_delivery';
      case PaymentMethod.cardOnDelivery:
        return 'card_on_delivery';
    }
  }

  String get label {
    switch (this) {
      case PaymentMethod.pix:
        return 'Pix';
      case PaymentMethod.cashOnDelivery:
        return 'Dinheiro';
      case PaymentMethod.cardOnDelivery:
        return 'Cartão de Crédito';
    }
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImageUrl;
  final int quantity;
  final double unitPrice;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItem.fromSupabaseMap(Map<String, dynamic> map) {
    final rawPrice = map['unit_price'];
    final parsedPrice = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '0') ?? 0;
    final product = map['products'] is Map<String, dynamic>
        ? map['products'] as Map<String, dynamic>
        : <String, dynamic>{};

    return OrderItem(
      productId: (map['product_id'] ?? '').toString(),
      productName: (map['product_name'] ?? '').toString(),
      productImageUrl: (map['product_image_url'] ?? product['image_url'] ?? '')
          .toString(),
      quantity: map['quantity'] is num
          ? (map['quantity'] as num).toInt()
          : int.tryParse(map['quantity']?.toString() ?? '1') ?? 1,
      unitPrice: parsedPrice,
    );
  }

  double get subtotal => unitPrice * quantity;
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final double totalAmount;
  final String deliveryAddress;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final String? trackingCode;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.status,
    required this.paymentMethod,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.createdAt,
    this.estimatedDelivery,
    this.trackingCode,
  });

  factory Order.fromSupabaseMap(
    Map<String, dynamic> map, {
    DateTime? estimatedDelivery,
    String? trackingCode,
  }) {
    final rawTotal = map['total_amount'];
    final parsedTotal = rawTotal is num
        ? rawTotal.toDouble()
        : double.tryParse(rawTotal?.toString() ?? '0') ?? 0;
    final rawItems = map['order_items'];
    final parsedItems = rawItems is List
        ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(OrderItem.fromSupabaseMap)
              .toList(growable: false)
        : <OrderItem>[];
    final createdAt =
        tryParseUtcToLocal(map['created_at']?.toString()) ?? DateTime.now();

    return Order(
      id: _formatOrderId(map['id'], createdAt),
      userId: (map['user_id'] ?? '').toString(),
      items: parsedItems,
      status: OrderStatusExtension.fromDatabaseValue(map['status']?.toString()),
      paymentMethod: PaymentMethodExtension.fromDatabaseValue(
        map['payment_method']?.toString(),
      ),
      totalAmount: parsedTotal,
      deliveryAddress: (map['delivery_address'] ?? '').toString(),
      createdAt: createdAt,
      estimatedDelivery: estimatedDelivery,
      trackingCode: trackingCode,
    );
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  static String _formatOrderId(Object? id, DateTime createdAt) {
    final sequence = id?.toString().padLeft(4, '0') ?? '0000';
    return 'PED-${createdAt.year}-$sequence';
  }
}
