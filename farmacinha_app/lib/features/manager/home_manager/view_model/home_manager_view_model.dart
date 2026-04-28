import 'package:farmacia_app/features/auth/view_models/auth_session_view_model.dart';
import 'package:farmacia_app/features/manager/shared/data/models/manager_dashboard_models.dart';

class HomeManagerViewModel {
  String get managerName {
    final name = AuthSessionViewModel.instance.currentUser?.name.trim();
    if (name == null || name.isEmpty) {
      return 'Gerente';
    }
    return name.split(' ').first;
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  String totalSales(ManagerDashboardData data) {
    return formatCurrency(data.currentMonthRevenue);
  }

  String totalSalesTrend(ManagerDashboardData data) {
    final variation = _variation(
      current: data.currentMonthRevenue,
      previous: data.previousMonthRevenue,
    );
    final prefix = variation >= 0 ? '+' : '';
    return '$prefix${variation.toStringAsFixed(1)}% vs mes anterior';
  }

  bool totalSalesPositive(ManagerDashboardData data) {
    return data.currentMonthRevenue >= data.previousMonthRevenue;
  }

  String newClients(ManagerDashboardData data) {
    return data.newClientsThisMonth.toString();
  }

  String get newClientsTrend => 'Novos clientes este mes';

  String pendingOrders(ManagerDashboardData data) {
    return data.pendingOrders.toString();
  }

  String get pendingOrdersNote => 'Aguardando atendimento';

  String formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  double _variation({required double current, required double previous}) {
    if (previous == 0) {
      return current == 0 ? 0 : 100;
    }
    return ((current - previous) / previous) * 100;
  }
}
