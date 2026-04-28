import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/manager/shared/data/models/manager_dashboard_models.dart';
import 'package:farmacia_app/features/manager/shared/data/repositories/manager_dashboard_repository.dart';
import 'package:flutter/material.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  late Future<ManagerDashboardData> _dataFuture;
  String _selectedFilter = 'Todos';
  String _selectedDateFilter = 'Tudo';
  DateTime? _customDate;

  final List<String> _filters = const ['Todos', 'Sucesso', 'Atencao', 'Erro'];
  final List<String> _dateFilters = const [
    'Tudo',
    'Hoje',
    'Ontem',
    'Esta semana',
    'Personalizado',
  ];

  @override
  void initState() {
    super.initState();
    _dataFuture = ManagerDashboardRepository.instance.fetchDashboardData();
  }

  Future<void> _refresh() async {
    final future = ManagerDashboardRepository.instance.fetchDashboardData();
    setState(() => _dataFuture = future);
    await future;
  }

  List<_ManagerActivity> _buildActivities(ManagerDashboardData data) {
    final activities = <_ManagerActivity>[];

    for (final order in data.orders) {
      activities.add(
        _ManagerActivity(
          title:
              'Pedido ${order.id.replaceFirst('PED-', '#')} - ${order.statusLabel}',
          time: order.createdAt,
          type: _typeForOrder(order),
        ),
      );
    }

    for (final product in data.products.where(
      (product) => product.stock <= 10,
    )) {
      activities.add(
        _ManagerActivity(
          title: 'Estoque critico: ${product.name}',
          time: DateTime.now(),
          type: 'error',
        ),
      );
    }

    activities.sort((a, b) => b.time.compareTo(a.time));
    return activities;
  }

  String _typeForOrder(ManagerOrderSummary order) {
    switch (order.statusLabel) {
      case 'CANCELADO':
        return 'error';
      case 'PENDENTE':
      case 'PROCESSANDO':
        return 'warning';
      default:
        return 'success';
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'success':
        return const Color(0xFF10B981);
      case 'warning':
        return const Color(0xFFFAC000);
      case 'error':
        return Pallete.primaryRed;
      default:
        return Pallete.textColor;
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle_outline_rounded;
      case 'warning':
        return Icons.info_outline_rounded;
      case 'error':
        return Icons.warning_amber_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  String _labelForType(String type) {
    switch (type) {
      case 'success':
        return 'Sucesso';
      case 'warning':
        return 'Atencao';
      case 'error':
        return 'Erro';
      default:
        return '';
    }
  }

  List<_ManagerActivity> _filterActivities(List<_ManagerActivity> activities) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    return activities.where((activity) {
      if (_selectedFilter != 'Todos' &&
          _labelForType(activity.type) != _selectedFilter) {
        return false;
      }

      final activityDate = DateTime(
        activity.time.year,
        activity.time.month,
        activity.time.day,
      );

      switch (_selectedDateFilter) {
        case 'Hoje':
          return activityDate == today;
        case 'Ontem':
          return activityDate == yesterday;
        case 'Esta semana':
          return !activityDate.isBefore(weekStart);
        case 'Personalizado':
          if (_customDate == null) return true;
          return activityDate ==
              DateTime(_customDate!.year, _customDate!.month, _customDate!.day);
        default:
          return true;
      }
    }).toList();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Pallete.primaryRed,
              onPrimary: Pallete.whiteColor,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDate = picked;
        _selectedDateFilter = 'Personalizado';
      });
    }
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
          'Historico de Atividades',
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
      body: FutureBuilder<ManagerDashboardData>(
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

          final activities = _filterActivities(
            _buildActivities(snapshot.data!),
          );

          return RefreshIndicator(
            color: Pallete.primaryRed,
            onRefresh: _refresh,
            child: Column(
              children: [
                _buildFilters(activities.length),
                const SizedBox(height: 12),
                Expanded(
                  child: activities.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 160),
                            Center(
                              child: Text(
                                'Nenhuma atividade encontrada',
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
                          itemCount: activities.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final activity = activities[index];
                            final color = _colorForType(activity.type);
                            final icon = _iconForType(activity.type);
                            final label = _labelForType(activity.type);

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Pallete.whiteColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Pallete.borderColor),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(icon, color: color, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          activity.title,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatDate(activity.time),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Pallete.textColor
                                                .withOpacity(0.7),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: color,
                                      ),
                                    ),
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

  Widget _buildFilters(int activityCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterList(_filters, _selectedFilter, (filter) {
            setState(() => _selectedFilter = filter);
          }),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _dateFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _dateFilters[index];
                final isSelected = filter == _selectedDateFilter;
                final isCustom = filter == 'Personalizado';
                final label = isCustom && _customDate != null
                    ? '${_customDate!.day.toString().padLeft(2, '0')}/${_customDate!.month.toString().padLeft(2, '0')}'
                    : filter;

                return GestureDetector(
                  onTap: () {
                    if (isCustom) {
                      _pickDate(context);
                    } else {
                      setState(() {
                        _selectedDateFilter = filter;
                        _customDate = null;
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Pallete.accentYellow
                          : Pallete.whiteColor,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: isSelected
                            ? Pallete.accentYellow
                            : Pallete.borderColor,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? const Color(0xFF0F172A)
                            : Pallete.textColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$activityCount atividades registradas',
            style: const TextStyle(fontSize: 13, color: Pallete.textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterList(
    List<String> filters,
    String selectedFilter,
    ValueChanged<String> onSelected,
  ) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selectedFilter;

          return GestureDetector(
            onTap: () => onSelected(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Pallete.primaryRed : Pallete.whiteColor,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: isSelected ? Pallete.primaryRed : Pallete.borderColor,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Pallete.whiteColor : Pallete.textColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    if (dateOnly == today) return 'Hoje, $hour:$minute';
    if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Ontem, $hour:$minute';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
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
              'Nao foi possivel carregar o historico.',
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

class _ManagerActivity {
  final String title;
  final DateTime time;
  final String type;

  const _ManagerActivity({
    required this.title,
    required this.time,
    required this.type,
  });
}
