import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Enum representing different permission types
/// Order matches the UI display order for better UX flow
enum PermissionType {
  microphone, // First - simple permission, no restart needed
  accessibility, // Second - needs manual granting in System Preferences
  screenRecording, // Last - requires app restart after granting
}

/// Enum representing permission status
enum PermissionStatus {
  notDetermined,
  denied,
  authorized,
  restricted,
}

/// A service to handle macOS permissions
class PermissionService {
  static const MethodChannel _channel =
      MethodChannel('com.autoquill.permissions');

  /// Check if the platform supports the permission system
  static bool get isSupported => Platform.isMacOS;

  /// Check the status of a specific permission
  static Future<PermissionStatus> checkPermission(
      PermissionType permissionType) async {
    if (!isSupported) return PermissionStatus.authorized;

    try {
      if (kDebugMode) {
        print(
            'PermissionService: Checking ${permissionType.name} permission...');
      }

      final String result = await _channel.invokeMethod('checkPermission', {
        'type': permissionType.name,
      });

      final status = _parsePermissionStatus(result);

      if (kDebugMode) {
        print(
            'PermissionService: ${permissionType.name} permission status: $status (raw: $result)');
      }

      return status;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking ${permissionType.name} permission: $e');
      }
      return PermissionStatus.notDetermined;
    }
  }

  /// Request a specific permission
  static Future<PermissionStatus> requestPermission(
      PermissionType permissionType) async {
    if (!isSupported) return PermissionStatus.authorized;

    try {
      final String result = await _channel.invokeMethod('requestPermission', {
        'type': permissionType.name,
      });

      return _parsePermissionStatus(result);
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting ${permissionType.name} permission: $e');
      }
      return PermissionStatus.denied;
    }
  }

  /// Open system preferences for a specific permission
  static Future<void> openSystemPreferences(
      PermissionType permissionType) async {
    if (!isSupported) return;

    try {
      await _channel.invokeMethod('openSystemPreferences', {
        'type': permissionType.name,
      });
    } catch (e) {
      if (kDebugMode) {
        print(
            'Error opening system preferences for ${permissionType.name}: $e');
      }
    }
  }

  /// Check all required permissions at once
  static Future<Map<PermissionType, PermissionStatus>>
      checkAllPermissions() async {
    final Map<PermissionType, PermissionStatus> results = {};

    if (kDebugMode) {
      print('PermissionService: Checking all permissions...');
    }

    for (final permissionType in PermissionType.values) {
      try {
        results[permissionType] = await checkPermission(permissionType);

        // Add a small delay between checks to ensure system has time to respond
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        if (kDebugMode) {
          print('Error checking ${permissionType.name}: $e');
        }
        results[permissionType] = PermissionStatus.notDetermined;
      }
    }

    if (kDebugMode) {
      print('PermissionService: All permissions checked: $results');
    }

    return results;
  }

  /// Check if all required permissions are granted
  static Future<bool> areAllPermissionsGranted() async {
    final permissions = await checkAllPermissions();
    return permissions.values
        .every((status) => status == PermissionStatus.authorized);
  }

  /// Get permission description for UI
  static String getPermissionDescription(PermissionType permissionType) {
    switch (permissionType) {
      case PermissionType.microphone:
        return 'AutoQuill AI needs microphone access to transcribe your voice recordings.';
      case PermissionType.accessibility:
        return 'AutoQuill AI needs accessibility permission to register global hotkeys and automate text insertion. Grant this in System Preferences > Privacy & Security > Accessibility.';
      case PermissionType.screenRecording:
        return 'AutoQuill AI needs screen recording permission to capture screenshots for AI context. The app will restart automatically after granting this permission.';
    }
  }

  /// Get permission title for UI
  static String getPermissionTitle(PermissionType permissionType) {
    switch (permissionType) {
      case PermissionType.microphone:
        return 'Microphone Access';
      case PermissionType.screenRecording:
        return 'Screen Recording';
      case PermissionType.accessibility:
        return 'Accessibility';
    }
  }

  /// Parse permission status string to enum
  static PermissionStatus _parsePermissionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'authorized':
        return PermissionStatus.authorized;
      case 'denied':
        return PermissionStatus.denied;
      case 'restricted':
        return PermissionStatus.restricted;
      case 'notdetermined':
      default:
        return PermissionStatus.notDetermined;
    }
  }
}
