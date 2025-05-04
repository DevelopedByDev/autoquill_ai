import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:keypress_simulator/keypress_simulator.dart';
import 'package:autoquill_ai/features/recording/domain/repositories/recording_repository.dart';
import 'package:autoquill_ai/features/transcription/domain/repositories/transcription_repository.dart';
import 'package:pasteboard/pasteboard.dart';
import '../assistant/clipboard_listener_service.dart';

/// Service to handle agent mode functionality
class AgentService {
  static final AgentService _instance = AgentService._internal();
  
  factory AgentService() {
    return _instance;
  }
  
  AgentService._internal() {
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
  
  /// Handle the agent hotkey press
  Future<void> handleAgentHotkey() async {
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
      print('Agent hotkey pressed');
    }
    
    // If already recording, stop and process
    if (_isRecording) {
      await _stopRecordingAndProcess(apiKey);
      return;
    }
    
    // Not recording yet, so start the text selection process
    BotToast.showText(text: 'Agent mode activated');
    
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
    } catch (e) {
      if (kDebugMode) {
        print('Error simulating paste command: $e');
      }
      BotToast.showText(text: 'Error simulating paste command');
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
    
    try {
      await _recordingRepository!.startRecording();
      _isRecording = true;
      BotToast.showText(text: 'Recording started. Press agent hotkey again to stop.');
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
    if (_recordedFilePath == null) {
      BotToast.showText(text: 'Missing recording');
      return;
    }
    
    try {
      // Transcribe the audio
      final response = await _transcriptionRepository!.transcribeAudio(_recordedFilePath!, apiKey);
      final transcribedText = response.text;
      
      if (kDebugMode) {
        print('Transcribed text: $transcribedText');
      }
      
      // Determine the mode based on whether text was selected
      final String mode = _selectedText == null ? 'generation' : 'context';
      BotToast.showText(text: 'Transcription complete, processing with agent for $mode...');
      
      // Send to Groq API - pass _selectedText as is (can be null)
      await _sendToGroqAPI(transcribedText, _selectedText, apiKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error in transcription: $e');
      }
      BotToast.showText(text: 'Transcription failed: $e');
    }
  }
  
  /// Send the transcribed text and selected text to Groq API
  Future<void> _sendToGroqAPI(String transcribedText, String? selectedText, String apiKey) async {
    try {
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
      
      // Get the selected agent model from settings
      final settingsBox = Hive.box('settings');
      final selectedModel = settingsBox.get('agent-model') ?? 'compound-beta-mini';
      
      // Prepare the message content
      final String content;
      if (selectedText != null) {
        // Context mode - instruction with selected text as context
        content = 'Instruction: $transcribedText\nContext: $selectedText';
      } else {
        // Generation mode - just the instruction
        content = transcribedText;
      }
      
      // Prepare the request body for agent mode
      final requestBody = {
        'model': selectedModel,
        'messages': [
          {
            'role': 'system',
            'content': 'You are an intelligent agent assistant capable of performing tasks, answering questions, and providing real-time search results when necessary. CRITICAL: Your response MUST be structured, factual, and to the point. ABSOLUTELY NO internal thoughts, tool output, "thinking steps", or explanations of what you are doing. Do NOT include any preambles, such as "Sure, I can help with that" or "Searching now...". Do NOT describe tools being used. ONLY return the final answer in clean, ready-to-use format. If structured data is appropriate (e.g. JSON, list, table), use that.'
          },
          {
            'role': 'user',
            'content': 'I will ask you factual questions or request structured data. When responding, DO NOT start with phrases like "Here is", "I found", or "Based on my search". Just respond directly with the result in a clean format.'
          },
          {
            'role': 'assistant',
            'content': 'Understood. I will provide only the final structured result with no preambles or tool-related text.'
          },
          {
            'role': 'user',
            'content': 'IMPORTANT: Your response must begin with the final result only. No internal thoughts, search steps, or commentary. Respond to this prompt: $content'
          },
        ],
        'temperature': 0.2,
        'max_tokens': 2000
      };
      
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
        
        if (kDebugMode) {
          print('Agent Response: $aiResponse');
        }
        
        // Copy the AI response to clipboard using pasteboard for better compatibility
        Pasteboard.writeText(aiResponse);
        
        BotToast.showText(text: 'Agent response copied to clipboard');
        
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
