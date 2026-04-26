import 'package:farmacia_app/app/app_routes.dart';
import 'package:farmacia_app/features/auth/utils/auth_route_resolver.dart';
import 'package:farmacia_app/features/auth/view_models/auth_session_view_model.dart';
import 'package:flutter/material.dart';

class SplashViewModel extends ChangeNotifier {
  Future<void> initializeApp(BuildContext context) async {
    await Future<void>.delayed(const Duration(seconds: 3));

    final restoredUser = await AuthSessionViewModel.instance.restoreSession();
    final nextRoute = restoredUser == null
        ? AppRoutes.welcome
        : resolveHomeRoute(restoredUser.role);

    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed(nextRoute);
    }
  }
}
