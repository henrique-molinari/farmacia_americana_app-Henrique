import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/manager/shared/data/models/manager_dashboard_models.dart';
import 'package:farmacia_app/features/manager/shared/data/repositories/manager_dashboard_repository.dart';
import 'package:flutter/material.dart';

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<ManagerOrderSummary>> _ordersFuture;
  String _searchQuery = '';
  String _selectedStatus = 'Todos';

  final List<String> _statusFilters = const [
    'Todos',
    'PENDENTE',
    'PROCESSANDO',
    'ENVIADO',
    'ENTREGUE',
    'CANCELADO',
  ];

  @override
  void initState() {
    super.initState();
    _ordersFuture = ManagerDashboardRepository.instance.fetchOrders();
  }

  Future<void> _refresh() async {
    final future = ManagerDashboardRepository.instance.fetchOrders();
    setState(() => _ordersFuture = future);
    await future;
  }

  List<ManagerOrderSummary> _filterOrders(List<ManagerOrderSummary> orders) {
    return orders.where((order) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          order.id.toLowerCase().contains(query) ||
          order.customerName.toLowerCase().contains(query);
      final matchesStatus =
          _selectedStatus == 'Todos' || order.statusLabel == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Pallete.whiteColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Historico de Pedidos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Pallete.borderColor),
        ),
      ),
      body: FutureBuilder<List<ManagerOrderSummary>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Pallete.primaryRed),
            );
          }

          if (snapshot.hasError) {
            return _ErrorState(onRetry: _refresh);
          }

          final orders = _filterOrders(snapshot.data ?? []);

          return RefreshIndicator(
            color: Pallete.primaryRed,
            onRefresh: _refresh,
            child: Column(
              children: [
                _buildFilters(),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${orders.length} pedidos',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Pallete.textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: orders.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 160),
                            Center(
                              child: Text(
                                'Nenhum pedido encontrado',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Pallete.textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: orders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            final statusColor = _statusColor(order.statusLabel);

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Pallete.whiteColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Pallete.borderColor),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatDate(order.createdAt),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Pallete.textColor
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            99,
                                          ),
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
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Buscar ID ou Cliente...',
              hintStyle: TextStyle(
                fontSize: 13,
                color: Pallete.textColor.withOpacity(0.6),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Pallete.textColor,
                size: 20,
              ),
              filled: true,
              fillColor: Pallete.whiteColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Pallete.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Pallete.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Pallete.primaryRed,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _statusFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final status = _statusFilters[index];
                final isSelected = status == _selectedStatus;
                return GestureDetector(
                  onTap: () => setState(() => _selectedStatus = status),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Pallete.primaryRed
                          : Pallete.whiteColor,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: isSelected
                            ? Pallete.primaryRed
                            : Pallete.borderColor,
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Pallete.whiteColor
                            : Pallete.textColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year}, $hour:$minute';
  }
}

class _ErrorState extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Pallete.primaryRed,
              size: 42,
            ),
            const SizedBox(height: 12),
            const Text(
              'Nao foi possivel carregar os pedidos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
