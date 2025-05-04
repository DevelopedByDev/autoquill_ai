import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:keypress_simulator/keypress_simulator.dart';
import 'package:autoquill_ai/features/recording/domain/repositories/recording_repository.dart';
import 'package:autoquill_ai/features/transcription/domain/repositories/transcription_repository.dart';
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
  void _handleTimeout() {
    if (kDebugMode) {
      print('Clipboard change timeout');
    }
    
    BotToast.showText(text: 'No text was selected');
  }
  
  /// Handle empty clipboard
  void _handleEmptyClipboard() {
    if (kDebugMode) {
      print('Clipboard is empty');
    }
    
    BotToast.showText(text: 'No text was selected');
  }
  
  /// Start recording the user's speech
  Future<void> _startRecording() async {
    if (_recordingRepository == null) {
      BotToast.showText(text: 'Recording system not initialized');
      return;
    }
    
    try {
      await _recordingRepository!.startRecording();
      _isRecording = true;
      BotToast.showText(text: 'Recording started. Press assistant hotkey again to stop.');
    } catch (e) {
      if (kDebugMode) {
        print('Error starting recording: $e');
      }
      BotToast.showText(text: 'Failed to start recording');
    }
  }
  
  /// Stop recording and process the audio
  Future<void> _stopRecordingAndProcess(String apiKey) async {
    if (!_isRecording || _recordingRepository == null || _transcriptionRepository == null) {
      return;
    }
    
    try {
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
      BotToast.showText(text: 'Error processing recording');
    }
  }
  
  /// Transcribe the audio and process with Groq API
  Future<void> _transcribeAndProcess(String apiKey) async {
    if (_recordedFilePath == null || _selectedText == null) {
      BotToast.showText(text: 'Missing recording or selected text');
      return;
    }
    
    try {
      // Transcribe the audio
      final response = await _transcriptionRepository!.transcribeAudio(_recordedFilePath!, apiKey);
      final transcribedText = response.text;
      
      if (kDebugMode) {
        print('Transcribed text: $transcribedText');
      }
      
      BotToast.showText(text: 'Transcription complete, processing with AI...');
      
      // Send to Groq API
      await _sendToGroqAPI(transcribedText, _selectedText!, apiKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error in transcription: $e');
      }
      BotToast.showText(text: 'Transcription failed: $e');
    }
  }
  
  /// Send the transcribed text and selected text to Groq API
  Future<void> _sendToGroqAPI(String transcribedText, String selectedText, String apiKey) async {
    try {
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
      
      // Prepare the message content
      final content = '$transcribedText: $selectedText';
      
      // Prepare the request body
      final body = jsonEncode({
        'model': 'llama3-70b-8192',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a helpful assistant that can rewrite text based on the user input instructions. Your output should not include any comments, not even "Here is the rewritten text" or anything like that. Just the edited text please'
          },
          {
            'role': 'assistant',
            'content': 'Your job is to filter out any comments, any "Here is the rewritten text" or anything like that. Output only the edited text.'
          },
          {
            'role': 'user',
            'content': content
          }, 
        ]
      });
      
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
        // Parse the response
        final jsonResponse = jsonDecode(response.body);
        final aiResponse = jsonResponse['choices'][0]['message']['content'];
        
        if (kDebugMode) {
          print('AI Response: $aiResponse');
        }
        
        // Copy the AI response to clipboard
        Clipboard.setData(ClipboardData(text: aiResponse));
        
        BotToast.showText(text: 'AI response copied to clipboard');
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
