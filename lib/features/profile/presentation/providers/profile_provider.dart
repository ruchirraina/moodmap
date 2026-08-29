import 'package:flutter/material.dart';

import '../../../../core/utils/loading_utils.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../journal/data/services/journal_service.dart';
import '../../constants/profile_constants.dart';
import '../../data/services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  final JournalService _journalService = JournalService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isNameFocused = false;
  String? _error;
  String? _nameError;

  String? _cachedName;
  String? _cachedPhotoURL;
  String? _cachedEmail;

  ProfileProvider() {
    _cachedName = _profileService.currentUser?.displayName;
    _cachedPhotoURL = _profileService.currentUser?.photoURL;
    _cachedEmail = _profileService.currentUser?.email;
  }

  bool get isLoading => _isLoading;
  bool get isNameFocused => _isNameFocused;
  String? get error => _error;
  String? get nameError => _nameError;

  String? get currentName => _cachedName;
  String? get photoURL => _cachedPhotoURL;
  String? get email => _cachedEmail;

  void onNameFocusChanged(bool hasFocus, String value) {
    if (_isLoading) return;

    final lostFocus = _isNameFocused && !hasFocus;
    _isNameFocused = hasFocus;

    if (lostFocus && value.trim().isEmpty) {
      _nameError = ProfileConstants.emptyNameError;
    }
    notifyListeners();
  }

  void onNameChanged(String value) {
    if (value.trim().isEmpty) {
      _nameError = ProfileConstants.emptyNameError;
    } else if (value.trim().length > ProfileConstants.nameMaxLength) {
      _nameError = ProfileConstants.nameLengthError;
    } else if (_nameError != null) {
      _nameError = null;
    }
    notifyListeners();
  }

  bool validateForm(String name) {
    _nameError = null;
    bool hasError = false;

    if (name.trim().isEmpty) {
      _nameError = ProfileConstants.emptyNameError;
      hasError = true;
    } else if (name.trim().length > ProfileConstants.nameMaxLength) {
      _nameError = ProfileConstants.nameLengthError;
      hasError = true;
    }

    if (hasError) notifyListeners();
    return !hasError;
  }

  void clearNameError() {
    if (_nameError != null) {
      _nameError = null;
      notifyListeners();
    }
  }

  Future<bool> updateName(String newName) async {
    if (!validateForm(newName)) {
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final startTime = DateTime.now();
    bool isSuccess = false;

    try {
      await _profileService.updateDisplayName(newName.trim());
      await _profileService.currentUser?.reload();
      _cachedName = newName.trim();
      isSuccess = true;
    } catch (e) {
      _error = e.toString();
    }

    await LoadingUtils.enforceMinimumLoadTime(startTime);

    _isLoading = false;
    notifyListeners();
    return isSuccess;
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    final startTime = DateTime.now();

    try {
      await _authService.signOut();
    } catch (e) {
      _error = e.toString();
    }

    await LoadingUtils.enforceMinimumLoadTime(startTime);

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteAccount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final startTime = DateTime.now();
    bool isSuccess = false;

    try {
      final userId = _profileService.currentUser?.uid;
      await _profileService.deleteAccount();
      if (userId != null) {
        await _journalService.deleteAllUserEntries(userId);
      }
      isSuccess = true;
    } catch (e) {
      if (e.toString() == ProfileConstants.excRequiresRecentLogin) {
        _error = ProfileConstants.reauthRequiredError;
      } else {
        _error = e.toString();
      }
    }

    await LoadingUtils.enforceMinimumLoadTime(startTime);

    _isLoading = false;
    notifyListeners();
    return isSuccess;
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  void reset() {
    _isLoading = false;
    _isNameFocused = false;
    _error = null;
    _nameError = null;
    notifyListeners();
  }
}
