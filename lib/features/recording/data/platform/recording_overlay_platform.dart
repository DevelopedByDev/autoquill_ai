import 'dart:async';
import 'package:flutter/services.dart';
import '../../presentation/bloc/recording_bloc.dart';

class RecordingOverlayPlatform {
  static const MethodChannel _channel = MethodChannel('com.autoquill.recording_overlay');
  static Timer? _levelUpdateTimer;
  static RecordingBloc? _recordingBloc;

  // Flag to track if any recording is currently in progress
  static bool isRecordingInProgress = false;

  /// Shows the recording overlay
  static Future<void> showOverlay() async {
    // If a recording is already in progress, don't start another one
    if (isRecordingInProgress) {
      print('Recording already in progress, ignoring request to show overlay');
      return;
    }
    
    try {
      // Set up method channel handler for button actions
      _setupMethodHandler();
      
      // Set the flag to indicate a recording is in progress
      isRecordingInProgress = true;
      
      await _channel.invokeMethod('showOverlay');
    } on PlatformException catch (e) {
      print('Failed to show overlay: ${e.message}');
      isRecordingInProgress = false;
    }
  }
  
  /// Shows the recording overlay with a specific mode label
  static Future<void> showOverlayWithMode(String mode) async {
    // If a recording is already in progress, don't start another one
    if (isRecordingInProgress) {
      print('Recording already in progress, ignoring request to show overlay for $mode mode');
      return;
    }
    
    try {
      // Set up method channel handler for button actions
      _setupMethodHandler();
      
      // Set the flag to indicate a recording is in progress
      isRecordingInProgress = true;
      
      await _channel.invokeMethod('showOverlayWithMode', {'mode': mode});
    } on PlatformException catch (e) {
      print('Failed to show overlay with mode: ${e.message}');
      isRecordingInProgress = false;
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
        print('RecordingBloc not set, cannot handle overlay button actions');
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
      await _channel.invokeMethod('hideOverlay');
      // Stop sending audio levels when hiding the overlay
      _stopSendingAudioLevels();
      // Reset the recording in progress flag
      isRecordingInProgress = false;
    } on PlatformException catch (e) {
      print('Failed to hide overlay: ${e.message}');
      // Reset the flag even if there's an error
      isRecordingInProgress = false;
    }
  }
  
  /// Sets the overlay text to "Recording stopped"
  static Future<void> setRecordingStopped() async {
    try {
      await _channel.invokeMethod('setRecordingStopped');
    } on PlatformException catch (e) {
      print('Failed to set recording stopped state: ${e.message}');
    }
  }
  
  /// Sets the overlay text to "Processing audio"
  static Future<void> setProcessingAudio() async {
    try {
      await _channel.invokeMethod('setProcessingAudio');
    } on PlatformException catch (e) {
      print('Failed to set processing audio state: ${e.message}');
    }
  }
  
  /// Sets the overlay text to "Transcription copied"
  static Future<void> setTranscriptionCompleted() async {
    try {
      await _channel.invokeMethod('setTranscriptionCompleted');
    } on PlatformException catch (e) {
      print('Failed to set transcription completed state: ${e.message}');
    }
  }
  
  /// Updates the audio level in the overlay
  static Future<void> updateAudioLevel(double level) async {
    try {
      await _channel.invokeMethod('updateAudioLevel', {'level': level});
    } on PlatformException catch (e) {
      print('Failed to update audio level: ${e.message}');
    }
  }
  
  /// Starts sending periodic audio level updates
  /// The audioLevelProvider function should return the current audio level (0.0 to 1.0)
  static void startSendingAudioLevels(Future<double> Function() audioLevelProvider) {
    // Stop any existing timer
    _stopSendingAudioLevels();
    
    // Start a new timer to send audio levels every 100ms
    _levelUpdateTimer = Timer.periodic(Duration(milliseconds: 100), (timer) async {
      try {
        final level = await audioLevelProvider();
        await updateAudioLevel(level);
      } catch (e) {
        print('Error getting audio level: $e');
      }
    });
  }
  
  /// Stops sending audio level updates
  static void _stopSendingAudioLevels() {
    _levelUpdateTimer?.cancel();
    _levelUpdateTimer = null;
  }
}
