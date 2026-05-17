import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/auth/view_models/welcome_view_model.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});

  final WelcomeViewModel viewModel = WelcomeViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 60),
                Image.asset(
                  'assets/images/logo.png',
                  width: 260,
                  fit: BoxFit.contain,
                ),

                const Column(
                  children: [
                    Text(
                      'Seja Bem Vindo(a)!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Acesse sua conta ou crie sua conta',
                      style: TextStyle(fontSize: 14, color: Pallete.textColor),
                    ),
                  ],
                ),

                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => viewModel.navigateToLogin(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Pallete.actionButton,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'ENTRAR',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => viewModel.navigateToRegister(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Pallete.actionButton,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'CRIAR CONTA',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Pallete.actionButton,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                GestureDetector(
                  onTap: () => viewModel.enterAsGuest(context),
                  child: const Text(
                    'Entrar como visitante',
                    style: TextStyle(
                      fontSize: 14,
                      color: Pallete.textColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                const Column(
                  children: [
                    Text(
                      'versão do aplicativo: 1.0.0',
                      style: TextStyle(fontSize: 12, color: Pallete.textColor),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
