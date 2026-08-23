import 'package:flutter/material.dart';

import '../../constants/auth_constants.dart';
import '../../data/services/auth_service.dart';

class SignUpProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _emailError;
  String? _nameError;
  String? _passwordError;
  String? _genericError;
  bool _isPasswordVisible = false;
  bool _isEmailFocused = false;
  bool _isNameFocused = false;
  bool _isPasswordFocused = false;
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;

  String? get emailError => _emailError;
  String? get nameError => _nameError;
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

  void onNameFocusChanged(bool hasFocus, String value) {
    if (_isEmailLoading || _isGoogleLoading) return;

    final lostFocus = _isNameFocused && !hasFocus;
    _isNameFocused = hasFocus;

    if (lostFocus && value.trim().isEmpty) {
      _nameError = AuthConstants.emptyNameError;
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

    if (lostFocus) {
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
    _emailError = null;
    _nameError = null;
    _passwordError = null;
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

    return !hasError;
  }

  Future<bool> signUp(String email, String name, String password) async {
    _genericError = null;
    notifyListeners();

    if (!validateForm(email, name, password)) {
      notifyListeners();
      return false;
    }

    _isEmailLoading = true;
    notifyListeners();

    final startTime = DateTime.now();
    bool isSuccess = false;

    try {
      await _authService.signUpWithEmail(
        email: email.trim(),
        password: password,
        name: name.trim(),
      );
      isSuccess = true;
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage == AuthConstants.excEmailInUse) {
        _emailError = AuthConstants.emailInUseError;
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

  Future<bool> signUpWithGoogle() async {
    _emailError = null;
    _nameError = null;
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
    _nameError = null;
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
    _nameError = null;
    _passwordError = null;
    _genericError = null;
    _isPasswordVisible = false;
    _isEmailFocused = false;
    _isNameFocused = false;
    _isPasswordFocused = false;
    _isEmailLoading = false;
    _isGoogleLoading = false;
    notifyListeners();
  }
}
