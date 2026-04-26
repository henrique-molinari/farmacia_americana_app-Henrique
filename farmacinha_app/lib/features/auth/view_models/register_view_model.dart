import 'package:farmacia_app/features/auth/data/repositories/auth_repository.dart';
import 'package:farmacia_app/features/auth/utils/auth_route_resolver.dart';
import 'package:farmacia_app/features/auth/view_models/auth_session_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterViewModel extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;
  bool _isLoading = false;

  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirm => _obscureConfirm;
  bool get acceptedTerms => _acceptedTerms;
  bool get isLoading => _isLoading;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmVisibility() {
    _obscureConfirm = !_obscureConfirm;
    notifyListeners();
  }

  void setAcceptedTerms(bool? value) {
    _acceptedTerms = value ?? false;
    notifyListeners();
  }

  Future<void> register(BuildContext context) async {
    final fullName = nameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      _showFeedback(context, 'Preencha nome, e-mail e senha para continuar.');
      return;
    }

    if (!_acceptedTerms) {
      _showFeedback(context, 'Aceite os termos de uso para criar sua conta.');
      return;
    }

    if (password != confirmPassword) {
      _showFeedback(context, 'As senhas nao coincidem.');
      return;
    }

    if (password.length < 6) {
      _showFeedback(context, 'A senha precisa ter pelo menos 6 caracteres.');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final registeredUser = await AuthRepository.instance.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );

      if (!context.mounted) return;

      context.read<AuthSessionViewModel>().login(registeredUser);
      _showFeedback(context, 'Conta criada com sucesso.', isWarning: false);

      Navigator.pushNamedAndRemoveUntil(
        context,
        resolveHomeRoute(registeredUser.role),
        (route) => false,
      );
    } catch (error, stackTrace) {
      debugPrint('Erro ao cadastrar: $error');
      debugPrint('$stackTrace');
      if (!context.mounted) return;
      _showFeedback(context, _formatAuthError(error));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _formatAuthError(Object error) {
    final message = error.toString();

    if (message.contains('User already registered')) {
      return 'Ja existe uma conta cadastrada com esse e-mail.';
    }

    if (message.contains('Password should be at least')) {
      return 'A senha precisa atender ao minimo exigido pelo Supabase.';
    }

    if (message.contains('Confirm email')) {
      return 'O Supabase ainda esta exigindo confirmacao por e-mail. Desative essa opcao no painel para testar pelo app.';
    }

    if (message.contains('Database error saving new user')) {
      return 'O Supabase recusou salvar o usuario. Normalmente isso acontece por trigger, policy ou conflito na tabela profiles.';
    }

    if (message.contains('duplicate key value')) {
      return 'Ja existe um perfil com esse e-mail ou identificador no banco.';
    }

    if (message.contains('row-level security')) {
      return 'A policy do Supabase bloqueou a criacao do perfil.';
    }

    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    return 'Nao foi possivel criar sua conta agora. Detalhe: $message';
  }

  void _showFeedback(
    BuildContext context,
    String message, {
    bool isWarning = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isWarning ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void registerWithGoogle() {
    debugPrint('Fluxo de autenticacao com Google ainda nao foi integrado.');
  }

  void registerWithFacebook() {
    debugPrint('Fluxo de autenticacao com Facebook ainda nao foi integrado.');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
