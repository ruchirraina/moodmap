import 'package:flutter/material.dart';

import '../../constants/auth_constants.dart';
import '../../data/services/auth_service.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _emailError;
  String? _genericError;
  bool _isEmailFocused = false;
  bool _isResetMessageVisible = false;
  bool _isLoading = false;

  String? get emailError => _emailError;
  String? get genericError => _genericError;
  bool get isResetMessageVisible => _isResetMessageVisible;
  bool get isLoading => _isLoading;

  void onEmailFocusChanged(bool hasFocus, String value) {
    if (_isLoading) return;

    final lostFocus = _isEmailFocused && !hasFocus;
    _isEmailFocused = hasFocus;

    if (lostFocus && value.trim().isEmpty) {
      _emailError = AuthConstants.emptyEmailError;
    }
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

  bool validateForm(String email) {
    if (email.trim().isEmpty) {
      _emailError = AuthConstants.emptyEmailError;
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<bool> sendResetLink(String email) async {
    _genericError = null;
    _isResetMessageVisible = false;
    notifyListeners();

    if (!validateForm(email)) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final startTime = DateTime.now();
    bool isSuccess = false;

    try {
      await _authService.sendPasswordResetEmail(email: email.trim());
      isSuccess = true;
      _isResetMessageVisible = true;
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage == 'Please enter a valid email address.') {
        _emailError = AuthConstants.invalidEmailFormatError;
      } else {
        _genericError = errorMessage;
      }
    }

    final elapsedTime = DateTime.now().difference(startTime);
    if (elapsedTime.inMilliseconds < AuthConstants.minimumLoadingMs) {
      await Future.delayed(
        Duration(
          milliseconds:
              AuthConstants.minimumLoadingMs - elapsedTime.inMilliseconds,
        ),
      );
    }

    _isLoading = false;
    notifyListeners();
    return isSuccess;
  }

  void hideResetMessage() {
    _isResetMessageVisible = false;
    notifyListeners();
  }

  void clearGenericError() {
    if (_genericError != null) {
      _genericError = null;
      notifyListeners();
    }
  }

  void reset() {
    _emailError = null;
    _genericError = null;
    _isEmailFocused = false;
    _isResetMessageVisible = false;
    _isLoading = false;
    notifyListeners();
  }
}
