import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';

class PromoBanner extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int? discountPercentage;
  final String ctaText;
  final String? backgroundImageUrl;
  final IconData? icon;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final VoidCallback? onCtaTapped;

  const PromoBanner({
    super.key,
    required this.title,
    required this.ctaText,
    this.subtitle,
    this.discountPercentage,
    this.backgroundImageUrl,
    this.icon,
    this.backgroundColor,
    this.onTap,
    this.onCtaTapped,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isMobile ? 160 : 200,
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          image: backgroundImageUrl != null
              ? DecorationImage(
                  image: NetworkImage(backgroundImageUrl!),
                  fit: BoxFit.cover,
                  colorFilter: const ColorFilter.mode(
                    Colors.black12,
                    BlendMode.darken,
                  ),
                )
              : null,
          // Se não vier imagem, uso um fundo em gradiente.
          gradient: backgroundImageUrl == null
              ? LinearGradient(
                  colors: [
                    backgroundColor ?? Pallete.gradient1,
                    // ignore: deprecated_member_use
                    backgroundColor?.withOpacity(0.8) ??
                        Pallete.gradient3,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (icon != null)
              Positioned(
                right: -30,
                bottom: -30,
                child: Icon(
                  icon,
                  size: 150,
                  color: Colors.white,
                ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (subtitle != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Pallete.actionButton,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 50, 50, 50),
                              ),
                            ),
                          ),

                        const SizedBox(height: 8),

                        Text(
                          title,
                          style: TextStyle(
                            fontSize: isMobile ? 22 : 28,
                            fontWeight: FontWeight.bold,
                            color: Pallete.whiteColor,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (discountPercentage != null)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Pallete.actionButton,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'ATÉ $discountPercentage%\nDE DESCONTO',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 50, 50, 50),
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onCtaTapped,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Pallete.whiteColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              ctaText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color.fromARGB(255, 50, 50, 50),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
