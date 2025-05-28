import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Utility class for playing sound effects in the app
class SoundPlayer {
  // Use multiple AudioPlayers for concurrent playback
  static final Map<String, AudioPlayer> _players = {};
  static bool _initialized = false;

  // Sound file paths
  static const String _startRecordingSound = 'assets/sounds/marimba_start.mp3';
  static const String _stopRecordingSound = 'assets/sounds/marimba_stop.mp3';
  static const String _typingSound = 'assets/sounds/fast_typing.wav';
  static const String _errorSound = 'assets/sounds/error_sound.mp3';

  // List of all sounds to preload
  static const List<String> _allSounds = [
    _startRecordingSound,
    _stopRecordingSound,
    _typingSound,
    _errorSound,
  ];

  /// Initialize and preload all audio players
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Create and preload players for each sound
      for (final sound in _allSounds) {
        final player = AudioPlayer();
        await player.setAsset(sound);
        await player.load(); // Preload the audio
        _players[sound] = player;
      }

      _initialized = true;
      if (kDebugMode) {
        print('Sound players initialized and preloaded');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing sound players: $e');
      }
      _initialized = false;
    }
  }

  /// Ensure sounds are initialized
  static Future<bool> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
    return _initialized;
  }

  /// Plays the sound for starting a recording
  static Future<void> playStartRecordingSound() async {
    _playSoundFile(_startRecordingSound);
  }

  /// Plays the sound for stopping a recording
  static Future<void> playStopRecordingSound() async {
    _playSoundFile(_stopRecordingSound);
  }

  /// Plays the typing sound for paste operations
  static Future<void> playTypingSound() async {
    _playSoundFile(_typingSound);
  }

  /// Plays the error sound
  static Future<void> playErrorSound() async {
    _playSoundFile(_errorSound);
  }

  /// Helper method to play a sound file with error handling
  /// Note: This method does not use await to avoid blocking the UI
  static void _playSoundFile(String assetPath) {
    // Use a future to handle the async operations without awaiting
    Future(() async {
      try {
        // Ensure players are initialized
        if (!await _ensureInitialized()) {
          return;
        }

        final player = _players[assetPath];
        if (player == null) {
          if (kDebugMode) {
            print('Player not found for sound: $assetPath');
          }
          return;
        }

        // Seek to beginning and play
        await player.seek(Duration.zero);
        player.play().catchError((e) {
          if (kDebugMode) {
            print('Error playing sound: $e');
          }
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error playing sound: $e');
        }
      }
    });
  }

  /// Release all player resources
  static void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
    _initialized = false;
  }
}
