import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../auth/data/services/auth_service.dart';

class HomeProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  StreamSubscription? _authSubscription;

  String? _displayName;
  String? _photoURL;

  String? get displayName => _displayName;
  String? get photoURL => _photoURL;

  HomeProvider() {
    _authSubscription = _authService.userChanges.listen((User? user) {
      if (_displayName != user?.displayName || _photoURL != user?.photoURL) {
        _displayName = user?.displayName;
        _photoURL = user?.photoURL;
        notifyListeners();
      }
    });

    final currentUser = _authService.currentUser;
    _displayName = currentUser?.displayName;
    _photoURL = currentUser?.photoURL;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
