import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/models/journal_entry.dart';
import '../../data/services/journal_service.dart';
import '../../data/services/ai_service.dart';
import '../../constants/journal_constants.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../music/domain/models/music_result.dart';

class JournalProvider extends ChangeNotifier {
  final JournalService _service = JournalService();
  final AuthService _authService = AuthService();
  final AiService _aiService = AiService();
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
        _selectedDate = DateTime.now();
        _isInitialized = false;
        _isLoading = true;
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
    return _entries
        .where(
          (entry) =>
              entry.date.year == _selectedDate.year &&
              entry.date.month == _selectedDate.month &&
              entry.date.day == _selectedDate.day,
        )
        .firstOrNull;
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

  Future<bool> generateAiMoodMap(JournalEntry entry) async {
    if (entry.aiSummary != null && entry.aiColors != null) return true;

    final aiResult = await _aiService.generateMoodMap(
      entry.body,
      entry.songTitle,
      entry.songArtist,
    );

    if (aiResult != null &&
        aiResult['summary'] != null &&
        aiResult['colors'] != null) {
      final summary = aiResult['summary'] as String;
      final colors = (aiResult['colors'] as List)
          .map((e) => e.toString())
          .toList();

      final updatedEntry = JournalEntry(
        id: entry.id,
        userId: entry.userId,
        date: entry.date,
        title: entry.title,
        body: entry.body,
        songTitle: entry.songTitle,
        songArtist: entry.songArtist,
        songCoverUrl: entry.songCoverUrl,
        songPreviewUrl: entry.songPreviewUrl,
        aiSummary: summary,
        aiColors: colors,
        createdAt: entry.createdAt,
        updatedAt: DateTime.now(),
      );

      await saveEntry(updatedEntry);
      return true;
    }
    return false;
  }

  Future<JournalEntry> updateEntryMusic(
    JournalEntry entry,
    MusicResult? music,
  ) async {
    final updatedEntry = JournalEntry(
      id: entry.id,
      userId: entry.userId,
      date: entry.date,
      title: entry.title,
      body: entry.body,
      songTitle: music?.title,
      songArtist: music?.artist,
      songCoverUrl: music?.coverUrl,
      songPreviewUrl: music?.previewUrl,
      aiSummary: entry.aiSummary,
      aiColors: entry.aiColors,
      createdAt: entry.createdAt,
      updatedAt: DateTime.now(),
    );

    await saveEntry(updatedEntry);
    return updatedEntry;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _entriesSubscription?.cancel();
    super.dispose();
  }
}
