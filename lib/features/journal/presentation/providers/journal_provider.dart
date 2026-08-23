import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/models/journal_entry.dart';
import '../../data/services/journal_service.dart';
import '../../constants/journal_constants.dart';
import '../../../auth/data/services/auth_service.dart';

class JournalProvider extends ChangeNotifier {
  final JournalService _service = JournalService();
  final AuthService _authService = AuthService();
  StreamSubscription? _authSubscription;
  StreamSubscription? _entriesSubscription;

  List<JournalEntry> _entries = [];
  bool _isLoading = true;
  bool _isInitialized = false;
  String? _error;

  DateTime _selectedDate = DateTime.now();

  JournalProvider() {
    _authSubscription = _authService.authStateChanges.listen((user) {
      if (user != null) {
        _loadEntries(user.uid);
      } else {
        _entries = [];
        _entriesSubscription?.cancel();
        notifyListeners();
      }
    });
  }

  List<JournalEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;

  JournalEntry? get entryForSelectedDate {
    try {
      return _entries.firstWhere(
        (entry) =>
            entry.date.year == _selectedDate.year &&
            entry.date.month == _selectedDate.month &&
            entry.date.day == _selectedDate.day,
      );
    } catch (_) {
      return null;
    }
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void _loadEntries(String userId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _entriesSubscription?.cancel();
    _entriesSubscription = _service
        .getUserEntriesStream(userId)
        .listen(
          (entries) {
            _entries = entries;
            _isLoading = false;
            _isInitialized = true;
            notifyListeners();
          },
          onError: (err) {
            _error = JournalConstants.errorGeneric;
            _isLoading = false;
            _isInitialized = true;
            notifyListeners();
          },
        );
  }

  Future<void> saveEntry(JournalEntry entry) async {
    _error = null;
    notifyListeners();
    try {
      await _service.saveEntry(entry);
    } catch (e) {
      _error = JournalConstants.errorGeneric;
      notifyListeners();
    }
  }

  Future<void> deleteEntry(String entryId) async {
    _error = null;
    notifyListeners();
    try {
      await _service.deleteEntry(entryId);
    } catch (e) {
      _error = JournalConstants.errorGeneric;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _entriesSubscription?.cancel();
    super.dispose();
  }
}
