import 'package:flutter/material.dart';

import '../../constants/auth_constants.dart';
import '../../data/services/auth_service.dart';

class SignInProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _emailError;
  String? _passwordError;
  String? _genericError;
  bool _isPasswordVisible = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;

  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get genericError => _genericError;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isPasswordFocused => _isPasswordFocused;
  bool get isEmailLoading => _isEmailLoading;
  bool get isGoogleLoading => _isGoogleLoading;

  void onEmailFocusChanged(bool hasFocus, String value) {
    if (_isEmailLoading || _isGoogleLoading) return;

    final lostFocus = _isEmailFocused && !hasFocus;
    _isEmailFocused = hasFocus;

    if (lostFocus && value.trim().isEmpty) {
      _emailError = AuthConstants.emptyEmailError;
    }
    notifyListeners();
  }

  void onPasswordFocusChanged(bool hasFocus, String value) {
    if (_isEmailLoading || _isGoogleLoading) return;

    final lostFocus = _isPasswordFocused && !hasFocus;
    _isPasswordFocused = hasFocus;

    if (!hasFocus) {
      _isPasswordVisible = false;
    }

    if (lostFocus && value.isEmpty) {
      _passwordError = AuthConstants.emptyPasswordError;
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
    _emailError = null;
    _passwordError = null;
    bool hasError = false;

    if (email.trim().isEmpty) {
      _emailError = AuthConstants.emptyEmailError;
      hasError = true;
    }
    if (password.isEmpty) {
      _passwordError = AuthConstants.emptyPasswordError;
      hasError = true;
    }

    return !hasError;
  }

  Future<bool> signIn(String email, String password) async {
    _genericError = null;
    notifyListeners();

    if (!validateForm(email, password)) {
      notifyListeners();
      return false;
    }

    _isEmailLoading = true;
    notifyListeners();

    final startTime = DateTime.now();
    bool isSuccess = false;

    try {
      await _authService.signInWithEmail(
        email: email.trim(),
        password: password,
      );
      isSuccess = true;
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage == AuthConstants.excInvalidCreds) {
        _emailError = AuthConstants.invalidCredentialsError;
        _passwordError = AuthConstants.invalidCredentialsError;
      } else if (errorMessage == AuthConstants.excInvalidEmail) {
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

    if (!isSuccess) {
      _isEmailLoading = false;
      notifyListeners();
    }
    return isSuccess;
  }

  Future<bool> signInWithGoogle() async {
    _emailError = null;
    _passwordError = null;
    _genericError = null;
    _isGoogleLoading = true;
    notifyListeners();

    final startTime = DateTime.now();
    bool isSuccess = false;

    try {
      await _authService.signInWithGoogle();
      isSuccess = true;
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage != AuthConstants.excSignInAborted) {
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

    if (!isSuccess) {
      _isGoogleLoading = false;
      notifyListeners();
    }
    return isSuccess;
  }

  void clearErrors() {
    _emailError = null;
    _passwordError = null;
    _genericError = null;
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
    _passwordError = null;
    _genericError = null;
    _isPasswordVisible = false;
    _isEmailFocused = false;
    _isPasswordFocused = false;
    _isEmailLoading = false;
    _isGoogleLoading = false;
    notifyListeners();
  }
}
