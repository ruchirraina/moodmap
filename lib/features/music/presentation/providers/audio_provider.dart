import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../constants/music_constants.dart';

class AudioProvider extends ChangeNotifier with WidgetsBindingObserver {
  final AudioPlayer _searchPlayer = AudioPlayer();
  final Map<String, AudioPlayer> _globalPlayers = {};
  final List<String> _globalPlayerKeys = [];

  final Map<String, int> _fadeTokens = {};
  final Map<String, Duration> _durations = {};
  final Map<String, bool> _isLoopFadingMap = {};

  bool _isMuted = true;
  String? _currentGlobalUrl;
  String? _currentSearchUrl;

  bool _isSearchPlaying = false;
  bool _isSearchLoading = false;
  bool _hasSearchError = false;

  bool _isGlobalLoading = false;
  bool _hasGlobalError = false;

  bool _isBackgrounded = false;
  bool _wasSearchPlayingBeforeBackground = false;
  bool _wasGlobalPlayingBeforeBackground = false;

  Timer? _searchTimeout;
  Timer? _globalTimeout;

  AudioProvider() {
    WidgetsBinding.instance.addObserver(this);

    _searchPlayer.setReleaseMode(ReleaseMode.loop);

    _searchPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        _isSearchPlaying = true;
        notifyListeners();
      } else if (state == PlayerState.paused || state == PlayerState.stopped) {
        _isSearchPlaying = false;
        notifyListeners();
      }
    });

    _searchPlayer.onPositionChanged.listen((position) {
      if (position > Duration.zero && _isSearchLoading) {
        _isSearchLoading = false;
        _hasSearchError = false;
        _searchTimeout?.cancel();
        notifyListeners();
      }
    });

    _searchPlayer.onPlayerComplete.listen((_) {
      _isSearchPlaying = false;
      _isSearchLoading = false;
      _hasSearchError = true;
      notifyListeners();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_isBackgrounded) {
        _isBackgrounded = false;
        _resumeFromBackground();
      }
    } else {
      if (!_isBackgrounded) {
        _isBackgrounded = true;
        _wasSearchPlayingBeforeBackground =
            (_isSearchPlaying || _isSearchLoading) && _currentSearchUrl != null;
        _wasGlobalPlayingBeforeBackground =
            (!_isMuted || _isGlobalLoading) && _currentGlobalUrl != null;
        _pauseAllImmediately();
      }
    }
  }

  void _resumeFromBackground() async {
    if (_wasSearchPlayingBeforeBackground && _currentSearchUrl != null) {
      _isSearchPlaying = true;
      _isSearchLoading = false;
      _hasSearchError = false;
      notifyListeners();

      if (_searchPlayer.state == PlayerState.stopped ||
          _searchPlayer.state == PlayerState.completed) {
        await _searchPlayer.seek(Duration.zero);
      }
      await _searchPlayer.setVolume(1.0);
      await _searchPlayer.resume();
    } else if (_wasGlobalPlayingBeforeBackground && _currentGlobalUrl != null) {
      _isMuted = false;
      notifyListeners();
      await _playGlobalTrack(fade: true);
    }
  }

  void _pauseAllImmediately() {
    bool changed = false;

    if (_isSearchPlaying || _isSearchLoading) {
      _searchTimeout?.cancel();
      _isSearchPlaying = false;
      _isSearchLoading = false;
      _abortFades(_searchPlayer);
      _searchPlayer.pause();
      changed = true;
    }

    if (!_isMuted || _isGlobalLoading) {
      _isMuted = true;
      _isGlobalLoading = false;
      _globalTimeout?.cancel();
      for (final player in _globalPlayers.values) {
        _abortFades(player);
        player.pause();
      }
      changed = true;
    }

    if (changed) {
      notifyListeners();
    }
  }

  void _handlePlaybackError(AudioPlayer player, Object error) {
    _abortFades(player);
    player.release();

    if (player == _searchPlayer) {
      _hasSearchError = true;
      _isSearchLoading = false;
      _isSearchPlaying = false;
    } else {
      _hasGlobalError = true;
      _isGlobalLoading = false;
    }
    notifyListeners();
  }

  void _abortFades(AudioPlayer player) {
    _fadeTokens[player.playerId] = DateTime.now().millisecondsSinceEpoch;
  }

  Future<void> _fadeOut(
    AudioPlayer player,
    Future<void> Function() action, {
    bool resetVolume = true,
  }) async {
    final token = DateTime.now().millisecondsSinceEpoch;
    _fadeTokens[player.playerId] = token;

    if (player.state == PlayerState.playing) {
      for (int i = MusicConstants.fadeStepCount - 1; i >= 0; i--) {
        if (_fadeTokens[player.playerId] != token) return;
        if (player.state != PlayerState.playing) break;
        try {
          await player.setVolume(i / MusicConstants.fadeStepCount);
          await Future.delayed(
            const Duration(milliseconds: MusicConstants.fadeStepDelayMs),
          );
        } catch (e) {
          _handlePlaybackError(player, e);
          break;
        }
      }
    }

    try {
      if (_fadeTokens[player.playerId] == token) {
        await action();
        if (resetVolume) {
          await player.setVolume(1.0);
        }
      }
    } catch (e) {
      _handlePlaybackError(player, e);
    }
  }

  Future<void> _fadeIn(
    AudioPlayer player,
    Future<void> Function() action,
  ) async {
    final token = DateTime.now().millisecondsSinceEpoch;
    _fadeTokens[player.playerId] = token;

    try {
      await player.setVolume(0.0);
      if (_fadeTokens[player.playerId] != token) return;

      await action();

      for (int i = 1; i <= MusicConstants.fadeStepCount; i++) {
        if (_fadeTokens[player.playerId] != token) return;
        if (player.state != PlayerState.playing) break;
        await Future.delayed(
          const Duration(milliseconds: MusicConstants.fadeStepDelayMs),
        );
        await player.setVolume(i / MusicConstants.fadeStepCount);
      }
    } catch (e) {
      _handlePlaybackError(player, e);
    }
  }

  Future<void> _triggerLoopFade(AudioPlayer player) async {
    _isLoopFadingMap[player.playerId] = true;
    await _fadeOut(player, () async {
      await player.seek(Duration.zero);
    }, resetVolume: false);

    final isActiveGlobal =
        _globalPlayers.values.contains(player) &&
        !_isMuted &&
        _currentGlobalUrl != null;

    if (isActiveGlobal) {
      await _fadeIn(player, () async {
        if (player.state != PlayerState.playing) await player.resume();
      });
    } else {
      await player.pause();
    }

    await Future.delayed(
      const Duration(milliseconds: MusicConstants.loopSettleDelayMs),
    );
    _isLoopFadingMap[player.playerId] = false;
  }

  AudioPlayer _getOrCreateGlobalPlayer(String url) {
    if (_globalPlayers.containsKey(url)) {
      _globalPlayerKeys.remove(url);
      _globalPlayerKeys.add(url);
      return _globalPlayers[url]!;
    }

    if (_globalPlayerKeys.length >= MusicConstants.maxGlobalPlayers) {
      final oldest = _globalPlayerKeys.removeAt(0);
      final oldPlayer = _globalPlayers.remove(oldest);
      oldPlayer?.dispose();
    }

    final player = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
    _globalPlayers[url] = player;
    _globalPlayerKeys.add(url);

    player.onDurationChanged.listen((d) {
      _durations[player.playerId] = d;
    });

    player.onPositionChanged.listen((position) {
      if (_currentGlobalUrl == url &&
          position > Duration.zero &&
          _isGlobalLoading) {
        _isGlobalLoading = false;
        _hasGlobalError = false;
        _globalTimeout?.cancel();
        notifyListeners();
      }

      final d = _durations[player.playerId];
      if (d != null && d.inMilliseconds > 0) {
        final remaining = d.inMilliseconds - position.inMilliseconds;
        if (remaining > 0 &&
            remaining <= MusicConstants.loopFadeThresholdMs &&
            player.state == PlayerState.playing) {
          if (_isLoopFadingMap[player.playerId] != true) {
            _triggerLoopFade(player);
          }
        }
      }
    });

    player.onPlayerComplete.listen((_) {
      if (_currentGlobalUrl == url) {
        _isGlobalLoading = false;
        _hasGlobalError = true;
        notifyListeners();
      }
    });

    return player;
  }

  bool get isMuted => _isMuted;
  String? get currentSearchUrl => _currentSearchUrl;
  bool get isSearchPlaying => _isSearchPlaying;
  bool get isSearchLoading => _isSearchLoading;
  bool get hasSearchError => _hasSearchError;
  bool get isGlobalLoading => _isGlobalLoading;
  bool get hasGlobalError => _hasGlobalError;

  Future<void> _pauseAllGlobalPlayers() async {
    final futures = <Future>[];
    for (final player in _globalPlayers.values) {
      futures.add(_fadeOut(player, () => player.pause()));
    }
    await Future.wait(futures);
  }

  Future<void> _stopAllGlobalPlayers() async {
    final futures = <Future>[];
    for (final player in _globalPlayers.values) {
      futures.add(_fadeOut(player, () => player.stop()));
    }
    await Future.wait(futures);
  }

  Future<void> _playGlobalTrack({bool fade = true}) async {
    if (_currentGlobalUrl == null) return;

    final player = _getOrCreateGlobalPlayer(_currentGlobalUrl!);
    final needsLoading = player.source == null;

    if (needsLoading) {
      _isGlobalLoading = true;
      _hasGlobalError = false;
      _globalTimeout?.cancel();
      notifyListeners();

      _globalTimeout = Timer(
        const Duration(seconds: MusicConstants.audioTimeoutSeconds),
        () {
          if (_currentGlobalUrl != null && _isGlobalLoading) {
            _isGlobalLoading = false;
            _hasGlobalError = true;
            _abortFades(player);
            player.release();
            notifyListeners();
          }
        },
      );
    } else {
      _hasGlobalError = false;
      notifyListeners();
    }

    try {
      if (needsLoading) {
        if (fade) {
          await _fadeIn(
            player,
            () => player.play(UrlSource(_currentGlobalUrl!)),
          );
        } else {
          _abortFades(player);
          await player.setVolume(1.0);
          await player.play(UrlSource(_currentGlobalUrl!));
        }
      } else {
        if (player.state == PlayerState.stopped ||
            player.state == PlayerState.completed) {
          await player.seek(Duration.zero);
        }
        if (fade) {
          await _fadeIn(player, () => player.resume());
        } else {
          _abortFades(player);
          await player.setVolume(1.0);
          await player.resume();
        }
      }
    } catch (e) {
      _globalTimeout?.cancel();
      _handlePlaybackError(player, e);
    }
  }

  Future<void> toggleMute() async {
    if (_hasGlobalError) {
      _hasGlobalError = false;
      if (!_isMuted && _currentGlobalUrl != null) {
        await _playGlobalTrack(fade: false);
      } else {
        notifyListeners();
      }
      return;
    }

    _isMuted = !_isMuted;

    if (_isMuted) {
      final wasLoading = _isGlobalLoading;
      _isGlobalLoading = false;
      _globalTimeout?.cancel();

      final playersList = _globalPlayers.values.toList();
      for (final player in playersList) {
        _abortFades(player);

        final isCurrentLoadingPlayer =
            wasLoading && _globalPlayers[_currentGlobalUrl] == player;

        if (isCurrentLoadingPlayer) {
          await player.release();
        } else {
          try {
            await player.pause();
            await player.setVolume(1.0);
          } catch (e) {
            _handlePlaybackError(player, e);
          }
        }
      }
      notifyListeners();
    } else if (_currentGlobalUrl != null) {
      await _playGlobalTrack(fade: false);
    } else {
      notifyListeners();
    }
  }

  Future<void> setGlobalTrack(String? url) async {
    if (_currentGlobalUrl == url && _currentSearchUrl == null) return;

    _currentGlobalUrl = url;
    _currentSearchUrl = null;
    _isSearchPlaying = false;
    _isSearchLoading = false;
    _hasSearchError = false;
    _searchTimeout?.cancel();

    _isGlobalLoading = false;
    _hasGlobalError = false;
    _globalTimeout?.cancel();

    _abortFades(_searchPlayer);
    await Future.wait([_stopAllGlobalPlayers(), _searchPlayer.release()]);

    if (url != null && !_isMuted) {
      await _playGlobalTrack(fade: true);
    } else {
      notifyListeners();
    }
  }

  void _setupSearchTimeout(String url) {
    _searchTimeout = Timer(
      const Duration(seconds: MusicConstants.audioTimeoutSeconds),
      () {
        if (_currentSearchUrl == url && _isSearchLoading) {
          _isSearchLoading = false;
          _hasSearchError = true;
          _isSearchPlaying = false;
          _abortFades(_searchPlayer);
          _searchPlayer.release();
          notifyListeners();
        }
      },
    );
  }

  Future<void> toggleSearchTrack(String url) async {
    _searchTimeout?.cancel();

    try {
      if (_currentSearchUrl == url) {
        if (_hasSearchError) {
          _hasSearchError = false;
          _isSearchLoading = true;
          _isSearchPlaying = false;
          notifyListeners();

          _setupSearchTimeout(url);
          _abortFades(_searchPlayer);
          await _searchPlayer.release();
          await _pauseAllGlobalPlayers();

          await _searchPlayer.setVolume(1.0);
          await _searchPlayer.play(UrlSource(url));
        } else if (_isSearchPlaying || _isSearchLoading) {
          final wasLoading = _isSearchLoading;
          _isSearchPlaying = false;
          _isSearchLoading = false;
          notifyListeners();

          _abortFades(_searchPlayer);
          if (wasLoading) {
            await _searchPlayer.release();
          } else {
            await _searchPlayer.pause();
            await _searchPlayer.setVolume(1.0);
          }
        } else {
          _isSearchPlaying = true;
          _hasSearchError = false;
          notifyListeners();

          await _pauseAllGlobalPlayers();

          if (_searchPlayer.state == PlayerState.stopped ||
              _searchPlayer.state == PlayerState.completed) {
            await _searchPlayer.seek(Duration.zero);
          }

          await _searchPlayer.setVolume(1.0);
          await _searchPlayer.resume();
        }
      } else {
        _currentSearchUrl = url;
        _isSearchPlaying = false;
        _isSearchLoading = true;
        _hasSearchError = false;
        notifyListeners();

        _setupSearchTimeout(url);

        _abortFades(_searchPlayer);
        await _searchPlayer.release();
        await _pauseAllGlobalPlayers();

        await _searchPlayer.setVolume(1.0);
        await _searchPlayer.play(UrlSource(url));
      }
    } catch (e) {
      _searchTimeout?.cancel();
      _handlePlaybackError(_searchPlayer, e);
    }
  }

  Future<void> clearSearchTrack() async {
    _searchTimeout?.cancel();
    _currentSearchUrl = null;
    _isSearchPlaying = false;
    _isSearchLoading = false;
    _hasSearchError = false;

    _abortFades(_searchPlayer);
    await _searchPlayer.release();
    notifyListeners();
  }

  Future<void> stopSearchTrackAndRestoreGlobal() async {
    if (_currentSearchUrl == null) return;

    _searchTimeout?.cancel();
    _currentSearchUrl = null;
    _isSearchPlaying = false;
    _isSearchLoading = false;
    _hasSearchError = false;

    _abortFades(_searchPlayer);
    await _searchPlayer.release();

    if (_currentGlobalUrl != null && !_isMuted) {
      await _playGlobalTrack(fade: true);
    } else {
      notifyListeners();
    }
  }

  Future<void> stopAll() async {
    _searchTimeout?.cancel();
    _globalTimeout?.cancel();
    _currentGlobalUrl = null;
    _currentSearchUrl = null;
    _isSearchPlaying = false;
    _isSearchLoading = false;
    _hasSearchError = false;
    _isGlobalLoading = false;
    _hasGlobalError = false;

    _abortFades(_searchPlayer);
    await Future.wait([_searchPlayer.release(), _stopAllGlobalPlayers()]);
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchTimeout?.cancel();
    _globalTimeout?.cancel();
    _searchPlayer.dispose();
    for (final player in _globalPlayers.values) {
      player.dispose();
    }
    super.dispose();
  }
}
