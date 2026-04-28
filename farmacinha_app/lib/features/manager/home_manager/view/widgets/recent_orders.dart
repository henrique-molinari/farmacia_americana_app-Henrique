import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/manager/home_manager/view/orders_history_screen.dart';
import 'package:farmacia_app/features/manager/shared/data/models/manager_dashboard_models.dart';
import 'package:flutter/material.dart';

class RecentOrders extends StatefulWidget {
  final List<ManagerOrderSummary> orders;

  const RecentOrders({super.key, required this.orders});

  @override
  State<RecentOrders> createState() => _RecentOrdersState();
}

class _RecentOrdersState extends State<RecentOrders> {
  final TextEditingController _searchController = TextEditingController();

  List<ManagerOrderSummary> get _filteredOrders {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return widget.orders;
    return widget.orders.where((order) {
      return order.id.toLowerCase().contains(query) ||
          order.customerName.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filteredOrders;

    return Container(
      decoration: BoxDecoration(
        color: Pallete.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Pallete.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pedidos Recentes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Buscar ID ou Cliente...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Pallete.textColor.withOpacity(0.6),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Pallete.textColor,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Pallete.grayColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Pallete.borderColor),
          if (orders.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Nenhum pedido encontrado',
                  style: TextStyle(
                    color: Pallete.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            ...orders.map((order) => _OrderItem(order: order)),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrdersHistoryScreen()),
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                color: Pallete.grayColor,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: const Center(
                child: Text(
                  'Ver Historico Completo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Pallete.primaryRed,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  final ManagerOrderSummary order;

  const _OrderItem({required this.order});

  Color _statusColor(String status) {
    switch (status) {
      case 'ENVIADO':
      case 'ENTREGUE':
        return const Color(0xFF10B981);
      case 'PROCESSANDO':
        return const Color(0xFFFAC000);
      case 'CANCELADO':
        return Pallete.primaryRed;
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.statusLabel);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Pallete.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.id.replaceFirst('PED-', '#'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Pallete.primaryRed,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order.customerName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  order.statusLabel,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'R\$ ${order.totalAmount.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
