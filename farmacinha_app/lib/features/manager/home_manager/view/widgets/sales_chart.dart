import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:flutter/material.dart';

class SalesChart extends StatefulWidget {
  final List<Map<String, dynamic>> dailyData;
  final List<Map<String, dynamic>> monthlyData;

  const SalesChart({
    super.key,
    required this.dailyData,
    required this.monthlyData,
  });

  @override
  State<SalesChart> createState() => _SalesChartState();
}

class _SalesChartState extends State<SalesChart> {
  int _selectedFilter = 0;

  List<Map<String, dynamic>> get _currentData =>
      _selectedFilter == 0 ? widget.dailyData : widget.monthlyData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Pallete.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Pallete.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Performance de Vendas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Pallete.grayColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _FilterButton(
                      label: 'Semanal',
                      isSelected: _selectedFilter == 0,
                      onTap: () => setState(() => _selectedFilter = 0),
                    ),
                    _FilterButton(
                      label: 'Mensal',
                      isSelected: _selectedFilter == 1,
                      onTap: () => setState(() => _selectedFilter = 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: _currentData.isEmpty
                ? const Center(
                    child: Text(
                      'Sem vendas no periodo',
                      style: TextStyle(
                        color: Pallete.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _currentData.map((data) {
                      final heightFactor = data['revenue'] as double;
                      final isActive = heightFactor == 1.00;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOut,
                                height: 160 * heightFactor,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Pallete.primaryRed
                                      : Pallete.accentYellow.withOpacity(0.35),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                data['label'].toString(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: isActive
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isActive
                                      ? Pallete.primaryRed
                                      : Pallete.textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Pallete.whiteColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Pallete.primaryRed : Pallete.textColor,
          ),
        ),
      ),
    );
  }
}
