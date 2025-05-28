import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../presentation/bloc/recording_bloc.dart';

class RecordingOverlayPlatform {
  static const MethodChannel _channel =
      MethodChannel('com.autoquill.recording_overlay');
  static Timer? _levelUpdateTimer;
  static RecordingBloc? _recordingBloc;

  // Flag to track if any recording is currently in progress
  static bool isRecordingInProgress = false;

  /// Shows the recording overlay
  static Future<void> showOverlay() async {
    try {
      // Mark recording as in progress immediately
      isRecordingInProgress = true;
      // Non-blocking overlay show
      _channel.invokeMethod('showOverlay').catchError((e) {
        if (kDebugMode) {
          print('Failed to show overlay: $e');
        }
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Failed to show overlay: ${e.message}');
      }
    }
  }

  /// Shows the recording overlay with a specific mode label
  static Future<void> showOverlayWithMode(String mode) async {
    await showOverlayWithModeAndHotkeys(mode, null, 'Esc');
  }

  /// Shows the recording overlay with a specific mode label and hotkey information
  static Future<void> showOverlayWithModeAndHotkeys(
      String mode, String? finishHotkey, String? cancelHotkey) async {
    try {
      // Mark recording as in progress immediately
      isRecordingInProgress = true;
      // Non-blocking overlay show
      _channel.invokeMethod('showOverlayWithModeAndHotkeys', {
        'mode': mode,
        'finishHotkey': finishHotkey,
        'cancelHotkey': cancelHotkey,
      }).catchError((e) {
        if (kDebugMode) {
          print('Failed to show overlay with mode and hotkeys: $e');
        }
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Failed to show overlay with mode and hotkeys: ${e.message}');
      }
    }
  }

  /// Sets the RecordingBloc instance for handling button actions
  static void setRecordingBloc(RecordingBloc bloc) {
    _recordingBloc = bloc;
  }

  /// Sets up the method channel handler for button actions from the overlay window
  static void _setupMethodHandler() {
    _channel.setMethodCallHandler((call) async {
      if (_recordingBloc == null) {
        if (kDebugMode) {
          print('RecordingBloc not set, cannot handle overlay button actions');
        }
        return;
      }

      switch (call.method) {
        case 'pauseRecording':
          _recordingBloc!.add(PauseRecording());
          break;
        case 'resumeRecording':
          _recordingBloc!.add(ResumeRecording());
          break;
        case 'stopRecording':
          _recordingBloc!.add(StopRecording());
          break;
        case 'restartRecording':
          _recordingBloc!.add(RestartRecording());
          break;
        case 'cancelRecording':
          _recordingBloc!.add(CancelRecording());
          break;
      }
    });
  }

  /// Hides the recording overlay
  static Future<void> hideOverlay() async {
    try {
      // Reset the recording in progress flag immediately
      isRecordingInProgress = false;
      // Stop sending audio levels when hiding the overlay
      _stopSendingAudioLevels();
      // Non-blocking overlay hide
      _channel.invokeMethod('hideOverlay').catchError((e) {
        if (kDebugMode) {
          print('Failed to hide overlay: $e');
        }
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Failed to hide overlay: ${e.message}');
      }
    }
  }

  /// Sets the overlay text to "Recording stopped"
  static Future<void> setRecordingStopped() async {
    try {
      // Non-blocking update
      _channel.invokeMethod('setRecordingStopped').catchError((e) {
        if (kDebugMode) {
          print('Failed to set recording stopped state: $e');
        }
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Failed to set recording stopped state: ${e.message}');
      }
    }
  }

  /// Sets the overlay text to "Processing audio"
  static Future<void> setProcessingAudio() async {
    try {
      // Non-blocking update
      _channel.invokeMethod('setProcessingAudio').catchError((e) {
        if (kDebugMode) {
          print('Failed to set processing audio state: $e');
        }
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Failed to set processing audio state: ${e.message}');
      }
    }
  }

  /// Sets the overlay text to "Transcription copied"
  static Future<void> setTranscriptionCompleted() async {
    try {
      // Non-blocking update
      _channel.invokeMethod('setTranscriptionCompleted').catchError((e) {
        if (kDebugMode) {
          print('Failed to set transcription completed state: $e');
        }
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Failed to set transcription completed state: ${e.message}');
      }
    }
  }

  /// Updates the audio level in the overlay
  static Future<void> updateAudioLevel(double level) async {
    try {
      // Non-blocking update - fire and forget
      _channel
          .invokeMethod('updateAudioLevel', {'level': level}).catchError((e) {
        // Silently ignore errors for audio level updates as they're frequent
      });
    } on PlatformException catch (e) {
      // Silently ignore
    }
  }

  /// Starts sending periodic audio level updates
  /// The audioLevelProvider function should return the current audio level (0.0 to 1.0)
  static void startSendingAudioLevels(
      Future<double> Function() audioLevelProvider) {
    // Stop any existing timer
    _stopSendingAudioLevels();

    // Start a new timer to send audio levels every 200ms (reduced frequency)
    _levelUpdateTimer =
        Timer.periodic(Duration(milliseconds: 200), (timer) async {
      try {
        final level = await audioLevelProvider();
        // Fire and forget the update
        updateAudioLevel(level);
      } catch (e) {
        // Silently ignore errors
      }
    });
  }

  /// Stops sending audio level updates
  static void _stopSendingAudioLevels() {
    _levelUpdateTimer?.cancel();
    _levelUpdateTimer = null;
  }
}
