import 'package:bot_toast/bot_toast.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:autoquill_ai/features/recording/domain/repositories/recording_repository.dart';
import 'package:autoquill_ai/features/transcription/domain/repositories/transcription_repository.dart';
import '../../../features/recording/data/platform/recording_overlay_platform.dart';
import '../services/clipboard_service.dart';

/// Handler for transcription hotkey functionality
class TranscriptionHotkeyHandler {
  // Flag to track if recording is in progress via hotkey
  static bool _isHotkeyRecordingActive = false;
  
  // Path to the recorded audio file when using hotkey
  static String? _hotkeyRecordedFilePath;
  
  // Repositories for direct access
  static RecordingRepository? _recordingRepository;
  static TranscriptionRepository? _transcriptionRepository;
  
  /// Initialize the handler with necessary repositories
  static void initialize(
    RecordingRepository recordingRepository, 
    TranscriptionRepository transcriptionRepository
  ) {
    _recordingRepository = recordingRepository;
    _transcriptionRepository = transcriptionRepository;
  }
  
  /// Handles the transcription hotkey press
  static void handleHotkey() async {
    if (_recordingRepository == null || _transcriptionRepository == null) {
      BotToast.showText(text: 'Recording system not initialized');
      return;
    }
    
    // Check if API key is available
    final apiKey = Hive.box('settings').get('groq_api_key');
    if (apiKey == null || apiKey.isEmpty) {
      BotToast.showText(text: 'No API key found. Please add your Groq API key in Settings.');
      return;
    }
    
    if (!_isHotkeyRecordingActive) {
      // Start recording directly using the repository
      try {
        await _recordingRepository!.startRecording();
        _isHotkeyRecordingActive = true;
        BotToast.showText(text: 'Recording started');
      } catch (e) {
        BotToast.showText(text: 'Failed to start recording: $e');
      }
    } else {
      // Stop recording and transcribe directly
      try {
        // Stop recording
        _hotkeyRecordedFilePath = await _recordingRepository!.stopRecording();
        _isHotkeyRecordingActive = false;
        BotToast.showText(text: 'Recording stopped, transcribing...');
        
        // Transcribe the audio
        await _transcribeAndCopyToClipboard(_hotkeyRecordedFilePath!, apiKey);
      } catch (e) {
        BotToast.showText(text: 'Error during recording or transcription: $e');
      }
    }
  }
  
  /// Transcribe audio and copy to clipboard without affecting UI
  static Future<void> _transcribeAndCopyToClipboard(String audioPath, String apiKey) async {
    try {
      // Update overlay to show we're processing the audio
      await RecordingOverlayPlatform.setProcessingAudio();
      
      // Transcribe the audio
      final response = await _transcriptionRepository!.transcribeAudio(audioPath, apiKey);
      // Trim any leading/trailing whitespace from the transcription text
      final transcriptionText = response.text.trim();
      
      // Copy to clipboard - this will also update the overlay state to "Transcription copied"
      // and hide the overlay after pasting
      await ClipboardService.copyToClipboard(transcriptionText);
      
      BotToast.showText(text: 'Transcription copied to clipboard');
    } catch (e) {
      // Hide the overlay on error
      await RecordingOverlayPlatform.hideOverlay();
      BotToast.showText(text: 'Transcription failed: $e');
    }
  }
}
