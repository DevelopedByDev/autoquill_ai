import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Utility class for playing sound effects in the app
class SoundPlayer {
  // Use a single instance of AudioPlayer for all sounds
  static AudioPlayer? _player;
  static bool _initialized = false;
  static bool _isPlaying = false;
  
  // Sound file paths
  static const String _startRecordingSound = 'assets/sounds/marimba_start.mp3';
  static const String _stopRecordingSound = 'assets/sounds/marimba_stop.mp3';
  static const String _typingSound = 'assets/sounds/fast_typing.wav';
  static const String _errorSound = 'assets/sounds/error_sound.mp3';
  
  /// Initialize the audio player
  static Future<bool> _ensureInitialized() async {
    if (_initialized && _player != null) return true;
    
    if (!_initialized) {
      try {
        // Release any existing player first
        _releasePlayer();
        
        // Create a new player
        _player = AudioPlayer();
        _initialized = true;
        return true;
      } catch (e) {
        if (kDebugMode) {
          print('Error initializing audio player: $e');
        }
        _initialized = false;
        _player = null;
        return false;
      }
    }
    
    return _initialized && _player != null;
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
    // Don't try to play if already playing
    if (_isPlaying) return;
    
    _isPlaying = true;
    
    // Use a future to handle the async operations without awaiting
    Future(() async {
      try {
        // Ensure player is initialized
        bool initialized = await _ensureInitialized();
        if (!initialized || _player == null) {
          _isPlaying = false;
          return;
        }
        
        // Stop any currently playing sound
        try {
          await _player!.stop().timeout(
            const Duration(milliseconds: 300),
            onTimeout: () => null,
          );
        } catch (e) {
          // Ignore stop errors
        }
        
        // Set the asset and play without waiting for completion
        _player!.setAsset(assetPath).then((_) {
          _player!.play().then((_) {
            // Reset playing state after a delay
            Future.delayed(const Duration(seconds: 1), () {
              _isPlaying = false;
            });
          }).catchError((_) {
            _isPlaying = false;
          });
        }).catchError((_) {
          _isPlaying = false;
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error playing sound: $e');
        }
        _isPlaying = false;
      }
    });
  }
  
  /// Release the player resources
  static void _releasePlayer() {
    try {
      if (_player != null) {
        try {
          _player!.stop();
        } catch (e) {
          // Ignore stop errors
        }
        
        try {
          _player!.dispose();
        } catch (e) {
          // Ignore dispose errors
        }
        
        _player = null;
      }
      _initialized = false;
      _isPlaying = false;
    } catch (e) {
      if (kDebugMode) {
        print('Error releasing audio player: $e');
      }
      // Ensure variables are reset even if errors occur
      _player = null;
      _initialized = false;
      _isPlaying = false;
    }
  }

  /// Disposes the audio player
  static void dispose() {
    _releasePlayer();
  }
}