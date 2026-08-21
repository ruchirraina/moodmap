import 'package:flutter/material.dart';

import '../../constants/auth_constants.dart';

class SignInProvider extends ChangeNotifier {
  String? _emailError;
  String? _passwordError;
  bool _isPasswordVisible = false;
  bool _isPasswordFocused = false;

  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isPasswordFocused => _isPasswordFocused;

  void onEmailFocusChanged(bool hasFocus, String value) {
    if (!hasFocus && value.trim().isEmpty) {
      _emailError = AuthConstants.emptyEmailError;
      notifyListeners();
    }
  }

  void onPasswordFocusChanged(bool hasFocus, String value) {
    _isPasswordFocused = hasFocus;
    if (!hasFocus) {
      _isPasswordVisible = false;
      if (value.isEmpty) {
        _passwordError = AuthConstants.emptyPasswordError;
      }
    }
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void onEmailChanged(String value) {
    if (value.trim().isEmpty) {
      _emailError = AuthConstants.emptyEmailError;
    } else if (_emailError != null) {
      _emailError = null;
    }
    notifyListeners();
  }

  void onPasswordChanged(String value) {
    if (value.isEmpty) {
      _passwordError = AuthConstants.emptyPasswordError;
    } else if (_passwordError != null) {
      _passwordError = null;
    }
    notifyListeners();
  }

  bool validateForm(String email, String password) {
    bool hasError = false;

    if (email.trim().isEmpty) {
      _emailError = AuthConstants.emptyEmailError;
      hasError = true;
    }
    if (password.isEmpty) {
      _passwordError = AuthConstants.emptyPasswordError;
      hasError = true;
    }

    notifyListeners();
    return !hasError;
  }

  void reset() {
    _emailError = null;
    _passwordError = null;
    _isPasswordVisible = false;
    _isPasswordFocused = false;
    notifyListeners();
  }
}
