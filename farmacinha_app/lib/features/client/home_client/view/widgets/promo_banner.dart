import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';

class PromoBanner extends StatelessWidget {
  /// Título principal da promoção
  final String title;

  /// Subtítulo ou descrição da promoção
  final String? subtitle;

  /// Percentual de desconto (ex: 50)
  final int? discountPercentage;

  /// Texto do botão CTA
  final String ctaText;

  /// URL da imagem de fundo ou ícone
  final String? backgroundImageUrl;

  /// Ícone decorativo (alternativa a image)
  final IconData? icon;

  /// Cor de fundo primária (se não usar imagem)
  final Color? backgroundColor;

  /// Callback ao clicar no banner
  final VoidCallback? onTap;

  /// Callback ao clicar no botão
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
          // Imagem de fundo (se houver)
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
          // Gradiente como fallback
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
            // Ícone decorativo no canto (fundo)
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

            // Conteúdo principal
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Espaço para layout flexível
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Subtítulo/Tag
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

                        // Título principal
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

                  // Footer com desconto e botão
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge de desconto
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

                      // Botão CTA
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
