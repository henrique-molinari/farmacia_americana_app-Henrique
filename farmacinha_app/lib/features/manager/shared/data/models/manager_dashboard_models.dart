import 'package:farmacia_app/features/client/orders/data/models/order_model.dart';

class ManagerProductSummary {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String imageUrl;
  final int soldUnits;

  const ManagerProductSummary({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.soldUnits,
  });

  factory ManagerProductSummary.fromMap(
    Map<String, dynamic> map, {
    int soldUnits = 0,
  }) {
    final rawPrice = map['price'];
    final rawStock = map['stock_quantity'];

    return ManagerProductSummary(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      category: (map['category'] ?? 'Geral').toString(),
      price: rawPrice is num
          ? rawPrice.toDouble()
          : double.tryParse(rawPrice?.toString() ?? '0') ?? 0,
      stock: rawStock is num
          ? rawStock.toInt()
          : int.tryParse(rawStock?.toString() ?? '0') ?? 0,
      imageUrl: (map['image_url'] ?? '').toString(),
      soldUnits: soldUnits,
    );
  }

  ManagerProductSummary copyWith({int? soldUnits}) {
    return ManagerProductSummary(
      id: id,
      name: name,
      category: category,
      price: price,
      stock: stock,
      imageUrl: imageUrl,
      soldUnits: soldUnits ?? this.soldUnits,
    );
  }
}

class ManagerOrderSummary {
  final String id;
  final String customerName;
  final String customerEmail;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final double totalAmount;
  final DateTime createdAt;
  final String deliveryAddress;
  final List<OrderItem> items;

  const ManagerOrderSummary({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.status,
    required this.paymentMethod,
    required this.totalAmount,
    required this.createdAt,
    required this.deliveryAddress,
    required this.items,
  });

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:
        return 'PENDENTE';
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        return 'PROCESSANDO';
      case OrderStatus.transit:
        return 'ENVIADO';
      case OrderStatus.delivered:
        return 'ENTREGUE';
      case OrderStatus.cancelled:
        return 'CANCELADO';
    }
  }

  int get itemCount => items.fold(0, (total, item) => total + item.quantity);
}

class ManagerClientSummary {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  const ManagerClientSummary({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });
}

class ManagerChartPoint {
  final String label;
  final double revenue;
  final double orders;

  const ManagerChartPoint({
    required this.label,
    required this.revenue,
    required this.orders,
  });

  Map<String, dynamic> toMap() {
    return {'label': label, 'revenue': revenue, 'orders': orders};
  }
}

class ManagerBillingPeriod {
  final double current;
  final double previous;
  final String label;

  const ManagerBillingPeriod({
    required this.current,
    required this.previous,
    required this.label,
  });
}

class ManagerBiData {
  final Map<String, ManagerBillingPeriod> billingData;
  final Map<String, List<Map<String, dynamic>>> chartData;
  final Map<String, List<Map<String, dynamic>>> topProductsData;

  const ManagerBiData({
    required this.billingData,
    required this.chartData,
    required this.topProductsData,
  });
}

class ManagerDashboardData {
  final List<ManagerOrderSummary> orders;
  final List<ManagerProductSummary> products;
  final int totalClients;
  final int newClientsThisMonth;
  final double currentMonthRevenue;
  final double previousMonthRevenue;
  final List<Map<String, dynamic>> weeklySalesChart;
  final List<Map<String, dynamic>> monthlySalesChart;

  const ManagerDashboardData({
    required this.orders,
    required this.products,
    required this.totalClients,
    required this.newClientsThisMonth,
    required this.currentMonthRevenue,
    required this.previousMonthRevenue,
    required this.weeklySalesChart,
    required this.monthlySalesChart,
  });

  int get pendingOrders => orders
      .where(
        (order) =>
            order.status != OrderStatus.delivered &&
            order.status != OrderStatus.cancelled,
      )
      .length;

  List<ManagerProductSummary> get topProducts {
    final sortedProducts = List<ManagerProductSummary>.from(products)
      ..removeWhere((product) => product.soldUnits <= 0)
      ..sort((a, b) => b.soldUnits.compareTo(a.soldUnits));
    return sortedProducts;
  }

  List<ManagerOrderSummary> get recentOrders => orders.take(5).toList();
}
