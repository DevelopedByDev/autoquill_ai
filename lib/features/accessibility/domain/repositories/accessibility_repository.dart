import '../../data/platform/accessibility_platform.dart';

/// Repository for accessibility features
class AccessibilityRepository {
  /// Extracts visible text from the active application screen using OCR
  Future<String> extractVisibleText() async {
    return await AccessibilityPlatform.extractVisibleText();
  }
}
