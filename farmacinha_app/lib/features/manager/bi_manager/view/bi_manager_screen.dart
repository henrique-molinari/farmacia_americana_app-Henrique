import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/manager/bi_manager/view/widgets/bi_sales_chart.dart';
import 'package:farmacia_app/features/manager/bi_manager/view/widgets/bi_top_products.dart';
import 'package:farmacia_app/features/manager/bi_manager/view/widgets/billing_card.dart';
import 'package:farmacia_app/features/manager/bi_manager/view/widgets/comparison_card.dart';
import 'package:farmacia_app/features/manager/bi_manager/view_model/bi_manager_view_model.dart';
import 'package:farmacia_app/features/manager/shared/data/models/manager_dashboard_models.dart';
import 'package:farmacia_app/features/manager/shared/widgets/notifications_bottom_sheet.dart';
import 'package:flutter/material.dart';

class BiManagerScreen extends StatefulWidget {
  const BiManagerScreen({super.key});

  @override
  State<BiManagerScreen> createState() => _BiManagerScreenState();
}

class _BiManagerScreenState extends State<BiManagerScreen> {
  final _viewModel = BiManagerViewModel();
  late Future<ManagerBiData> _dataFuture;
  String _selectedPeriod = 'Diario';

  @override
  void initState() {
    super.initState();
    _dataFuture = _viewModel.loadData();
  }

  Future<void> _refresh() async {
    final future = _viewModel.loadData();
    setState(() => _dataFuture = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context),
      body: FutureBuilder<ManagerBiData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Pallete.primaryRed),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return _ErrorState(onRetry: _refresh);
          }

          final data = snapshot.data!;
          final billing = data.billingData[_selectedPeriod]!;
          final chartData = data.chartData[_selectedPeriod]!;
          final topProducts = data.topProductsData[_selectedPeriod]!;
          final variation = _viewModel.getVariation(billing);
          final currentProgress = _viewModel.getCurrentProgress(billing);
          final previousProgress = _viewModel.getPreviousProgress(billing);

          return RefreshIndicator(
            color: Pallete.primaryRed,
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Business Intelligence',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _viewModel.updatedAt,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Pallete.textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildPeriodSelector(),
                  const SizedBox(height: 20),
                  BillingCard(
                    currentValue: _viewModel.formatCurrency(billing.current),
                    previousValue: _viewModel.formatCurrency(billing.previous),
                    variation: variation,
                    periodLabel: billing.label,
                  ),
                  const SizedBox(height: 16),
                  BiSalesChart(data: chartData),
                  const SizedBox(height: 16),
                  ComparisonCard(
                    currentProgress: currentProgress,
                    previousProgress: previousProgress,
                    currentLabel: _viewModel.formatCurrency(billing.current),
                    previousLabel: _viewModel.formatCurrency(billing.previous),
                  ),
                  const SizedBox(height: 16),
                  BiTopProducts(products: topProducts),
                  const SizedBox(height: 16),
                ],
              ),
            ),
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
              Icons.bar_chart_rounded,
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

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Pallete.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Pallete.borderColor),
      ),
      child: Row(
        children: _viewModel.periods.map((period) {
          final isSelected = period == _selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Pallete.primaryRed : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    period,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Pallete.whiteColor
                          : Pallete.textColor,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
              'Nao foi possivel carregar o BI.',
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
