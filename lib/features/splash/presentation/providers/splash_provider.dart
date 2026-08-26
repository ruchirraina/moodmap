import 'package:flutter/material.dart';

import '../../../auth/data/services/auth_service.dart';

class SplashProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool get isLoggedIn => _authService.currentUser != null;
}
