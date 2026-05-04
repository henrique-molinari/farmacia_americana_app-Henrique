import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/manager/home_manager/view/widgets/best_sellers.dart';
import 'package:farmacia_app/features/manager/home_manager/view/widgets/kpi_card.dart';
import 'package:farmacia_app/features/manager/home_manager/view/widgets/recent_orders.dart';
import 'package:farmacia_app/features/manager/home_manager/view/widgets/sales_chart.dart';
import 'package:farmacia_app/features/manager/home_manager/view_model/home_manager_view_model.dart';
import 'package:farmacia_app/features/manager/shared/data/models/manager_dashboard_models.dart';
import 'package:farmacia_app/features/manager/shared/data/repositories/manager_dashboard_repository.dart';
import 'package:farmacia_app/features/manager/shared/widgets/notifications_bottom_sheet.dart';
import 'package:flutter/material.dart';

class HomeManagerScreen extends StatefulWidget {
  const HomeManagerScreen({super.key});

  @override
  State<HomeManagerScreen> createState() => _HomeManagerScreenState();
}

class _HomeManagerScreenState extends State<HomeManagerScreen> {
  final HomeManagerViewModel _viewModel = HomeManagerViewModel();
  late Future<ManagerDashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = ManagerDashboardRepository.instance.fetchDashboardData();
  }

  Future<void> _refresh() async {
    final future = ManagerDashboardRepository.instance.fetchDashboardData();
    setState(() => _dashboardFuture = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context),
      body: FutureBuilder<ManagerDashboardData>(
        future: _dashboardFuture,
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

          final data = snapshot.data;
          if (data == null) {
            return _ErrorState(onRetry: _refresh);
          }

          return RefreshIndicator(
            color: Pallete.primaryRed,
            onRefresh: _refresh,
            child: _buildBody(context, data),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Pallete.whiteColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Pallete.borderColor),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Pallete.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Pallete.primaryRed,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FARMACIA AMERICANA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Pallete.primaryRed,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Painel Administrativo',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Pallete.textColor,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: Pallete.textColor,
          ),
          onPressed: () => NotificationsBottomSheet.show(context),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildBody(BuildContext context, ManagerDashboardData data) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_viewModel.greeting}, ${_viewModel.managerName}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Visao consolidada da rede Farmacia Americana hoje.',
            style: TextStyle(fontSize: 13, color: Pallete.textColor),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Relatorio atualizado com os dados do Supabase.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              icon: const Icon(Icons.analytics_rounded, size: 20),
              label: const Text(
                'Gerar Relatorio Estrategico',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallete.primaryRed,
                foregroundColor: Pallete.whiteColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: Pallete.primaryRed.withOpacity(0.3),
              ),
            ),
          ),
          const SizedBox(height: 24),
          KpiCard(
            label: 'Total de Vendas',
            value: _viewModel.totalSales(data),
            trend: _viewModel.totalSalesTrend(data),
            isPositiveTrend: _viewModel.totalSalesPositive(data),
            icon: Icons.payments_rounded,
          ),
          const SizedBox(height: 12),
          KpiCard(
            label: 'Novos Clientes',
            value: _viewModel.newClients(data),
            trend: _viewModel.newClientsTrend,
            isPositiveTrend: true,
            icon: Icons.person_add_rounded,
          ),
          const SizedBox(height: 12),
          KpiCard(
            label: 'Pedidos Pendentes',
            value: _viewModel.pendingOrders(data),
            trend: _viewModel.pendingOrdersNote,
            isPositiveTrend: false,
            icon: Icons.pending_actions_rounded,
          ),
          const SizedBox(height: 24),
          SalesChart(
            dailyData: data.weeklySalesChart,
            monthlyData: data.monthlySalesChart,
          ),
          const SizedBox(height: 24),
          BestSellers(products: data.topProducts),
          const SizedBox(height: 24),
          RecentOrders(orders: data.recentOrders),
          const SizedBox(height: 16),
        ],
      ),
    );
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
              'Nao foi possivel carregar o painel.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Confira as policies do Supabase para gerente e tente novamente.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Pallete.textColor),
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
