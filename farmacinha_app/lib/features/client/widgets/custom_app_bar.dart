import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationTap;
  final VoidCallback? onLogoTap;
  final int unreadCount;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.onMenuTap,
    required this.onNotificationTap,
    this.onLogoTap,
    this.unreadCount = 0,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 1,
      backgroundColor: Pallete.whiteColor,
      leading: IconButton(
        icon: Icon(
          showBackButton ? Icons.arrow_back_ios_new_rounded : Icons.menu_rounded,
          color: Pallete.primaryRed,
          size: showBackButton ? 24 : 28,
        ),
        onPressed: onMenuTap,
      ),
      title: GestureDetector(
        onTap: onLogoTap,
        child: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Drogaria ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Pallete.primaryRed,
                ),
              ),
              TextSpan(
                text: 'Americana',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Pallete.accentYellow,
                ),
              ),
            ],
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Pallete.primaryRed,
                    size: 26,
                  ),
                  onPressed: onNotificationTap,
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Pallete.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
