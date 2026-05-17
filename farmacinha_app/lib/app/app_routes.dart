// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:farmacia_app/features/splash/view/splash_screen.dart';
import 'package:farmacia_app/features/auth/views/welcome_screen.dart';
import 'package:farmacia_app/features/auth/views/login_screen.dart';
import 'package:farmacia_app/features/auth/views/register_screen.dart';
import 'package:farmacia_app/features/client/home_client/view/home_client_screen.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view/attendant_search_screen.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view/home_attendant_screen.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view/attendant_chat_screen.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view/attendant_chat_detail_screen.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view/attendant_notications_screen.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view/attendant_profile_screen.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view/attendant_personal_data_screen.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view/attendant_product_registration_screen.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view/attendant_security_screen.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view/attendant_support_screen.dart';

import 'package:farmacia_app/features/client/account/view/account_screen.dart';
import 'package:farmacia_app/features/client/orders/list/view/orders_screen.dart';
import 'package:farmacia_app/features/client/notifications/view/notifications_screen.dart';
import 'package:farmacia_app/features/client/purchase_history/view/purchase_history_screen.dart';
import 'package:farmacia_app/features/client/account/view/personal_data_screen.dart';
import 'package:farmacia_app/features/client/account/view/favorite_products_screen.dart';
import 'package:farmacia_app/features/client/account/view/payment_methods_screen.dart';
import 'package:farmacia_app/features/client/account/view/addresses_screen.dart';
import 'package:farmacia_app/features/client/cart/view/cart_screen.dart';
import 'package:farmacia_app/features/client/cart/view/checkout_screen.dart';
import 'package:farmacia_app/features/client/chat/view/client_chat_screen.dart';
import 'package:farmacia_app/features/client/search/view/search_result_view.dart';
import 'package:farmacia_app/features/client/product_detail/view/product_detail_view.dart';
// ignore: unused_import
import 'package:farmacia_app/features/client/home_client/data/models/product_model.dart';

import 'package:farmacia_app/features/manager/manager_shell_screen.dart';

class AppRoutes {
  // Rotas usadas nas telas de login e cadastro.
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';

  // Cada perfil entra em uma home diferente.
  static const String homeClient = '/home_client';
  static const String homeAttendant = '/home_attendant';
  static const String attendantSearch = '/attendant_search';
  static const String attendantChat = '/attendant_chat';
  static const String attendantChatDetail = '/attendant_chat_detail';
  static const String attendantNotifications = '/attendant_notifications';
  static const String attendantProfile = '/attendant_profile';
  static const String attendantPersonalData = '/attendant_personal_data';
  static const String attendantProductRegistration = '/attendant_product_registration';
  static const String attendantSecurity = '/attendant_security';
  static const String attendantSupport = '/attendant_support';
  static const String homeManager = '/home_manager';

  // Telas do fluxo do cliente.
  static const String account = '/account';
  static const String orders = '/orders';
  static const String notifications = '/notifications';
  static const String purchaseHistory = '/purchase_history';
  static const String personalData = '/personal_data';
  static const String favorites = '/favorites';
  static const String paymentMethods = '/payment_methods';
  static const String addresses = '/addresses';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String clientChat = '/client_chat';
  static const String searchResult = '/search_result';
  static const String productDetail = '/product_detail';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => SplashScreen(),
    welcome: (_) => WelcomeScreen(),
    login: (_) => LoginScreen(),
    register: (_) => RegisterScreen(),
    homeClient: (_) => HomeClientScreen(),
    homeAttendant: (_) => HomeAttendantScreen(),
    attendantSearch: (_) => AttendantSearchScreen(),
    attendantChat: (_) => AttendantChatScreen(),
    attendantChatDetail: (_) => AttendantChatDetailScreen(),
    attendantNotifications: (_) => AttendantNotificationsScreen(),
    attendantProfile: (_) => AttendantProfileScreen(),
    attendantPersonalData: (_) => AttendantPersonalDataScreen(),
    attendantProductRegistration: (_) => AttendantProductRegistrationScreen(),
    attendantSecurity: (_) => AttendantSecurityScreen(),
    attendantSupport: (_) => AttendantSupportScreen(),
    account: (_) => AccountScreen(),
    orders: (_) => OrdersScreen(),
    notifications: (_) => NotificationsScreen(),
    purchaseHistory: (_) => PurchaseHistoryScreen(),
    homeManager: (_) => ManagerShellScreen(),
    personalData: (_) => PersonalDataScreen(),
    favorites: (_) => FavoriteProductsScreen(),
    paymentMethods: (_) => PaymentMethodsScreen(),
    addresses: (_) => AddressesScreen(),
    cart: (_) => CartScreen(),
    checkout: (_) => CheckoutScreen(),
    clientChat: (_) => ClientChatScreen(),
    searchResult: (_) => SearchResultScreen(),
    productDetail: (_) => ProductDetailScreen(),
  };
}
