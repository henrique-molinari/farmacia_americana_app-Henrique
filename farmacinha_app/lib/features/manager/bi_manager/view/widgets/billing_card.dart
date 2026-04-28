import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';

class BillingCard extends StatelessWidget {
  final String currentValue;
  final String previousValue;
  final double variation;
  final String periodLabel;

  const BillingCard({
    super.key,
    required this.currentValue,
    required this.previousValue,
    required this.variation,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = variation >= 0;
    final variationText =
        '${isPositive ? '+' : ''}${variation.toStringAsFixed(1)}% $periodLabel';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Pallete.primaryRed, Pallete.redDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label da seção
          const Text(
            'FATURAMENTO DO PERÍODO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 12),

          // Valor atual
          Text(
            currentValue,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 8),

          // Variação percentual
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      variationText,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Divisória
          Container(height: 1, color: Colors.white.withOpacity(0.2)),

          const SizedBox(height: 12),

          // Valor anterior
          Row(
            children: [
              const Icon(
                Icons.history_rounded,
                size: 14,
                color: Colors.white70,
              ),
              const SizedBox(width: 6),
              Text(
                'Período anterior: $previousValue',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
