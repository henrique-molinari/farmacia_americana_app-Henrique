import 'package:flutter/material.dart';
import 'package:farmacia_app/core/widgets/gradient_button.dart';
import 'package:farmacia_app/core/widgets/social_button.dart';
import 'package:farmacia_app/core/widgets/login_field.dart';
import 'package:farmacia_app/core/widgets/password_field.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/auth/view_models/login_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Instanciando a ViewModel que gerencia os controllers e a lógica de login
  final LoginViewModel viewModel = LoginViewModel();

  @override
  void dispose() {
    // IMPORTANTE: Liberar a memória dos controllers ao fechar a tela
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
                    'Login',
                    style: TextStyle(
                      fontSize: 50,
                      color: Color.fromARGB(255, 233, 206, 120),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Campo de Email vinculado ao controller da ViewModel
                  LoginField(
                    hintText: 'Email',
                    controller: viewModel.emailController,
                  ),
                  const SizedBox(height: 16),

                  // Campo de Senha com controle de visibilidade
                  PasswordField(
                    controller: viewModel.passwordController,
                    obscureText: viewModel.obscurePassword,
                    onToggleVisibility: viewModel.togglePasswordVisibility,
                  ),

                  // Seção "Salvar Login"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 40,
                          width: 36,
                          child: Checkbox(
                            side: const BorderSide(color: Pallete.borderColor),
                            value: viewModel.isRememberMe,
                            activeColor: const Color.fromARGB(
                              255,
                              233,
                              206,
                              120,
                            ),
                            onChanged: viewModel.toggleRememberMe,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Text(
                          'Salvar Login',
                          style: TextStyle(
                            fontSize: 14,
                            color: Pallete.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Botão de Login chamando o método com o context
                  GradientButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () => viewModel.login(context),
                  ),

                  const SizedBox(height: 52),
                  const Text(
                    'ou',
                    style: TextStyle(
                      fontSize: 17,
                      color: Color.fromARGB(126, 36, 36, 36),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botões Sociais (Apenas UI por enquanto)
                  SocialButton(
                    iconName: 'g_logo',
                    label: 'Entrar com Google',
                    iconColor: Pallete.googleLogo,
                    textColor: Pallete.textColor,
                    horizontalPadding: 80.0,
                    onPressed: () => debugPrint("Login Social Google"),
                  ),
                  const SizedBox(height: 25),
                  SocialButton(
                    iconName: 'f_logo',
                    iconColor: Pallete.facebookLogo,
                    label: 'Entrar com Facebook',
                    textColor: Pallete.textColor,
                    onPressed: () => debugPrint("Login Social Facebook"),
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
