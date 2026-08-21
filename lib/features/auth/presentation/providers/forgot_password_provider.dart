import 'package:flutter/material.dart';

import '../../constants/auth_constants.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  String? _emailError;
  bool _isResetMessageVisible = false;

  String? get emailError => _emailError;
  bool get isResetMessageVisible => _isResetMessageVisible;

  void onEmailFocusChanged(bool hasFocus, String value) {
    if (!hasFocus && value.trim().isEmpty) {
      _emailError = AuthConstants.emptyEmailError;
      notifyListeners();
    }
  }

  void onEmailChanged(String value) {
    if (value.trim().isEmpty) {
      _emailError = AuthConstants.emptyEmailError;
    } else if (_emailError != null) {
      _emailError = null;
    }
    notifyListeners();
  }

  bool validateForm(String email) {
    if (email.trim().isEmpty) {
      _emailError = AuthConstants.emptyEmailError;
      notifyListeners();
      return false;
    }
    return true;
  }

  void showResetMessage() {
    _isResetMessageVisible = true;
    notifyListeners();
  }

  void hideResetMessage() {
    _isResetMessageVisible = false;
    notifyListeners();
  }

  void reset() {
    _emailError = null;
    _isResetMessageVisible = false;
    notifyListeners();
  }
}
