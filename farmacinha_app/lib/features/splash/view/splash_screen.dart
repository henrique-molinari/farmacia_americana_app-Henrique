import 'package:flutter/material.dart';
import 'package:farmacia_app/features/splash/view_model/splash_view_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final SplashViewModel _viewModel = SplashViewModel();

  @override
  void initState() {
    super.initState();

    // Animação simples para a logo aparecer mais suave.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    _viewModel.initializeApp(context);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: _buildLogo(),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DROGARIA',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE31E24),
            letterSpacing: 6,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'AMERIC',
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1A1A),
                height: 1.0,
              ),
            ),
            Container(
              color: const Color(0xFFFFD700),
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              child: const Text(
                'A',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                  height: 1.0,
                ),
              ),
            ),
            const Text(
              'NA',
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1A1A),
                height: 1.0,
              ),
            ),
          ],
        ),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'SAÚDE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE31E24),
              letterSpacing: 5,
            ),
          ),
        ),
      ],
    );
  }
}
