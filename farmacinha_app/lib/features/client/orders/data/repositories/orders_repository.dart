import 'package:farmacia_app/features/client/orders/data/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdersRepository {
  OrdersRepository._();

  static final OrdersRepository instance = OrdersRepository._();

  SupabaseClient get _client => Supabase.instance.client;

  Future<List<Order>> fetchCurrentUserOrders() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      return [];
    }

    final response = await _client
        .from('orders')
        .select(
          'id, user_id, status, payment_method, total_amount, delivery_address, created_at, order_items(product_id, product_name, unit_price, quantity, products(image_url))',
        )
        .eq('user_id', authUser.id)
        .order('created_at', ascending: false);

    return response
        .map<Order>((order) => Order.fromSupabaseMap(order))
        .toList(growable: false);
  }

  Future<Order> createOrder({
    required List<OrderItem> items,
    required PaymentMethod paymentMethod,
    required double totalAmount,
    required String deliveryAddress,
    required DateTime estimatedDelivery,
    required String trackingCode,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw Exception('Entre com sua conta para finalizar o pedido.');
    }

    final itemPayload = _buildOrderItemsPayload(items);

    try {
      final order = await _client.rpc(
        'create_order_with_stock',
        params: {
          'p_items': itemPayload,
          'p_payment_method': paymentMethod.databaseValue,
          'p_total_amount': totalAmount,
          'p_delivery_address': deliveryAddress,
        },
      );

      return Order.fromSupabaseMap(
        Map<String, dynamic>.from(order as Map),
        estimatedDelivery: estimatedDelivery,
        trackingCode: trackingCode,
      );
    } on PostgrestException catch (error) {
      throw Exception(_formatCreateOrderError(error));
    }
  }

  List<Map<String, dynamic>> _buildOrderItemsPayload(List<OrderItem> items) {
    return items
        .map((item) {
          final productId = int.tryParse(item.productId);
          if (productId == null) {
            throw Exception(
              'O produto "${item.productName}" precisa estar cadastrado no Supabase antes de finalizar o pedido.',
            );
          }

          return {
            'product_id': productId,
            'product_name': item.productName,
            'unit_price': item.unitPrice,
            'quantity': item.quantity,
          };
        })
        .toList(growable: false);
  }

  String _formatCreateOrderError(PostgrestException error) {
    final message = error.message;

    if (message.contains('Could not find the function') ||
        message.contains('create_order_with_stock')) {
      return 'A funcao de pedido com estoque ainda nao foi criada no Supabase. Rode o SQL docs/supabase/supabase_order_stock.sql.';
    }

    if (message.contains('Estoque insuficiente')) {
      return message;
    }

    if (message.contains('row-level security')) {
      return 'O Supabase bloqueou a operacao por RLS. Confira as policies e a funcao create_order_with_stock.';
    }

    return 'Nao foi possivel finalizar o pedido. Detalhe: $message';
  }
}
