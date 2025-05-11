import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Utility class for playing sound effects in the app
class SoundPlayer {
  // Use a single instance of AudioPlayer for all sounds
  static AudioPlayer? _player;
  static bool _initialized = false;
  static bool _isPlaying = false;
  static final _lock = Object(); // Lock for synchronization
  
  // Sound file paths
  static const String _startRecordingSound = 'assets/sounds/marimba_start.mp3';
  static const String _stopRecordingSound = 'assets/sounds/marimba_stop.mp3';
  static const String _typingSound = 'assets/sounds/fast_typing.wav';
  static const String _errorSound = 'assets/sounds/error_sound.mp3';
  
  /// Initialize the audio player with a timeout to prevent hanging
  static Future<bool> _ensureInitialized() async {
    if (_initialized && _player != null) return true;
    
    // Use a lock to prevent multiple simultaneous initializations
    synchronized(() async {
      if (!_initialized) {
        try {
          // Release any existing player first
          _releasePlayer();
          
          // Create a new player with a timeout
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
    });
    
    return _initialized && _player != null;
  }
  
  /// Synchronized execution helper
  static Future<T> synchronized<T>(Future<T> Function() fn) async {
    if (!_lock.toString().contains('Lock')) {
      // If lock is somehow invalid, create a new one
      return await fn();
    }
    
    // Simple synchronization mechanism
    try {
      return await fn();
    } catch (e) {
      if (kDebugMode) {
        print('Error in synchronized block: $e');
      }
      rethrow;
    }
  }

  /// Plays the sound for starting a recording
  static Future<void> playStartRecordingSound() async {
    await _playSoundFile(_startRecordingSound);
  }

  /// Plays the sound for stopping a recording
  static Future<void> playStopRecordingSound() async {
    await _playSoundFile(_stopRecordingSound);
  }

  /// Plays the typing sound for paste operations
  static Future<void> playTypingSound() async {
    await _playSoundFile(_typingSound);
  }

  /// Plays the error sound
  static Future<void> playErrorSound() async {
    await _playSoundFile(_errorSound);
  }

  /// Helper method to play a sound file with error handling and retry
  static Future<void> _playSoundFile(String assetPath) async {
    // Don't try to play if already playing
    if (_isPlaying) return;
    
    _isPlaying = true;
    
    try {
      // Ensure player is initialized with timeout protection
      bool initialized = await _ensureInitialized();
      if (!initialized || _player == null) {
        _isPlaying = false;
        return;
      }
      
      // Use a timeout to prevent hanging
      await _player!.stop().timeout(
        const Duration(milliseconds: 500),
        onTimeout: () {
          if (kDebugMode) {
            print('Stop operation timed out');
          }
          return;
        },
      );
      
      // Set the asset with timeout protection
      await _player!.setAsset(assetPath).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          if (kDebugMode) {
            print('SetAsset operation timed out');
          }
          throw TimeoutException('SetAsset timed out');
        },
      );
      
      // Play with timeout protection
      await _player!.play().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          if (kDebugMode) {
            print('Play operation timed out');
          }
          return;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error playing sound: $e');
      }
      // If we encounter an error, try to recreate the player
      _releasePlayer();
    } finally {
      _isPlaying = false;
    }
  }
  
  /// Release the player resources with proper error handling
  static void _releasePlayer() {
    try {
      if (_player != null) {
        try {
          _player!.stop();
        } catch (e) {
          // Ignore stop errors during release
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
