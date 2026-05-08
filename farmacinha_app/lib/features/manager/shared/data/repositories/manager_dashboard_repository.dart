import 'dart:math' as math;

import 'package:farmacia_app/core/utils/date_time_utils.dart';
import 'package:farmacia_app/features/auth/data/models/user_model.dart';
import 'package:farmacia_app/features/client/orders/data/models/order_model.dart';
import 'package:farmacia_app/features/manager/shared/data/models/manager_dashboard_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManagerDashboardRepository {
  ManagerDashboardRepository._();

  static final ManagerDashboardRepository instance =
      ManagerDashboardRepository._();

  SupabaseClient get _client => Supabase.instance.client;

  Future<ManagerDashboardData> fetchDashboardData() async {
    final orders = await fetchOrders();
    final soldByProductId = _soldUnitsByProductId(orders);
    final products = await _fetchProductsSafely(
      soldByProductId: soldByProductId,
    );
    final clientStats = await _fetchClientStats();
    final now = DateTime.now();

    return ManagerDashboardData(
      orders: orders,
      products: products,
      totalClients: clientStats.totalClients,
      newClientsThisMonth: clientStats.newClientsThisMonth,
      currentMonthRevenue: _revenueBetween(
        orders,
        DateTime(now.year, now.month),
        DateTime(now.year, now.month + 1),
      ),
      previousMonthRevenue: _revenueBetween(
        orders,
        DateTime(now.year, now.month - 1),
        DateTime(now.year, now.month),
      ),
      weeklySalesChart: _buildWeeklyChart(orders),
      monthlySalesChart: _buildMonthlyChart(orders),
    );
  }

  Future<List<ManagerProductSummary>> fetchProducts({
    Map<String, int> soldByProductId = const {},
  }) async {
    final response = await _client.from('products').select().order('name');

    return response
        .map<ManagerProductSummary>((product) {
          final map = product;
          final id = (map['id'] ?? '').toString();
          return ManagerProductSummary.fromMap(
            map,
            soldUnits: soldByProductId[id] ?? 0,
          );
        })
        .toList(growable: false);
  }

  Future<List<ManagerOrderSummary>> fetchOrders() async {
    final response = await _client
        .from('orders')
        .select(
          'id, user_id, status, payment_method, total_amount, delivery_address, created_at',
        )
        .order('created_at', ascending: false);

    final orders = response.whereType<Map<String, dynamic>>().toList(
      growable: false,
    );
    final profilesByUserId = await _fetchProfilesByUserId(orders);
    final itemsByOrderId = await _fetchOrderItemsByOrderId(orders);

    return orders
        .map<ManagerOrderSummary>((order) {
          final userId = order['user_id']?.toString() ?? '';
          return _orderSummaryFromMap(
            order,
            profile: profilesByUserId[userId],
            items:
                itemsByOrderId[order['id']?.toString()] ?? const <OrderItem>[],
          );
        })
        .toList(growable: false);
  }

  Future<ManagerOrderSummary?> fetchOrderByRawId(Object? orderId) async {
    if (orderId == null || orderId.toString().trim().isEmpty) {
      return null;
    }

    final response = await _client
        .from('orders')
        .select(
          'id, user_id, status, payment_method, total_amount, delivery_address, created_at',
        )
        .eq('id', orderId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final order = Map<String, dynamic>.from(response);
    final profilesByUserId = await _fetchProfilesByUserId([order]);
    final itemsByOrderId = await _fetchOrderItemsByOrderId([order]);
    final userId = order['user_id']?.toString() ?? '';

    return _orderSummaryFromMap(
      order,
      profile: profilesByUserId[userId],
      items: itemsByOrderId[order['id']?.toString()] ?? const <OrderItem>[],
    );
  }

  Future<List<ManagerClientSummary>> fetchRecentClients({int limit = 5}) async {
    final response = await _client
        .from('profiles')
        .select('id, full_name, email, created_at')
        .eq('role', UserRole.cliente.name)
        .order('created_at', ascending: false)
        .limit(limit);

    return response
        .whereType<Map<String, dynamic>>()
        .map((profile) {
          final createdAt =
              tryParseUtcToLocal(profile['created_at']?.toString()) ??
              DateTime.now();

          return ManagerClientSummary(
            id: (profile['id'] ?? '').toString(),
            name: _resolveCustomerName(profile, profile['id']),
            email: (profile['email'] ?? '').toString(),
            createdAt: createdAt,
          );
        })
        .toList(growable: false);
  }

  Future<List<ManagerProductSummary>> _fetchProductsSafely({
    required Map<String, int> soldByProductId,
  }) async {
    try {
      return await fetchProducts(soldByProductId: soldByProductId);
    } catch (_) {
      return const <ManagerProductSummary>[];
    }
  }

  Future<Map<String, Map<String, dynamic>>> _fetchProfilesByUserId(
    List<Map<String, dynamic>> orders,
  ) async {
    final userIds = orders
        .map((order) => order['user_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (userIds.isEmpty) {
      return const <String, Map<String, dynamic>>{};
    }

    try {
      final response = await _client
          .from('profiles')
          .select('id, full_name, email')
          .inFilter('id', userIds);

      final result = <String, Map<String, dynamic>>{};
      for (final profile in response.whereType<Map<String, dynamic>>()) {
        final id = profile['id']?.toString() ?? '';
        if (id.isEmpty) {
          continue;
        }
        result[id] = profile;
      }
      return result;
    } catch (_) {
      return const <String, Map<String, dynamic>>{};
    }
  }

  Future<Map<String, List<OrderItem>>> _fetchOrderItemsByOrderId(
    List<Map<String, dynamic>> orders,
  ) async {
    final orderIds = orders
        .map((order) => order['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (orderIds.isEmpty) {
      return const <String, List<OrderItem>>{};
    }

    try {
      final response = await _client
          .from('order_items')
          .select('order_id, product_id, product_name, unit_price, quantity')
          .inFilter('order_id', orderIds);

      final result = <String, List<OrderItem>>{};
      for (final item in response.whereType<Map<String, dynamic>>()) {
        final orderId = item['order_id']?.toString() ?? '';
        if (orderId.isEmpty) {
          continue;
        }
        result
            .putIfAbsent(orderId, () => <OrderItem>[])
            .add(OrderItem.fromSupabaseMap(item));
      }
      return result;
    } catch (_) {
      return const <String, List<OrderItem>>{};
    }
  }

  ManagerOrderSummary _orderSummaryFromMap(
    Map<String, dynamic> map, {
    Map<String, dynamic>? profile,
    List<OrderItem> items = const <OrderItem>[],
  }) {
    final resolvedProfile = profile ?? const <String, dynamic>{};
    final createdAt =
        tryParseUtcToLocal(map['created_at']?.toString()) ?? DateTime.now();
    final rawTotal = map['total_amount'];

    return ManagerOrderSummary(
      id: _formatOrderId(map['id'], createdAt),
      customerName: _resolveCustomerName(resolvedProfile, map['user_id']),
      customerEmail: (resolvedProfile['email'] ?? '').toString(),
      status: OrderStatusExtension.fromDatabaseValue(map['status']?.toString()),
      paymentMethod: PaymentMethodExtension.fromDatabaseValue(
        map['payment_method']?.toString(),
      ),
      totalAmount: rawTotal is num
          ? rawTotal.toDouble()
          : double.tryParse(rawTotal?.toString() ?? '0') ?? 0,
      createdAt: createdAt,
      deliveryAddress: (map['delivery_address'] ?? '').toString(),
      items: items,
    );
  }

  Future<ManagerBiData> fetchBiData() async {
    final orders = await fetchOrders();

    return ManagerBiData(
      billingData: {
        'Diario': _periodBilling(orders, _PeriodType.daily),
        'Semanal': _periodBilling(orders, _PeriodType.weekly),
        'Mensal': _periodBilling(orders, _PeriodType.monthly),
      },
      chartData: {
        'Diario': _buildDailyChart(orders),
        'Semanal': _buildWeeklyChart(orders),
        'Mensal': _buildMonthlyChart(orders),
      },
      topProductsData: {
        'Diario': _topProductsForPeriod(orders, _PeriodType.daily),
        'Semanal': _topProductsForPeriod(orders, _PeriodType.weekly),
        'Mensal': _topProductsForPeriod(orders, _PeriodType.monthly),
      },
    );
  }

  String _resolveCustomerName(Map<String, dynamic> profile, Object? userId) {
    final name = (profile['full_name'] ?? '').toString().trim();
    if (name.isNotEmpty) {
      return name;
    }

    final email = (profile['email'] ?? '').toString().trim();
    if (email.isNotEmpty) {
      return email;
    }

    final fallbackId = userId?.toString() ?? '';
    if (fallbackId.length > 8) {
      return 'Cliente ${fallbackId.substring(0, 8)}';
    }

    return 'Cliente';
  }

  Future<_ClientStats> _fetchClientStats() async {
    try {
      final response = await _client
          .from('profiles')
          .select('id, role, created_at')
          .eq('role', UserRole.cliente.name);
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month);
      final clients = response.whereType<Map<String, dynamic>>().toList();
      final newClientsThisMonth = clients.where((client) {
        final createdAt = tryParseUtcToLocal(client['created_at']?.toString());
        return createdAt != null && !createdAt.isBefore(monthStart);
      }).length;

      return _ClientStats(
        totalClients: clients.length,
        newClientsThisMonth: newClientsThisMonth,
      );
    } catch (_) {
      return const _ClientStats(totalClients: 0, newClientsThisMonth: 0);
    }
  }

  Map<String, int> _soldUnitsByProductId(List<ManagerOrderSummary> orders) {
    final result = <String, int>{};
    for (final order in orders.where(_shouldCountOrder)) {
      for (final item in order.items) {
        result[item.productId] = (result[item.productId] ?? 0) + item.quantity;
      }
    }
    return result;
  }

  double _revenueBetween(
    List<ManagerOrderSummary> orders,
    DateTime start,
    DateTime end,
  ) {
    return orders
        .where((order) {
          return _shouldCountOrder(order) &&
              !order.createdAt.isBefore(start) &&
              order.createdAt.isBefore(end);
        })
        .fold<double>(0, (total, order) => total + order.totalAmount);
  }

  List<Map<String, dynamic>> _buildDailyChart(
    List<ManagerOrderSummary> orders,
  ) {
    const labels = ['08h', '10h', '12h', '14h', '16h', '18h', '20h'];
    final revenue = List<double>.filled(labels.length, 0);
    final counts = List<int>.filled(labels.length, 0);
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    for (final order in orders.where(_shouldCountOrder)) {
      if (order.createdAt.isBefore(todayStart) ||
          !order.createdAt.isBefore(tomorrowStart)) {
        continue;
      }

      final index = ((order.createdAt.hour - 8) / 2)
          .floor()
          .clamp(0, 6)
          .toInt();
      revenue[index] += order.totalAmount;
      counts[index] += 1;
    }

    return _normalizeChart(labels, revenue, counts);
  }

  List<Map<String, dynamic>> _buildWeeklyChart(
    List<ManagerOrderSummary> orders,
  ) {
    const labels = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB', 'DOM'];
    final revenue = List<double>.filled(labels.length, 0);
    final counts = List<int>.filled(labels.length, 0);
    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final nextWeekStart = weekStart.add(const Duration(days: 7));

    for (final order in orders.where(_shouldCountOrder)) {
      if (order.createdAt.isBefore(weekStart) ||
          !order.createdAt.isBefore(nextWeekStart)) {
        continue;
      }

      final index = order.createdAt.weekday - 1;
      revenue[index] += order.totalAmount;
      counts[index] += 1;
    }

    return _normalizeChart(labels, revenue, counts);
  }

  List<Map<String, dynamic>> _buildMonthlyChart(
    List<ManagerOrderSummary> orders,
  ) {
    final now = DateTime.now();
    final months = List<DateTime>.generate(
      7,
      (index) => DateTime(now.year, now.month - (6 - index)),
    );
    final labels = months.map((month) => _monthLabel(month.month)).toList();
    final revenue = List<double>.filled(labels.length, 0);
    final counts = List<int>.filled(labels.length, 0);

    for (final order in orders.where(_shouldCountOrder)) {
      final index = months.indexWhere(
        (month) =>
            month.year == order.createdAt.year &&
            month.month == order.createdAt.month,
      );
      if (index < 0) {
        continue;
      }

      revenue[index] += order.totalAmount;
      counts[index] += 1;
    }

    return _normalizeChart(labels, revenue, counts);
  }

  List<Map<String, dynamic>> _normalizeChart(
    List<String> labels,
    List<double> revenue,
    List<int> counts,
  ) {
    final maxRevenue = revenue.fold<double>(0, math.max);
    final maxOrders = counts.fold<int>(0, math.max);

    return List<Map<String, dynamic>>.generate(labels.length, (index) {
      return {
        'label': labels[index],
        'revenue': maxRevenue == 0 ? 0.08 : revenue[index] / maxRevenue,
        'orders': maxOrders == 0 ? 0.08 : counts[index] / maxOrders,
      };
    });
  }

  ManagerBillingPeriod _periodBilling(
    List<ManagerOrderSummary> orders,
    _PeriodType type,
  ) {
    final now = DateTime.now();
    late DateTime currentStart;
    late DateTime currentEnd;
    late DateTime previousStart;
    late DateTime previousEnd;
    late String label;

    switch (type) {
      case _PeriodType.daily:
        currentStart = DateTime(now.year, now.month, now.day);
        currentEnd = currentStart.add(const Duration(days: 1));
        previousStart = currentStart.subtract(const Duration(days: 1));
        previousEnd = currentStart;
        label = 'vs. ontem';
        break;
      case _PeriodType.weekly:
        currentStart = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        currentEnd = currentStart.add(const Duration(days: 7));
        previousStart = currentStart.subtract(const Duration(days: 7));
        previousEnd = currentStart;
        label = 'vs. semana anterior';
        break;
      case _PeriodType.monthly:
        currentStart = DateTime(now.year, now.month);
        currentEnd = DateTime(now.year, now.month + 1);
        previousStart = DateTime(now.year, now.month - 1);
        previousEnd = currentStart;
        label = 'vs. mes anterior';
        break;
    }

    return ManagerBillingPeriod(
      current: _revenueBetween(orders, currentStart, currentEnd),
      previous: _revenueBetween(orders, previousStart, previousEnd),
      label: label,
    );
  }

  List<Map<String, dynamic>> _topProductsForPeriod(
    List<ManagerOrderSummary> orders,
    _PeriodType type,
  ) {
    final now = DateTime.now();
    late DateTime start;
    late DateTime end;

    switch (type) {
      case _PeriodType.daily:
        start = DateTime(now.year, now.month, now.day);
        end = start.add(const Duration(days: 1));
        break;
      case _PeriodType.weekly:
        start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        end = start.add(const Duration(days: 7));
        break;
      case _PeriodType.monthly:
        start = DateTime(now.year, now.month);
        end = DateTime(now.year, now.month + 1);
        break;
    }

    final sold = <String, _SoldProduct>{};
    for (final order in orders.where(_shouldCountOrder)) {
      if (order.createdAt.isBefore(start) || !order.createdAt.isBefore(end)) {
        continue;
      }

      for (final item in order.items) {
        final current = sold[item.productId];
        sold[item.productId] = _SoldProduct(
          name: item.productName,
          units: (current?.units ?? 0) + item.quantity,
        );
      }
    }

    final sorted = sold.values.toList()
      ..sort((a, b) => b.units.compareTo(a.units));
    final max = sorted.isEmpty ? 1 : sorted.first.units;

    return sorted
        .take(5)
        .map((product) {
          return {'name': product.name, 'units': product.units, 'max': max};
        })
        .toList(growable: false);
  }

  bool _shouldCountOrder(ManagerOrderSummary order) {
    return order.status != OrderStatus.cancelled;
  }

  String _formatOrderId(Object? id, DateTime createdAt) {
    final sequence = id?.toString().padLeft(4, '0') ?? '0000';
    return 'PED-${createdAt.year}-$sequence';
  }

  String _monthLabel(int month) {
    const labels = [
      'JAN',
      'FEV',
      'MAR',
      'ABR',
      'MAI',
      'JUN',
      'JUL',
      'AGO',
      'SET',
      'OUT',
      'NOV',
      'DEZ',
    ];
    return labels[month - 1];
  }
}

class _ClientStats {
  final int totalClients;
  final int newClientsThisMonth;

  const _ClientStats({
    required this.totalClients,
    required this.newClientsThisMonth,
  });
}

class _SoldProduct {
  final String name;
  final int units;

  const _SoldProduct({required this.name, required this.units});
}

enum _PeriodType { daily, weekly, monthly }
