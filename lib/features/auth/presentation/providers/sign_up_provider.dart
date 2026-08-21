import 'package:flutter/material.dart';

import '../../constants/auth_constants.dart';

class SignUpProvider extends ChangeNotifier {
  String? _emailError;
  String? _nameError;
  String? _passwordError;
  bool _isPasswordVisible = false;
  bool _isPasswordFocused = false;

  String? get emailError => _emailError;
  String? get nameError => _nameError;
  String? get passwordError => _passwordError;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isPasswordFocused => _isPasswordFocused;

  void onEmailFocusChanged(bool hasFocus, String value) {
    if (!hasFocus && value.trim().isEmpty) {
      _emailError = AuthConstants.emptyEmailError;
      notifyListeners();
    }
  }

  void onNameFocusChanged(bool hasFocus, String value) {
    if (!hasFocus && value.trim().isEmpty) {
      _nameError = AuthConstants.emptyNameError;
      notifyListeners();
    }
  }

  void onPasswordFocusChanged(bool hasFocus, String value) {
    _isPasswordFocused = hasFocus;
    if (!hasFocus) {
      _isPasswordVisible = false;
      if (value.isEmpty) {
        _passwordError = AuthConstants.emptyPasswordError;
      } else if (value.length < AuthConstants.passwordMinLength) {
        _passwordError = AuthConstants.passwordLengthError;
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

  void onNameChanged(String value) {
    if (value.trim().isEmpty) {
      _nameError = AuthConstants.emptyNameError;
    } else if (value.trim().length > AuthConstants.nameMaxLength) {
      _nameError = AuthConstants.nameLengthError;
    } else if (_nameError != null) {
      _nameError = null;
    }
    notifyListeners();
  }

  void onPasswordChanged(String value) {
    if (value.isEmpty) {
      _passwordError = AuthConstants.emptyPasswordError;
    } else if (_passwordError == AuthConstants.passwordLengthError &&
        value.length < AuthConstants.passwordMinLength) {
      // Maintain the length error visually until the length requirement is met.
    } else if (_passwordError != null) {
      _passwordError = null;
    }
    notifyListeners();
  }

  bool validateForm(String email, String name, String password) {
    bool hasError = false;

    if (email.trim().isEmpty) {
      _emailError = AuthConstants.emptyEmailError;
      hasError = true;
    }
    if (name.trim().isEmpty) {
      _nameError = AuthConstants.emptyNameError;
      hasError = true;
    } else if (name.trim().length > AuthConstants.nameMaxLength) {
      _nameError = AuthConstants.nameLengthError;
      hasError = true;
    }
    if (password.isEmpty) {
      _passwordError = AuthConstants.emptyPasswordError;
      hasError = true;
    } else if (password.length < AuthConstants.passwordMinLength) {
      _passwordError = AuthConstants.passwordLengthError;
      hasError = true;
    }

    notifyListeners();
    return !hasError;
  }

  void reset() {
    _emailError = null;
    _nameError = null;
    _passwordError = null;
    _isPasswordVisible = false;
    _isPasswordFocused = false;
    notifyListeners();
  }
}
