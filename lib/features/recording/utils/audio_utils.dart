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
      
      // For WAV files, check for proper header
      if (path.toLowerCase().endsWith('.wav')) {
        final bytes = await file.openRead(0, 12).toList();
        if (bytes.isEmpty) {
          print('Could not read file header');
          return false;
        }
        
        final header = bytes.first;
        // Check for RIFF and WAVE markers which should be present in valid WAV files
        // RIFF at position 0-3 and WAVE at position 8-11
        if (header.length < 12 || 
            // Check for 'RIFF' in ASCII
            (header[0] != 82 || header[1] != 73 || header[2] != 70 || header[3] != 70) ||
            // Check for 'WAVE' in ASCII
            (header[8] != 87 || header[9] != 65 || header[10] != 86 || header[11] != 69)) {
          print('Invalid WAV file header');
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
  /// This approach works for WAV files by properly handling the headers
  static Future<File> _mergeAudioFiles(String file1Path, String file2Path, String outputPath) async {
    // We're now dealing with WAV files which can be merged with proper header handling
    if (file1Path.toLowerCase().endsWith('.wav')) {
      try {
        return await _mergeWavFiles(file1Path, file2Path, outputPath);
      } catch (e) {
        print('Error merging WAV files: $e');
        // If merging fails, use the original file as fallback
        final file1 = File(file1Path);
        if (await file1.exists() && await file1.length() > 1000) {
          return await file1.copy(outputPath);
        }
      }
    }
    
    // Fallback to just copying the original file
    print('Using original file as fallback');
    return await File(file1Path).copy(outputPath);
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
  
  /// Properly merges two WAV files by handling the headers correctly
  static Future<File> _mergeWavFiles(String file1Path, String file2Path, String outputPath) async {
    final file1 = await File(file1Path).readAsBytes();
    final file2 = await File(file2Path).readAsBytes();
    
    // Parse WAV headers
    // WAV structure: RIFF header (12 bytes) + fmt chunk + data chunk
    
    // Find the data chunk in the first file
    int dataPos1 = _findDataChunkPosition(file1);
    if (dataPos1 == -1) {
      throw Exception('Could not find data chunk in first WAV file');
    }
    
    // Find the data chunk in the second file
    int dataPos2 = _findDataChunkPosition(file2);
    if (dataPos2 == -1) {
      throw Exception('Could not find data chunk in second WAV file');
    }
    
    // Get data size from first file (4 bytes after 'data')
    int dataSize1 = _bytesToInt(file1.sublist(dataPos1 + 4, dataPos1 + 8), Endian.little);
    
    // Get data size from second file
    int dataSize2 = _bytesToInt(file2.sublist(dataPos2 + 4, dataPos2 + 8), Endian.little);
    
    // Calculate new data size
    int newDataSize = dataSize1 + dataSize2;
    
    // Calculate new file size (RIFF chunk size = file size - 8)
    int newRiffSize = file1.length - 8 + dataSize2;
    
    // Create new file
    final result = Uint8List(file1.length + dataSize2);
    
    // Copy RIFF header from first file
    result.setRange(0, 4, file1.sublist(0, 4)); // 'RIFF'
    
    // Update RIFF chunk size
    final newRiffSizeBytes = _intToBytes(newRiffSize, 4, Endian.little);
    result.setRange(4, 8, newRiffSizeBytes);
    
    // Copy rest of the header
    result.setRange(8, dataPos1 + 4, file1.sublist(8, dataPos1 + 4));
    
    // Update data chunk size
    final newDataSizeBytes = _intToBytes(newDataSize, 4, Endian.little);
    result.setRange(dataPos1 + 4, dataPos1 + 8, newDataSizeBytes);
    
    // Copy audio data from first file
    result.setRange(dataPos1 + 8, dataPos1 + 8 + dataSize1, 
                   file1.sublist(dataPos1 + 8, dataPos1 + 8 + dataSize1));
    
    // Copy audio data from second file
    result.setRange(dataPos1 + 8 + dataSize1, result.length,
                   file2.sublist(dataPos2 + 8, dataPos2 + 8 + dataSize2));
    
    return await File(outputPath).writeAsBytes(result);
  }
  
  /// Find the position of the 'data' chunk in a WAV file
  static int _findDataChunkPosition(Uint8List wavFile) {
    // Search for 'data' chunk marker (ASCII: 100, 97, 116, 97)
    for (int i = 12; i < wavFile.length - 4; i++) {
      if (wavFile[i] == 100 && wavFile[i + 1] == 97 && 
          wavFile[i + 2] == 116 && wavFile[i + 3] == 97) {
        return i;
      }
    }
    return -1;
  }
  
  /// Convert bytes to integer with specified endianness
  static int _bytesToInt(Uint8List bytes, Endian endian) {
    int result = 0;
    if (endian == Endian.little) {
      for (int i = 0; i < bytes.length; i++) {
        result |= bytes[i] << (8 * i);
      }
    } else {
      for (int i = 0; i < bytes.length; i++) {
        result = (result << 8) | bytes[i];
      }
    }
    return result;
  }
}
