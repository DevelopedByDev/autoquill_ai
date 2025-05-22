import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:screen_capturer/screen_capturer.dart';

/// Repository for accessibility features
class AccessibilityRepository {
  /// Captures a screenshot and returns the path to the saved image
  Future<String?> captureScreenshot() async {
    try {
      // Capture the entire screen
      final capturedData = await ScreenCapturer.instance.capture(
        mode: CaptureMode.screen,
        imagePath: await _getTemporaryFilePath(),
      );
      
      if (capturedData == null) {
        return null;
      }
      
      // Return the path to the captured image
      return capturedData.imagePath;
    } catch (e) {
      print('Error capturing screenshot: $e');
      return null;
    }
  }
  
  /// Converts an image to base64 encoding
  Future<String?> imageToBase64(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }
  
  /// Gets a temporary file path for saving the screenshot
  Future<String> _getTemporaryFilePath() async {
    final directory = await getTemporaryDirectory();
    return '${directory.path}/autoquill_screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
  }
}
