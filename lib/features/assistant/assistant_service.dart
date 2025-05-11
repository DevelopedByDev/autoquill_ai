import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:autoquill_ai/core/utils/sound_player.dart';
import '../recording/data/platform/recording_overlay_platform.dart';
import 'package:http/http.dart' as http;
import 'package:keypress_simulator/keypress_simulator.dart';
import 'package:autoquill_ai/features/recording/domain/repositories/recording_repository.dart';
import 'package:autoquill_ai/features/transcription/domain/repositories/transcription_repository.dart';
import 'package:pasteboard/pasteboard.dart';
import 'clipboard_listener_service.dart';

/// Service to handle assistant mode functionality
class AssistantService {
  static final AssistantService _instance = AssistantService._internal();
  
  factory AssistantService() {
    return _instance;
  }
  
  AssistantService._internal() {
    _clipboardListener.init();
  }
  
  // The clipboard listener service
  final ClipboardListenerService _clipboardListener = ClipboardListenerService();
  
  // Repositories for recording and transcription
  RecordingRepository? _recordingRepository;
  TranscriptionRepository? _transcriptionRepository;
  
  // Flag to track if recording is in progress
  bool _isRecording = false;
  
  // Store the selected text from clipboard
  String? _selectedText;
  
  // Path to the recorded audio file
  String? _recordedFilePath;
  
  /// Set the repositories for recording and transcription
  void setRepositories(RecordingRepository recordingRepository, TranscriptionRepository transcriptionRepository) {
    _recordingRepository = recordingRepository;
    _transcriptionRepository = transcriptionRepository;
  }
  
  /// Handle the assistant hotkey press
  Future<void> handleAssistantHotkey() async {
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
    
    if (kDebugMode) {
      print('Assistant hotkey pressed');
    }
    
    // If already recording, stop and process
    if (_isRecording) {
      await _stopRecordingAndProcess(apiKey);
      return;
    }
    
    // Not recording yet, so start the text selection process
    BotToast.showText(text: 'Assistant mode activated');
    
    // Simulate copy command to get selected text
    await _simulateCopyCommand();
    
    // Start watching for clipboard changes
    _clipboardListener.startWatching(
      onTextChanged: _handleSelectedText,
      onTimeout: _handleTimeout,
      onEmpty: _handleEmptyClipboard,
    );
  }
  
  /// Simulate copy command (Meta + C)
  Future<void> _simulateCopyCommand() async {
    try {
      // Simulate key down for Meta + C
      await keyPressSimulator.simulateKeyDown(
        PhysicalKeyboardKey.keyC,
        [ModifierKey.metaModifier],
      );
      
      // Simulate key up for Meta + C
      await keyPressSimulator.simulateKeyUp(
        PhysicalKeyboardKey.keyC,
        [ModifierKey.metaModifier],
      );
      
      if (kDebugMode) {
        print('Copy command simulated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error simulating copy command: $e');
      }
      BotToast.showText(text: 'Error simulating copy command');
    }
  }
  
  /// Simulate paste command (Meta + V)
  Future<void> _simulatePasteCommand() async {
    try {
      // Play typing sound for paste operation
      await SoundPlayer.playTypingSound();
      
      // Simulate key down for Meta + V
      await keyPressSimulator.simulateKeyDown(
        PhysicalKeyboardKey.keyV,
        [ModifierKey.metaModifier],
      );
      
      // Simulate key up for Meta + V
      await keyPressSimulator.simulateKeyUp(
        PhysicalKeyboardKey.keyV,
        [ModifierKey.metaModifier],
      );
      
      if (kDebugMode) {
        print('Paste command simulated');
      }
      
      // Now that we've pasted the text, hide the overlay
      await RecordingOverlayPlatform.hideOverlay();
    } catch (e) {
      if (kDebugMode) {
        print('Error simulating paste command: $e');
      }
      // Play error sound
      await SoundPlayer.playErrorSound();
      BotToast.showText(text: 'Error simulating paste command');
      
      // Hide the overlay even if there's an error
      await RecordingOverlayPlatform.hideOverlay();
    }
  }
  
  /// Handle the selected text from clipboard
  Future<void> _handleSelectedText(String text) async {
    if (kDebugMode) {
      print('Selected text: ${text.length} characters');
    }
    
    // Store the selected text
    _selectedText = text;
    
    // Show toast with the length of selected text
    BotToast.showText(text: 'Selected ${text.length} characters. Recording instructions...');
    
    // Start recording the user's speech
    await _startRecording();
  }
  
  /// Handle timeout when no clipboard changes are detected
  Future<void> _handleTimeout() async {
    if (kDebugMode) {
      print('Clipboard change timeout');
    }
    
    BotToast.showText(text: 'No text selected. Recording instructions for generation...');
    
    // Set selected text to null to indicate generation-only mode
    _selectedText = null;
    
    // Start recording the user's speech
    await _startRecording();
  }
  
  /// Handle empty clipboard
  Future<void> _handleEmptyClipboard() async {
    if (kDebugMode) {
      print('Clipboard is empty');
    }
    
    BotToast.showText(text: 'No text selected. Recording instructions for generation...');
    
    // Set selected text to null to indicate generation-only mode
    _selectedText = null;
    
    // Start recording the user's speech
    await _startRecording();
  }
  
  /// Start recording the user's speech
  Future<void> _startRecording() async {
    if (_recordingRepository == null) {
      BotToast.showText(text: 'Recording system not initialized');
      return;
    }
    
    // Check if any recording is already in progress
    if (RecordingOverlayPlatform.isRecordingInProgress) {
      BotToast.showText(text: 'Another recording is already in progress');
      return;
    }
    
    try {
      // Play the start recording sound
      await SoundPlayer.playStartRecordingSound();
      
      // Show the overlay with the assistant mode
      await RecordingOverlayPlatform.showOverlayWithMode('Assistant');
      await _recordingRepository!.startRecording();
      _isRecording = true;
      BotToast.showText(text: 'Recording started. Press assistant hotkey again to stop.');
    } catch (e) {
      if (kDebugMode) {
        print('Error starting recording: $e');
      }
      // Play error sound
      await SoundPlayer.playErrorSound();
      BotToast.showText(text: 'Failed to start recording');
      await RecordingOverlayPlatform.hideOverlay();
    }
  }
  
  /// Stop recording and process the audio
  Future<void> _stopRecordingAndProcess(String apiKey) async {
    if (!_isRecording || _recordingRepository == null || _transcriptionRepository == null) {
      return;
    }
    
    try {
      // Play the stop recording sound
      await SoundPlayer.playStopRecordingSound();
      
      // Stop recording
      _recordedFilePath = await _recordingRepository!.stopRecording();
      _isRecording = false;
      BotToast.showText(text: 'Recording stopped, transcribing...');
      
      // Transcribe the audio
      await _transcribeAndProcess(apiKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping recording: $e');
      }
      // Play error sound
      await SoundPlayer.playErrorSound();
      BotToast.showText(text: 'Error processing recording');
    }
  }
  
  /// Transcribe the audio and process with Groq API
  Future<void> _transcribeAndProcess(String apiKey) async {
    if (_recordedFilePath == null) {
      BotToast.showText(text: 'Missing recording');
      // Hide the overlay since we can't proceed
      await RecordingOverlayPlatform.hideOverlay();
      return;
    }
    
    try {
      // Update overlay to show we're processing the audio
      await RecordingOverlayPlatform.setProcessingAudio();
      
      // Transcribe the audio
      final response = await _transcriptionRepository!.transcribeAudio(_recordedFilePath!, apiKey);
      final transcribedText = response.text;
      
      if (kDebugMode) {
        print('Transcribed text: $transcribedText');
      }
      
      // Update overlay to show transcription is complete
      await RecordingOverlayPlatform.setTranscriptionCompleted();
      
      // Determine the mode based on whether text was selected
      final String mode = _selectedText == null ? 'generation' : 'editing';
      BotToast.showText(text: 'Transcription complete, processing with AI for $mode...');
      
      // Send to Groq API - pass _selectedText as is (can be null)
      await _sendToGroqAPI(transcribedText, _selectedText, apiKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error in transcription: $e');
      }
      // Hide the overlay on error
      await RecordingOverlayPlatform.hideOverlay();
      BotToast.showText(text: 'Transcription failed: $e');
    }
  }
  
  /// Send the transcribed text and selected text to Groq API
  Future<void> _sendToGroqAPI(String transcribedText, String? selectedText, String apiKey) async {
    try {
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
      
      // Prepare the message content
      final String content;
      if (selectedText != null) {
        // Edit mode - instruction followed by text to edit
        content = '$transcribedText: $selectedText';
      } else {
        // Generation mode - just the instruction
        content = transcribedText;
      }
      
      // Prepare the request body
      final Map<String, dynamic> requestBody;
      
      // Get the selected assistant model from settings
      final settingsBox = Hive.box('settings');
      final selectedModel = settingsBox.get('assistant-model') ?? 'llama3-70b-8192';
      
      if (selectedText != null) {
        // Edit mode - use system prompt for text editing
        requestBody = {
          'model': selectedModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a text editor that rewrites text based on instructions. CRITICAL: Your response MUST contain ONLY the edited text with ABSOLUTELY NO introductory phrases, NO explanations, NO "Here is the rewritten text", NO comments about what you did, and NO concluding remarks. Do not start with "Here", "I", or any other introductory word. Just give the edited text directly. The user will only see your exact output, so it must be ready to use immediately.'
            },
            {
              'role': 'user',
              'content': 'I will give you instructions followed by text to edit. The format will be "[INSTRUCTIONS]: [TEXT]". Only return the edited text with no additional comments or explanations. Do not start with "Here", "I", or any other introductory word or phrase.'
            },
            {
              'role': 'assistant',
              'content': 'I understand. I will only return the edited text with no additional comments or explanations.'
            },
            {
              'role': 'user',
              'content': 'IMPORTANT: Your response must start with the edited text directly. Do not include any preamble like "Here is" or "I have". $content'
            }, 
          ],
          'temperature': 0.2, // Even lower temperature for more predictable output
          'max_tokens': 2000 // Ensure we have enough tokens for the response
        };
      } else {
        // Generation mode - use system prompt for text generation
        requestBody = {
          'model': selectedModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful text generation assistant. CRITICAL: Your response MUST contain ONLY the generated text with ABSOLUTELY NO introductory phrases, NO explanations, NO "Here is the text", NO comments about what you did, and NO concluding remarks. Do not start with "Here", "I", or any other introductory word. Just give the generated text directly. The user will only see your exact output, so it must be ready to use immediately.'
            },
            {
              'role': 'user',
              'content': 'I will give you instructions for generating text. Only return the generated text with no additional comments or explanations. Do not start with "Here", "I", or any other introductory word or phrase.'
            },
            {
              'role': 'assistant',
              'content': 'I understand. I will only return the generated text with no additional comments or explanations.'
            },
            {
              'role': 'user',
              'content': 'IMPORTANT: Your response must start with the generated text directly. Do not include any preamble like "Here is" or "I have". $content'
            }, 
          ],
          'temperature': 0.2, // Even lower temperature for more predictable output
          'max_tokens': 2000 // Ensure we have enough tokens for the response
        };
      }
      
      // Encode the final body
      final body = jsonEncode(requestBody);
      
      // Send the request
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: body,
      );
      
      if (response.statusCode == 200) {
        // Extract the AI response from the JSON response
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        var aiResponse = jsonResponse['choices'][0]['message']['content'];

        // print(aiResponse);
        
        // Post-process the response to remove common preambles
        // aiResponse = _cleanAIResponse(aiResponse);
        
        if (kDebugMode) {
          print('AI Response: $aiResponse');
        }
        
        // Copy the AI response to clipboard using pasteboard for better compatibility
        Pasteboard.writeText(aiResponse);
        
        BotToast.showText(text: 'AI response copied to clipboard');
        
        // Simulate paste command after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        await _simulatePasteCommand();
      } else {
        if (kDebugMode) {
          print('API Error: ${response.statusCode} ${response.body}');
        }
        BotToast.showText(text: 'API Error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending to API: $e');
      }
      BotToast.showText(text: 'Error sending to API: $e');
    }
  }
  
  /// Dispose of the service
  void dispose() {
    _clipboardListener.dispose();
  }
}
