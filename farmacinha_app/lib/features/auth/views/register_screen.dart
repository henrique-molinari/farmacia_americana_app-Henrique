import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/core/widgets/gradient_button.dart';
import 'package:farmacia_app/core/widgets/login_field.dart';
import 'package:farmacia_app/core/widgets/password_field.dart';
import 'package:farmacia_app/core/widgets/social_button.dart';
import 'package:farmacia_app/features/auth/view_models/register_view_model.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterViewModel viewModel = RegisterViewModel();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Criar conta',
                    style: TextStyle(
                      fontSize: 40,
                      color: Color.fromARGB(255, 233, 206, 120),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  LoginField(
                    hintText: 'Nome completo',
                    controller: viewModel.nameController,
                  ),
                  const SizedBox(height: 16),
                  LoginField(
                    hintText: 'Email',
                    controller: viewModel.emailController,
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    controller: viewModel.passwordController,
                    obscureText: viewModel.obscurePassword,
                    onToggleVisibility: viewModel.togglePasswordVisibility,
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    controller: viewModel.confirmPasswordController,
                    obscureText: viewModel.obscureConfirm,
                    onToggleVisibility: viewModel.toggleConfirmVisibility,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 40,
                          width: 36,
                          child: Checkbox(
                            side: const BorderSide(color: Pallete.borderColor),
                            value: viewModel.acceptedTerms,
                            activeColor: const Color.fromARGB(
                              255,
                              233,
                              206,
                              120,
                            ),
                            onChanged: viewModel.setAcceptedTerms,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Text(
                          'Concordo com os ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Pallete.textColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => debugPrint('Abrir termos de uso'),
                          child: const Text(
                            'termos de uso',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 233, 206, 120),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GradientButton(
                    label: 'Criar conta',
                    onPressed: viewModel.isLoading
                        ? null
                        : () => viewModel.register(context),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'ou',
                    style: TextStyle(
                      fontSize: 17,
                      color: Color.fromARGB(126, 36, 36, 36),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SocialButton(
                    iconName: 'g_logo',
                    label: 'Cadastrar com Google',
                    iconColor: Pallete.googleLogo,
                    textColor: Pallete.textColor,
                    horizontalPadding: 80.0,
                    onPressed: viewModel.registerWithGoogle,
                  ),
                  const SizedBox(height: 20),
                  SocialButton(
                    iconName: 'f_logo',
                    label: 'Cadastrar com Facebook',
                    iconColor: Pallete.facebookLogo,
                    textColor: Pallete.textColor,
                    onPressed: viewModel.registerWithFacebook,
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
