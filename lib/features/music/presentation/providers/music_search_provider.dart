import 'package:flutter/material.dart';

import '../../constants/music_constants.dart';
import '../../data/services/music_service.dart';
import '../../domain/models/music_result.dart';

class MusicSearchProvider extends ChangeNotifier {
  final MusicService _musicService = MusicService();

  List<MusicResult> _results = [];
  bool _isLoading = false;
  String? _error;
  bool _isDisposed = false;

  List<MusicResult> get results => _results;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void clearSearch() {
    _results = [];
    _error = null;
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> searchSongs(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    _isLoading = true;
    _error = null;
    if (!_isDisposed) {
      notifyListeners();
    }

    final startTime = DateTime.now();

    try {
      _results = await _musicService.searchSongs(query.trim());
    } catch (e) {
      if (e.toString().contains(MusicConstants.networkError)) {
        _error = MusicConstants.networkError;
      } else {
        _error = MusicConstants.genericError;
      }
      _results = [];
    }

    final elapsedTime = DateTime.now().difference(startTime);
    if (elapsedTime.inMilliseconds < MusicConstants.minimumLoadingMs) {
      await Future.delayed(
        Duration(
          milliseconds:
              MusicConstants.minimumLoadingMs - elapsedTime.inMilliseconds,
        ),
      );
    }

    if (_isDisposed) return;

    _isLoading = false;
    notifyListeners();
  }
}
