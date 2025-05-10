import 'dart:io';
import 'dart:typed_data';

/// Utility class for audio file operations
class AudioUtils {
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
  static Future<File> _mergeAudioFiles(String file1Path, String file2Path, String outputPath) async {
    final file1 = await File(file1Path).readAsBytes();
    final file2 = await File(file2Path).readAsBytes();
    
    // For WAV files, we'd need to handle the headers properly
    // This is a simplified approach that works for basic concatenation
    final combined = Uint8List(file1.length + file2.length);
    combined.setRange(0, file1.length, file1);
    combined.setRange(file1.length, combined.length, file2);
    
    return await File(outputPath).writeAsBytes(combined);
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
