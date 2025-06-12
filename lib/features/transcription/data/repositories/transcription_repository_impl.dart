import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../datasources/transcription_local_datasource.dart';
import '../../domain/repositories/transcription_repository.dart';
import '../models/transcription_response.dart';
import '../../../recording/utils/audio_utils.dart';
import '../../../../core/services/whisper_kit_service.dart';

class TranscriptionRepositoryImpl implements TranscriptionRepository {
  final TranscriptionLocalDataSource localDataSource;
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/audio/transcriptions';

  // Static HTTP client for connection pooling
  static final http.Client _httpClient = http.Client();

  // Optimized timeout durations
  static const Duration _connectionTimeout = Duration(seconds: 10);
  static const Duration _responseTimeout = Duration(seconds: 60);

  TranscriptionRepositoryImpl({required this.localDataSource});

  @override
  Future<TranscriptionResponse> transcribeAudio(
      String audioPath, String apiKey) async {
    // Start timing for performance monitoring
    final stopwatch = Stopwatch()..start();

    // Validate the audio file before attempting transcription
    final file = File(audioPath);
    if (!await file.exists()) {
      throw Exception('Audio file not found');
    }

    // Check file size to ensure it's not empty
    final fileSize = await file.length();
    if (fileSize < 100) {
      // Arbitrary minimum size for a valid audio file
      throw Exception('Audio file is too small or empty');
    }

    // Use AudioUtils to validate the file
    if (!await AudioUtils.validateAudioFile(audioPath)) {
      if (kDebugMode) {
        print('Audio file validation failed: $audioPath');
      }
      throw Exception('Invalid audio file format');
    }

    // Get settings to check local transcription preference
    final settingsBox = Hive.box('settings');

    // Check if local transcription is enabled
    final localTranscriptionEnabled = settingsBox
        .get('local_transcription_enabled', defaultValue: false) as bool;

    if (localTranscriptionEnabled) {
      // Check if the selected model is initialized
      final selectedLocalModel = settingsBox.get('selected_local_model',
          defaultValue: 'base') as String;

      final isModelInitialized =
          await WhisperKitService.isModelInitialized(selectedLocalModel);

      if (isModelInitialized) {
        // Use local WhisperKit transcription
        if (kDebugMode) {
          print(
              'Using local transcription - model $selectedLocalModel is initialized');
        }
        return await _transcribeAudioLocally(audioPath, settingsBox, stopwatch);
      } else {
        // Model not initialized yet, fall back to cloud if API key is available
        if (kDebugMode) {
          print(
              'Model $selectedLocalModel not initialized yet, falling back to cloud transcription');
        }
        return await _transcribeAudioRemotely(
            audioPath, apiKey, settingsBox, stopwatch);
      }
    } else {
      // Use remote API transcription
      return await _transcribeAudioRemotely(
          audioPath, apiKey, settingsBox, stopwatch);
    }
  }

  /// Transcribe audio using local WhisperKit models
  Future<TranscriptionResponse> _transcribeAudioLocally(
      String audioPath, Box settingsBox, Stopwatch stopwatch) async {
    if (kDebugMode) {
      print('Using local transcription with WhisperKit');
    }

    // Get the selected local model
    final selectedLocalModel =
        settingsBox.get('selected_local_model', defaultValue: 'base') as String;

    if (kDebugMode) {
      print('Local transcription using model: $selectedLocalModel');
    }

    try {
      // Check if the selected model is downloaded
      final isModelDownloaded =
          await WhisperKitService.isModelDownloaded(selectedLocalModel);
      if (!isModelDownloaded) {
        throw Exception(
            'Selected model "$selectedLocalModel" is not downloaded. Please download it first.');
      }

      // Transcribe using WhisperKit
      final transcriptionText = await WhisperKitService.transcribeAudio(
          audioPath, selectedLocalModel);

      // Log performance metrics
      stopwatch.stop();
      if (kDebugMode) {
        print(
            'Local transcription completed in ${stopwatch.elapsedMilliseconds}ms');
      }

      final transcription = TranscriptionResponse(
        text: transcriptionText,
        xGroq: GroqMetadata(id: 'local-whisperkit-$selectedLocalModel'),
      );

      // Save the transcription locally (non-blocking)
      saveTranscription(audioPath, transcription.text).catchError((e) {
        if (kDebugMode) {
          print('Error saving transcription locally: $e');
        }
      });

      return transcription;
    } catch (e) {
      throw Exception('Local transcription failed: $e');
    }
  }

  /// Transcribe audio using remote API (original implementation)
  Future<TranscriptionResponse> _transcribeAudioRemotely(String audioPath,
      String apiKey, Box settingsBox, Stopwatch stopwatch) async {
    if (kDebugMode) {
      print('Using remote API transcription');
    }

    // Load selected languages
    final List<dynamic>? savedLanguagesList =
        settingsBox.get('selected_languages');
    String selectedModel;

    if (kDebugMode) {
      print('Raw saved languages list: $savedLanguagesList');
    }

    if (savedLanguagesList != null) {
      // Check if ONLY English is selected
      bool isOnlyEnglishSelected = false;

      if (savedLanguagesList.length == 1) {
        final langData = savedLanguagesList.first;
        if (langData is Map && langData['code'] == 'en') {
          isOnlyEnglishSelected = true;
        }
      }

      if (kDebugMode) {
        print('Is only English selected: $isOnlyEnglishSelected');
      }

      // Simplified model selection logic:
      // Only use English-only model if ONLY English is selected
      // Use multilingual model for all other cases
      if (isOnlyEnglishSelected) {
        selectedModel = 'distil-whisper-large-v3-en';
        if (kDebugMode) {
          print(
              'Using English-only model: $selectedModel (only English selected)');
        }
      } else {
        selectedModel = 'whisper-large-v3-turbo';
        if (kDebugMode) {
          print(
              'Using multilingual model: $selectedModel (auto-detect or multiple/non-English languages)');
        }
      }
    } else {
      // Legacy format fallback
      final selectedLanguageCode =
          settingsBox.get('selected_language_code') ?? '';
      selectedModel = selectedLanguageCode == 'en'
          ? 'distil-whisper-large-v3-en'
          : 'whisper-large-v3-turbo';

      if (kDebugMode) {
        print(
            'Using legacy format - Language: $selectedLanguageCode, Model: $selectedModel');
      }
    }

    // Get dictionary words from settings
    final List<dynamic>? storedDictionary = settingsBox.get('dictionary');
    String? prompt;

    // If dictionary has words, create a prompt string with them
    if (storedDictionary != null && storedDictionary.isNotEmpty) {
      final List<String> dictionary = storedDictionary.cast<String>().toList();
      // Join dictionary words with commas to create a prompt
      prompt = 'Vocabulary: ${dictionary.join(', ')}.';
    }

    // Log file information for debugging
    if (kDebugMode) {
      print('Transcribing file: $audioPath');
      final file = File(audioPath);
      print('File size: ${await file.length()} bytes');
      print('Model: $selectedModel');
    }

    // Create the API request with optimized settings
    final request = http.MultipartRequest('POST', Uri.parse(_baseUrl))
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..headers['Connection'] = 'keep-alive' // Enable connection reuse
      ..headers['Accept'] =
          'application/json; charset=utf-8' // Ensure UTF-8 response
      ..headers['Accept-Charset'] = 'utf-8' // Request UTF-8 encoding
      ..files.add(await http.MultipartFile.fromPath('file', audioPath))
      ..fields['model'] = selectedModel
      ..fields['temperature'] = '0'
      ..fields['response_format'] =
          'json'; // Use json instead of verbose_json for faster parsing

    // No language parameter - let the model auto-detect
    if (kDebugMode) {
      print(
          'API Request - Model: $selectedModel, No language parameter (clean auto-detect request)');
    }

    // Add prompt if dictionary words exist
    if (prompt != null && prompt.isNotEmpty) {
      request.fields['prompt'] = prompt;
    }

    try {
      // Send request with timeout
      final streamedResponse = await _httpClient
          .send(request)
          .timeout(_connectionTimeout, onTimeout: () {
        throw TimeoutException('Connection timeout after $_connectionTimeout');
      });

      final response = await http.Response.fromStream(streamedResponse)
          .timeout(_responseTimeout, onTimeout: () {
        throw TimeoutException('Response timeout after $_responseTimeout');
      });

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to transcribe audio: ${response.statusCode} - ${response.body}');
      }

      // Ensure UTF-8 decoding for proper Unicode character handling
      final responseBody = utf8.decode(response.bodyBytes);
      final responseJson = json.decode(responseBody);

      // Handle both verbose and simple JSON responses
      final transcriptionText = responseJson['text'] as String;
      final transcription = TranscriptionResponse(
        text: transcriptionText,
        xGroq: GroqMetadata(id: responseJson['x_groq']?['id'] ?? 'unknown'),
      );

      // Log performance metrics
      stopwatch.stop();
      if (kDebugMode) {
        print('Transcription completed in ${stopwatch.elapsedMilliseconds}ms');
      }

      // Save the transcription locally (non-blocking)
      saveTranscription(audioPath, transcription.text).catchError((e) {
        if (kDebugMode) {
          print('Error saving transcription locally: $e');
        }
      });

      return transcription;
    } on TimeoutException catch (e) {
      throw Exception('Request timeout: ${e.message}');
    } catch (e) {
      throw Exception('Failed to transcribe audio: $e');
    }
  }

  @override
  Future<String?> getTranscription(String audioPath) {
    return localDataSource.getTranscription(audioPath);
  }

  @override
  Future<void> saveTranscription(String audioPath, String transcription) {
    return localDataSource.saveTranscription(audioPath, transcription);
  }

  /// Cleanup method to close the HTTP client when done
  static void dispose() {
    _httpClient.close();
  }
}
