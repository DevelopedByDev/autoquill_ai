import 'dart:async';
import 'package:flutter/services.dart';
import '../../presentation/bloc/recording_bloc.dart';

class RecordingOverlayPlatform {
  static const MethodChannel _channel = MethodChannel('com.autoquill.recording_overlay');
  static Timer? _levelUpdateTimer;
  static RecordingBloc? _recordingBloc;

  /// Shows the recording overlay
  static Future<void> showOverlay() async {
    try {
      // Set up method channel handler for button actions
      _setupMethodHandler();
      
      await _channel.invokeMethod('showOverlay');
    } on PlatformException catch (e) {
      print('Failed to show overlay: ${e.message}');
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
    } on PlatformException catch (e) {
      print('Failed to hide overlay: ${e.message}');
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
