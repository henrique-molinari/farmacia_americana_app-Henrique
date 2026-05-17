import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final int? productCount;

  const CategoryChip({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isSelected = false,
    this.productCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          // Quando a categoria está ativa, deixei ela mais destacada.
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Pallete.gradient1,
                    Pallete.gradient2,
                    Pallete.gradient3,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Pallete.grayColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Pallete.gradient3
                : Pallete.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Pallete.gradient3.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? const Color.fromARGB(255, 50, 50, 50)
                    : Pallete.textColor,
              ),
              const SizedBox(width: 8),
            ],

            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color.fromARGB(255, 50, 50, 50)
                    : Pallete.textColor,
              ),
            ),

            if (productCount != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.black12
                      : Pallete.borderColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$productCount',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? const Color.fromARGB(255, 50, 50, 50)
                        : Pallete.textColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
