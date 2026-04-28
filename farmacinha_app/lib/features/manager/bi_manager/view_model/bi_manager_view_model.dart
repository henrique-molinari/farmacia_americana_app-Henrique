import 'package:farmacia_app/features/manager/shared/data/models/manager_dashboard_models.dart';
import 'package:farmacia_app/features/manager/shared/data/repositories/manager_dashboard_repository.dart';

class BiManagerViewModel {
  final List<String> periods = const ['Diario', 'Semanal', 'Mensal'];

  Future<ManagerBiData> loadData() {
    return ManagerDashboardRepository.instance.fetchBiData();
  }

  double getVariation(ManagerBillingPeriod data) {
    if (data.previous == 0) {
      return data.current == 0 ? 0 : 100;
    }
    return ((data.current - data.previous) / data.previous) * 100;
  }

  double getCurrentProgress(ManagerBillingPeriod data) {
    final max = data.current > data.previous ? data.current : data.previous;
    if (max == 0) return 0;
    return data.current / max;
  }

  double getPreviousProgress(ManagerBillingPeriod data) {
    final max = data.current > data.previous ? data.current : data.previous;
    if (max == 0) return 0;
    return data.previous / max;
  }

  String formatCurrency(double value) {
    if (value >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(1).replaceAll('.', ',')}mil';
    }
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String get updatedAt {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return 'Atualizado hoje, $hour:$minute';
  }
}
