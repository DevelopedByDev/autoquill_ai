import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:autoquill_ai/core/utils/sound_player.dart';
import 'package:autoquill_ai/core/stats/stats_service.dart';
import '../recording/data/platform/recording_overlay_platform.dart';
import 'package:http/http.dart' as http;
import 'package:keypress_simulator/keypress_simulator.dart';
import 'package:autoquill_ai/features/recording/domain/repositories/recording_repository.dart';
import 'package:autoquill_ai/features/transcription/domain/repositories/transcription_repository.dart';
import 'package:pasteboard/pasteboard.dart';
import '../accessibility/domain/repositories/accessibility_repository.dart';
import 'clipboard_listener_service.dart';

/// Service to handle assistant mode functionality
class AssistantService {
  static final AssistantService _instance = AssistantService._internal();
  
  factory AssistantService() {
    return _instance;
  }
  
  AssistantService._internal() {
    _clipboardListenerService.init();
    // Initialize stats service without awaiting to avoid blocking constructor
    _initStats();
  }
  
  // Initialize stats service asynchronously
  Future<void> _initStats() async {
    try {
      await _statsService.init();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing stats service: $e');
      }
    }
  }
  
  // Stats service for tracking word counts
  final StatsService _statsService = StatsService();
  
  // Flag to track if clipboard listener is active
  bool _isListening = false; // Used in handleAssistantHotkey()
  
  // Clipboard listener service
  final _clipboardListenerService = ClipboardListenerService();
  
  // Repositories
  RecordingRepository? _recordingRepository;
  TranscriptionRepository? _transcriptionRepository;
  
  // Accessibility repository for OCR-based text extraction
  final _accessibilityRepository = AccessibilityRepository();
  
  // Flag to track if recording is in progress
  bool _isRecording = false;
  
  // Selected text from clipboard
  String? _selectedText;
  
  // Path to the recorded audio file
  String? _recordedFilePath;
  
  // Recording start time for tracking duration
  DateTime? _recordingStartTime;
  
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
    _clipboardListenerService.startWatching(
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
      _recordingStartTime = DateTime.now();
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
      
      // Calculate recording duration
      if (_recordingStartTime != null) {
        try {
          final recordingDuration = DateTime.now().difference(_recordingStartTime!);
          await _statsService.addTranscriptionTime(recordingDuration.inSeconds);
        } catch (e) {
          if (kDebugMode) {
            print('Error updating transcription time in assistant service: $e');
          }
          // Fallback to direct Hive update if the stats service fails
          try {
            if (Hive.isBoxOpen('stats')) {
              final box = Hive.box('stats');
              final currentTime = box.get('transcription_time_seconds', defaultValue: 0);
              box.put('transcription_time_seconds', currentTime + DateTime.now().difference(_recordingStartTime!).inSeconds);
            }
          } catch (_) {}
        } finally {
          _recordingStartTime = null;
        }
      }
      
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
      String? contextText;
      
      // Extract visible text from the active application screen using OCR (macOS only)
      if (Platform.isMacOS) {
        try {
          BotToast.showText(text: 'Capturing screen for context...');
          contextText = await _accessibilityRepository.extractVisibleText();
          if (kDebugMode) {
            print('Extracted context from screen: $contextText');
          }
          
          if (contextText.contains('Error:')) {
            BotToast.showText(
              text: 'Could not capture screen content. Using only selected text.',
              duration: const Duration(seconds: 3),
            );
          } else {
            BotToast.showText(
              text: 'Successfully captured screen content for context.',
              duration: const Duration(seconds: 2),
            );
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error extracting visible text: $e');
          }
          BotToast.showText(
            text: 'Error capturing screen content: ${e.toString()}',
            duration: const Duration(seconds: 3),
          );
        }
      }
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
        final List<Map<String, String>> messages = [
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
          }
        ];
        
        // Add context from screen if available
        if (contextText != null && contextText.isNotEmpty && !contextText.contains('Error:')) {
          messages.add({
            'role': 'user',
            'content': 'Here is some additional context from what is visible on my screen. Use this to inform your edits if relevant:\n\n$contextText. If there are names, dates, emails, pay extra attention as they may be relevant to the instructions.'
          });
          
          messages.add({
            'role': 'assistant',
            'content': 'I understand the context from your screen. I will use it to inform my edits if relevant.'
          });
        }
        
        // Add the final user instruction with content
        messages.add({
          'role': 'user',
          'content': 'IMPORTANT: Your response must start with the edited text directly. Do not include any preamble like "Here is" or "I have". $content'
        });
        
        requestBody = {
          'model': selectedModel,
          'messages': messages,
          'temperature': 0.2, // Even lower temperature for more predictable output
          'max_tokens': 2000 // Ensure we have enough tokens for the response
        };
      } else {
        // Generation mode - use system prompt for text generation
        final List<Map<String, String>> messages = [
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
          }
        ];
        
        // Add context from screen if available
        if (contextText != null && contextText.isNotEmpty && !contextText.contains('Error:')) {
          messages.add({
            'role': 'user',
            'content': 'Here is some additional context from what is visible on my screen. Use this to inform your response if relevant:\n\n$contextText. If there are names, dates, emails, pay extra attention as they may be relevant to the instructions.'
          });
          
          messages.add({
            'role': 'assistant',
            'content': 'I understand the context from your screen. I will use it to inform my response if relevant.'
          });
        }
        
        // Add the final user instruction with content
        messages.add({
          'role': 'user',
          'content': 'IMPORTANT: Your response must start with the generated text directly. Do not include any preamble like "Here is" or "I have". $content'
        });
        
        requestBody = {
          'model': selectedModel,
          'messages': messages,
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
        
        // Hide the overlay
        await RecordingOverlayPlatform.hideOverlay();
        
        // Now that the overlay is hidden, update word counts using StatsService
        try {
          // Update transcription words
          if (transcribedText.isNotEmpty) {
            await _statsService.addTranscriptionWords(transcribedText);
          }
          
          // Update generated words
          if (aiResponse.isNotEmpty) {
            await _statsService.addGenerationWords(aiResponse);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error updating word counts in assistant service: $e');
          }
          
          // Fallback: Update directly in the stats box
          try {
            // Ensure stats box is open
            if (!Hive.isBoxOpen('stats')) {
              await Hive.openBox('stats');
            }
            
            final box = Hive.box('stats');
            
            // Update transcription words
            if (transcribedText.isNotEmpty) {
              final transcriptionWordCount = transcribedText.trim().split(RegExp(r'\s+')).length;
              final currentTranscriptionCount = box.get('transcription_words_count', defaultValue: 0);
              box.put('transcription_words_count', currentTranscriptionCount + transcriptionWordCount);
            }
            
            // Update generated words
            if (aiResponse.isNotEmpty) {
              final generationWordCount = aiResponse.trim().split(RegExp(r'\s+')).length;
              final currentGenerationCount = box.get('generation_words_count', defaultValue: 0);
              box.put('generation_words_count', currentGenerationCount + generationWordCount);
            }
          } catch (boxError) {
            if (kDebugMode) {
              print('Error updating word counts directly in stats box: $boxError');
            }
          }
        }
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
    _clipboardListenerService.dispose();
  }
}
