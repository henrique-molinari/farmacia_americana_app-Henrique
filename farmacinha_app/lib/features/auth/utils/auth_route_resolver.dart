import 'package:farmacia_app/app/app_routes.dart';
import 'package:farmacia_app/features/auth/data/models/user_model.dart';

String resolveHomeRoute(UserRole role) {
  switch (role) {
    case UserRole.cliente:
      return AppRoutes.homeClient;
    case UserRole.atendente:
    case UserRole.farmaceutico:
      return AppRoutes.homeAttendant;
    case UserRole.gerente:
    case UserRole.admin:
      return AppRoutes.homeManager;
  }
}
