import 'package:audioplayers/audioplayers.dart';

/// Utility class for playing sound effects in the app
class SoundPlayer {
  // Use a single instance of AudioPlayer for all sounds
  static final _player = AudioPlayer();

  // Sound file paths
  static const String _startRecordingSound = 'sounds/marimba_start.mp3';
  static const String _stopRecordingSound = 'sounds/marimba_stop.mp3';
  static const String _typingSound = 'sounds/fast_typing.wav';

  /// Plays the sound for starting a recording
  static Future<void> playStartRecordingSound() async {
    await _player.stop(); // Stop any currently playing sound
    await _player.play(AssetSource(_startRecordingSound));
  }

  /// Plays the sound for stopping a recording
  static Future<void> playStopRecordingSound() async {
    await _player.stop(); // Stop any currently playing sound
    await _player.play(AssetSource(_stopRecordingSound));
  }

  /// Plays the typing sound for paste operations
  static Future<void> playTypingSound() async {
    await _player.stop(); // Stop any currently playing sound
    await _player.play(AssetSource(_typingSound));
  }

  /// Disposes the audio player resources
  static void dispose() {
    _player.dispose();
  }
}
