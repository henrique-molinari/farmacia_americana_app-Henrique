import 'package:farmacia_app/app/app_routes.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/auth/data/models/user_model.dart';
import 'package:farmacia_app/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

class AuthSessionViewModel extends ChangeNotifier {
  AuthSessionViewModel._();

  static final AuthSessionViewModel instance = AuthSessionViewModel._();

  User? _currentUser;
  bool _isGuest = false;

  User? get currentUser => _currentUser;
  bool get isGuest => _isGuest;
  bool get isAuthenticated => _currentUser != null && !_isGuest;

  void login(User user) {
    _currentUser = user;
    _isGuest = false;
    notifyListeners();
  }

  void enterAsGuest() {
    _currentUser = null;
    _isGuest = true;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _isGuest = false;
    notifyListeners();
  }

  Future<User?> restoreSession() async {
    try {
      final restoredUser = await AuthRepository.instance.getCurrentUser();
      _currentUser = restoredUser;
      _isGuest = false;
      notifyListeners();
      return restoredUser;
    } catch (_) {
      _currentUser = null;
      _isGuest = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await AuthRepository.instance.signOut();
    } finally {
      logout();
    }
  }

  bool requireAuthentication(
    BuildContext context, {
    String message = 'Entre com sua conta para continuar.',
  }) {
    if (isAuthenticated) return true;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Login necessário',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Agora não',
              style: TextStyle(color: Pallete.textColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushNamed(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Pallete.primaryRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Fazer login'),
          ),
        ],
      ),
    );

    return false;
  }
}
