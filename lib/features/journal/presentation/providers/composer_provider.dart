import 'package:flutter/material.dart';

import '../../domain/models/journal_entry.dart';
import '../../data/services/journal_service.dart';
import '../../constants/composer_constants.dart';
import '../../constants/journal_constants.dart';
import '../../../auth/data/services/auth_service.dart';

class ComposerProvider extends ChangeNotifier {
  final JournalService _service = JournalService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  String? _titleError;
  int _currentLength = 0;
  int _currentTitleLength = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get titleError => _titleError;
  int get currentLength => _currentLength;
  int get currentTitleLength => _currentTitleLength;

  bool get hasValidationErrors =>
      _titleError != null ||
      _currentLength > ComposerConstants.bodyCharacterLimit;

  void updateCharacterCount(int length) {
    _currentLength = length;
    notifyListeners();
  }

  void updateTitleLength(int length) {
    _currentTitleLength = length;
    notifyListeners();
  }

  void onTitleChanged(String title) {
    _currentTitleLength = title.length;
    if (title.length > ComposerConstants.titleMaxLength) {
      _titleError =
          'Title cannot exceed ${ComposerConstants.titleMaxLength} characters';
    } else {
      _titleError = null;
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> saveEntry({
    required DateTime sessionStart,
    required DateTime entryDate,
    required String title,
    required String body,
    JournalEntry? existingEntry,
  }) async {
    if (hasValidationErrors) return false;

    final now = DateTime.now();
    if (now.day != sessionStart.day ||
        now.month != sessionStart.month ||
        now.year != sessionStart.year) {
      _error = ComposerConstants.pastMidnightError;
      notifyListeners();
      return false;
    }

    final finalTitle = title.trim().isEmpty ? null : title.trim();
    final finalBody = body.trim();

    final hasMusic =
        existingEntry?.songTitle != null ||
        existingEntry?.songCoverUrl != null ||
        existingEntry?.songPreviewUrl != null;

    if (finalTitle == null && finalBody.isEmpty && !hasMusic) {
      if (existingEntry != null) {
        _isLoading = true;
        notifyListeners();

        try {
          await _service.deleteEntry(existingEntry.id);
        } catch (e) {
          _error = JournalConstants.errorGeneric;
          _isLoading = false;
          notifyListeners();
          return false;
        }

        _isLoading = false;
        notifyListeners();
      }
      return true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final user = _authService.currentUser;
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final entryId = existingEntry?.id ?? _service.generateId();

    final entry = JournalEntry(
      id: entryId,
      userId: user.uid,
      date: entryDate,
      title: finalTitle,
      body: finalBody,
      songTitle: existingEntry?.songTitle,
      songArtist: existingEntry?.songArtist,
      songCoverUrl: existingEntry?.songCoverUrl,
      songPreviewUrl: existingEntry?.songPreviewUrl,
      aiSummary: existingEntry?.aiSummary,
      aiColors: existingEntry?.aiColors,
      createdAt: existingEntry?.createdAt ?? now,
      updatedAt: now,
    );

    await Future.delayed(
      const Duration(milliseconds: ComposerConstants.saveDelayMs),
    );

    try {
      await _service.saveEntry(entry);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = JournalConstants.errorGeneric;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
