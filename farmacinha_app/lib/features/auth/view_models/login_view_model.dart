import 'package:farmacia_app/features/auth/data/repositories/auth_repository.dart';
import 'package:farmacia_app/features/auth/utils/auth_route_resolver.dart';
import 'package:farmacia_app/features/auth/view_models/auth_session_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isRememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  bool get isRememberMe => _isRememberMe;
  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _isLoading;

  void toggleRememberMe(bool? value) {
    _isRememberMe = value ?? false;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    final emailInput = emailController.text.trim().toLowerCase();
    final passwordInput = passwordController.text.trim();

    if (emailInput.isEmpty || passwordInput.isEmpty) {
      _showErrorSnackBar(context, 'Preencha e-mail e senha para continuar.');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final authenticatedUser = await AuthRepository.instance.signIn(
        email: emailInput,
        password: passwordInput,
      );

      if (!context.mounted) return;

      context.read<AuthSessionViewModel>().login(authenticatedUser);
      Navigator.pushNamedAndRemoveUntil(
        context,
        resolveHomeRoute(authenticatedUser.role),
        (route) => false,
      );
    } catch (error, stackTrace) {
      debugPrint('Erro ao fazer login: $error');
      debugPrint('$stackTrace');
      if (!context.mounted) return;
      _showErrorSnackBar(context, _formatAuthError(error));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _formatAuthError(Object error) {
    final message = error.toString();

    if (message.contains('Invalid login credentials')) {
      return 'E-mail ou senha invalidos. Se voce acabou de trocar o e-mail, use o e-mail antigo ate confirmar a troca no Supabase.';
    }

    if (message.contains('Email not confirmed')) {
      return 'Confirme seu e-mail antes de entrar.';
    }

    if (message.contains('row-level security')) {
      return 'A policy do Supabase bloqueou o acesso ao perfil do usuario.';
    }

    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    return 'Nao foi possivel fazer login agora. Detalhe: $message';
  }

  void _showErrorSnackBar(
    BuildContext context,
    String message, {
    bool isWarning = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isWarning ? Colors.orange : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
