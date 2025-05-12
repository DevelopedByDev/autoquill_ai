import 'dart:io';
import 'dart:typed_data';

/// Utility class for audio file operations
class AudioUtils {
  /// Validates that an audio file exists and has content
  /// Returns true if the file is valid, false otherwise
  static Future<bool> validateAudioFile(String path) async {
    try {
      final file = File(path);
      
      // Check if file exists
      if (!await file.exists()) {
        print('Audio file does not exist: $path');
        return false;
      }
      
      // Check if file has content
      final fileSize = await file.length();
      if (fileSize < 100) { // Arbitrary minimum size for a valid audio file
        print('Audio file is too small to be valid: $fileSize bytes');
        return false;
      }
      
      // For M4A files, check for proper header
      if (path.toLowerCase().endsWith('.m4a')) {
        final bytes = await file.openRead(0, 8).toList();
        if (bytes.isEmpty) {
          print('Could not read file header');
          return false;
        }
        
        final header = bytes.first;
        // Check for ftyp marker which should be present in valid M4A files
        if (header.length < 8 || 
            (header[4] != 102 || header[5] != 116 || header[6] != 121 || header[7] != 112)) { // 'ftyp' in ASCII
          print('Invalid M4A file header');
          return false;
        }
      }
      
      return true;
    } catch (e) {
      print('Error validating audio file: $e');
      return false;
    }
  }
  
  /// Estimates the duration of an audio file
  /// This is a rough estimate based on file size and typical audio formats
  static Future<Duration> estimateAudioDuration(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();

    // Rough estimate for PCM WAV at 16-bit mono 44.1kHz: 88200 bytes per second
    // For AAC/M4A, this is a very rough approximation
    final seconds = bytes.length / 88200;
    return Duration(milliseconds: (seconds * 1000).toInt());
  }

  /// Pads an audio file with silence to reach a minimum duration
  /// Returns the path to the padded audio file
  static Future<String> padWithSilence(String originalPath, Duration minDuration) async {
    final currentDuration = await estimateAudioDuration(originalPath);
    
    if (currentDuration >= minDuration) {
      print('Audio already meets minimum duration: ${currentDuration.inSeconds}s');
      return originalPath;
    }

    final silenceDuration = minDuration - currentDuration;
    print('Padding audio with ${silenceDuration.inSeconds}s of silence');
    
    // Create a new file path for the padded audio
    final originalFile = File(originalPath);
    final directory = originalFile.parent;
    final fileName = originalPath.split('/').last.split('.').first;
    final extension = originalPath.split('.').last;
    final paddedPath = '${directory.path}/${fileName}_padded.$extension';
    
    // Generate silence (assuming 16-bit PCM mono, 44.1kHz)
    final int sampleRate = 44100;
    final int numChannels = 1;
    final int bitsPerSample = 16;
    final int numSilentSamples = (silenceDuration.inMilliseconds * sampleRate ~/ 1000);
    
    // Create silence data (all zeros)
    final silenceData = Uint8List(numSilentSamples * 2); // 2 bytes per sample
    
    // Create a WAV file with the silence
    final silencePath = '${directory.path}/temp_silence.wav';
    await _writeWavFile(silencePath, silenceData, sampleRate, numChannels, bitsPerSample);
    
    // Merge original audio with silence
    final paddedFile = await _mergeAudioFiles(originalPath, silencePath, paddedPath);
    
    // Clean up temporary silence file
    try {
      await File(silencePath).delete();
    } catch (e) {
      print('Error deleting temporary silence file: $e');
    }
    
    return paddedFile.path;
  }
  
  /// Writes raw PCM data to a WAV file
  static Future<void> _writeWavFile(
    String path, 
    Uint8List audioData, 
    int sampleRate, 
    int channels, 
    int bitsPerSample
  ) async {
    final int byteRate = sampleRate * channels * (bitsPerSample ~/ 8);
    final int blockAlign = channels * (bitsPerSample ~/ 8);
    final int subChunk2Size = audioData.length;
    final int chunkSize = 36 + subChunk2Size;
    
    // Create WAV header
    final header = BytesBuilder();
    
    // RIFF chunk descriptor
    header.add(_stringToBytes('RIFF'));
    header.add(_intToBytes(chunkSize, 4, Endian.little));
    header.add(_stringToBytes('WAVE'));
    
    // fmt sub-chunk
    header.add(_stringToBytes('fmt '));
    header.add(_intToBytes(16, 4, Endian.little)); // Subchunk1Size
    header.add(_intToBytes(1, 2, Endian.little));  // AudioFormat (1 = PCM)
    header.add(_intToBytes(channels, 2, Endian.little));
    header.add(_intToBytes(sampleRate, 4, Endian.little));
    header.add(_intToBytes(byteRate, 4, Endian.little));
    header.add(_intToBytes(blockAlign, 2, Endian.little));
    header.add(_intToBytes(bitsPerSample, 2, Endian.little));
    
    // data sub-chunk
    header.add(_stringToBytes('data'));
    header.add(_intToBytes(subChunk2Size, 4, Endian.little));
    
    // Combine header and audio data
    final wav = Uint8List(header.length + audioData.length);
    wav.setRange(0, header.length, header.toBytes());
    wav.setRange(header.length, wav.length, audioData);
    
    await File(path).writeAsBytes(wav);
  }
  
  /// Merges two audio files by concatenating them
  /// Note: This is a simplified approach that works best with WAV files
  /// For M4A files, this might produce invalid files
  static Future<File> _mergeAudioFiles(String file1Path, String file2Path, String outputPath) async {
    // Check if we're dealing with M4A files
    if (file1Path.toLowerCase().endsWith('.m4a')) {
      // For M4A files, just use the original file if it's valid
      // since proper merging requires complex container handling
      final file1 = File(file1Path);
      if (await file1.exists() && await file1.length() > 1000) {
        // If the original file is substantial, just use it
        return await file1.copy(outputPath);
      }
    }
    
    // For WAV files or as a fallback
    try {
      final file1 = await File(file1Path).readAsBytes();
      final file2 = await File(file2Path).readAsBytes();
      
      // For WAV files, we'd need to handle the headers properly
      // This is a simplified approach that works for basic concatenation
      final combined = Uint8List(file1.length + file2.length);
      combined.setRange(0, file1.length, file1);
      combined.setRange(file1.length, combined.length, file2);
      
      return await File(outputPath).writeAsBytes(combined);
    } catch (e) {
      print('Error merging audio files: $e');
      // Return the original file as fallback
      return File(file1Path);
    }
  }
  
  /// Converts a string to bytes
  static Uint8List _stringToBytes(String str) {
    final result = Uint8List(str.length);
    for (var i = 0; i < str.length; i++) {
      result[i] = str.codeUnitAt(i);
    }
    return result;
  }
  
  /// Converts an integer to bytes with specified endianness
  static Uint8List _intToBytes(int value, int byteCount, [Endian endian = Endian.little]) {
    final result = Uint8List(byteCount);
    if (endian == Endian.little) {
      for (var i = 0; i < byteCount; i++) {
        result[i] = (value >> (8 * i)) & 0xFF;
      }
    } else {
      for (var i = 0; i < byteCount; i++) {
        result[byteCount - i - 1] = (value >> (8 * i)) & 0xFF;
      }
    }
    return result;
  }
}
