import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../datasources/transcription_local_datasource.dart';
import '../../domain/repositories/transcription_repository.dart';
import '../models/transcription_response.dart';
import '../../../recording/utils/audio_utils.dart';

class TranscriptionRepositoryImpl implements TranscriptionRepository {
  final TranscriptionLocalDataSource localDataSource;
  static const String _baseUrl = 'https://api.groq.com/openai/v1/audio/transcriptions';

  TranscriptionRepositoryImpl({required this.localDataSource});

  @override
  Future<TranscriptionResponse> transcribeAudio(String audioPath, String apiKey) async {
    // Validate the audio file before attempting transcription
    final file = File(audioPath);
    if (!await file.exists()) {
      throw Exception('Audio file not found');
    }
    
    // Check file size to ensure it's not empty
    final fileSize = await file.length();
    if (fileSize < 100) { // Arbitrary minimum size for a valid audio file
      throw Exception('Audio file is too small or empty');
    }
    
    // Use AudioUtils to validate the file
    if (!await AudioUtils.validateAudioFile(audioPath)) {
      if (kDebugMode) {
        print('Audio file validation failed: $audioPath');
      }
      throw Exception('Invalid audio file format');
    }

    // Get the selected transcription model from settings, default to whisper-large-v3 if not set
    final settingsBox = Hive.box('settings');
    final selectedModel = settingsBox.get('transcription-model') ?? 'whisper-large-v3';
    
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
      print('File size: ${await file.length()} bytes');
    }
    
    // Create the API request
    final request = http.MultipartRequest('POST', Uri.parse(_baseUrl))
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..files.add(await http.MultipartFile.fromPath('file', audioPath))
      ..fields['model'] = selectedModel
      ..fields['temperature'] = '0'
      ..fields['response_format'] = 'verbose_json';
      
    // Add prompt if dictionary words exist
    if (prompt != null && prompt.isNotEmpty) {
      request.fields['prompt'] = prompt;
    }

    final response = await request.send();
    final responseString = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Failed to transcribe audio: ${response.statusCode} - $responseString');
    }

    final responseJson = json.decode(responseString);
    final transcription = TranscriptionResponse.fromJson(responseJson);
    
    // Save the transcription locally
    await saveTranscription(audioPath, transcription.text);
    
    return transcription;
  }

  @override
  Future<String?> getTranscription(String audioPath) {
    return localDataSource.getTranscription(audioPath);
  }

  @override
  Future<void> saveTranscription(String audioPath, String transcription) {
    return localDataSource.saveTranscription(audioPath, transcription);
  }
}
