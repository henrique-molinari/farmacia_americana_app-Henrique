import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  String _selectedFilter = 'Todos';
  String _selectedDateFilter = 'Tudo';
  DateTime? _customDate;

  final List<String> _filters = ['Todos', 'Sucesso', 'Atenção', 'Erro'];
  final List<String> _dateFilters = ['Tudo', 'Hoje', 'Ontem', 'Esta semana', 'Personalizado'];

  static const List<Map<String, String>> _activities = [
    {'title': 'Relatório gerado', 'time': 'Hoje, 10:32', 'type': 'success'},
    {'title': 'Estoque atualizado', 'time': 'Hoje, 09:15', 'type': 'warning'},
    {'title': 'Pedido #CK-9279 cancelado', 'time': 'Ontem, 17:48', 'type': 'error'},
    {'title': 'Login realizado', 'time': 'Ontem, 08:00', 'type': 'success'},
    {'title': 'Produto cadastrado', 'time': '20/01, 14:30', 'type': 'success'},
    {'title': 'Relatório gerado', 'time': '20/01, 11:00', 'type': 'success'},
    {'title': 'Estoque crítico detectado', 'time': '19/01, 16:45', 'type': 'error'},
    {'title': 'Pedido #CK-9270 aprovado', 'time': '19/01, 14:20', 'type': 'success'},
    {'title': 'Configurações alteradas', 'time': '19/01, 10:05', 'type': 'warning'},
    {'title': 'Login realizado', 'time': '19/01, 08:00', 'type': 'success'},
    {'title': 'Pedido #CK-9265 cancelado', 'time': '18/01, 17:30', 'type': 'error'},
    {'title': 'Estoque atualizado', 'time': '18/01, 15:00', 'type': 'warning'},
  ];

  Color _colorForType(String type) {
    switch (type) {
      case 'success': return const Color(0xFF10B981);
      case 'warning': return const Color(0xFFFAC000);
      case 'error': return Pallete.primaryRed;
      default: return Pallete.textColor;
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'success': return Icons.check_circle_outline_rounded;
      case 'warning': return Icons.info_outline_rounded;
      case 'error': return Icons.warning_amber_rounded;
      default: return Icons.circle_outlined;
    }
  }

  String _labelForType(String type) {
    switch (type) {
      case 'success': return 'Sucesso';
      case 'warning': return 'Atenção';
      case 'error': return 'Erro';
      default: return '';
    }
  }

  List<Map<String, String>> get _filteredActivities {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    return _activities.where((a) {
      // Filtro por tipo
      if (_selectedFilter != 'Todos') {
        final label = _labelForType(a['type']!);
        if (label != _selectedFilter) return false;
      }

      // Filtro por data
      if (_selectedDateFilter != 'Tudo') {
        final time = a['time']!;
        if (_selectedDateFilter == 'Hoje' && !time.startsWith('Hoje')) return false;
        if (_selectedDateFilter == 'Ontem' && !time.startsWith('Ontem')) return false;
        if (_selectedDateFilter == 'Esta semana') {
          if (time.startsWith('Hoje') || time.startsWith('Ontem')) return true;
          // verifica datas no formato dd/mm
          final parts = time.split('/');
          if (parts.length >= 2) {
            final day = int.tryParse(parts[0]);
            final month = int.tryParse(parts[1].split(',')[0]);
            if (day != null && month != null) {
              final activityDate = DateTime(now.year, month, day);
              if (activityDate.isBefore(weekStart)) return false;
            }
          } else {
            return false;
          }
        }
        if (_selectedDateFilter == 'Personalizado' && _customDate != null) {
          final time = a['time']!;
          if (time.startsWith('Hoje')) {
            final activityDate = DateTime(now.year, now.month, now.day);
            if (activityDate != DateTime(_customDate!.year, _customDate!.month, _customDate!.day)) return false;
          } else if (time.startsWith('Ontem')) {
            final activityDate = yesterday;
            if (activityDate != DateTime(_customDate!.year, _customDate!.month, _customDate!.day)) return false;
          } else {
            final parts = time.split('/');
            if (parts.length >= 2) {
              final day = int.tryParse(parts[0]);
              final month = int.tryParse(parts[1].split(',')[0]);
              if (day == null || month == null) return false;
              final activityDate = DateTime(now.year, month, day);
              if (activityDate != DateTime(_customDate!.year, _customDate!.month, _customDate!.day)) return false;
            } else {
              return false;
            }
          }
        }
      }

      return true;
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
    final activities = _filteredActivities;
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
          'Histórico de Atividades',
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
      body: Column(
        children: [
          // Contagem e filtros
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filtro por tipo
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = filter == _selectedFilter;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
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
                ),

                const SizedBox(height: 10),

                // Filtro por data
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _dateFilters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final dateFilter = _dateFilters[index];
                      final isSelected = dateFilter == _selectedDateFilter;
                      final isPersonalizado = dateFilter == 'Personalizado';

                      // Label do chip personalizado mostra a data escolhida
                      String label = dateFilter;
                      if (isPersonalizado && _customDate != null) {
                        label =
                            '${_customDate!.day.toString().padLeft(2, '0')}/${_customDate!.month.toString().padLeft(2, '0')}';
                      }

                      return GestureDetector(
                        onTap: () {
                          if (isPersonalizado) {
                            _pickDate(context);
                          } else {
                            setState(() {
                              _selectedDateFilter = dateFilter;
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
                          child: Row(
                            children: [
                              if (isPersonalizado)
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.calendar_today_rounded,
                                    size: 12,
                                    color: isSelected
                                        ? const Color(0xFF0F172A)
                                        : Pallete.textColor,
                                  ),
                                ),
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? const Color(0xFF0F172A)
                                      : Pallete.textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Contagem
                Text(
                  '${activities.length} atividades registradas',
                  style: const TextStyle(fontSize: 13, color: Pallete.textColor),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Lista
          Expanded(
            child: activities.isEmpty
                ? Center(
                    child: Text(
                      'Nenhuma atividade encontrada',
                      style: TextStyle(
                        fontSize: 14,
                        color: Pallete.textColor.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: activities.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                final color = _colorForType(activity['type']!);
                final icon = _iconForType(activity['type']!);
                final label = _labelForType(activity['type']!);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Pallete.whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Pallete.borderColor),
                  ),
                  child: Row(
                    children: [
                      // Ícone colorido
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

                      // Título e hora
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity['title']!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activity['time']!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Pallete.textColor.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Badge de tipo
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
  }
}