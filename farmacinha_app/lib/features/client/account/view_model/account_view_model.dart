import 'package:farmacia_app/app/app_routes.dart';
import 'package:farmacia_app/features/auth/data/models/user_model.dart';
import 'package:farmacia_app/features/auth/view_models/auth_session_view_model.dart';
import 'package:flutter/material.dart';

class AccountViewModel extends ChangeNotifier {
  AccountViewModel({AuthSessionViewModel? authSession})
    : _authSession = authSession ?? AuthSessionViewModel.instance {
    _authSession.addListener(_syncWithSession);
    _syncWithSession();
  }

  final AuthSessionViewModel _authSession;
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isGuest => _authSession.isGuest || !_authSession.isAuthenticated;

  int get loyaltyPoints => 450;
  String get loyaltyTier => 'Cliente Gold';

  void _syncWithSession() {
    _currentUser = isGuest ? null : _authSession.currentUser;
    _isLoading = false;
    notifyListeners();
  }

  void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.login);
  }

  void navigateToRegister(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.register);
  }

  Future<void> logout(BuildContext context) async {
    await _authSession.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  void dispose() {
    _authSession.removeListener(_syncWithSession);
    super.dispose();
  }
}
