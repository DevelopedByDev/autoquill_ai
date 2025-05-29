import 'package:auto_updater/auto_updater.dart';
import 'package:flutter/foundation.dart';

class AutoUpdateService {
  static const String _feedURL =
      'http://localhost:5002/appcast.xml'; // For testing - replace with your actual appcast URL
  static bool _isInitialized = false;

  /// Initialize the auto-updater with the appcast URL
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (kDebugMode) {
        print('Initializing auto-updater...');
      }

      // Set the feed URL for checking updates
      await autoUpdater.setFeedURL(_feedURL);

      // Set automatic check interval (24 hours = 86400 seconds)
      await autoUpdater.setScheduledCheckInterval(86400);

      _isInitialized = true;

      if (kDebugMode) {
        print('Auto-updater initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize auto-updater: $e');
      }
    }
  }

  /// Manually check for updates
  static Future<void> checkForUpdates() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (kDebugMode) {
        print('Checking for updates...');
      }

      await autoUpdater.checkForUpdates();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to check for updates: $e');
      }
    }
  }

  /// Set the update check interval
  /// [interval] - Interval in seconds (minimum 3600, 0 to disable)
  static Future<void> setUpdateInterval(int interval) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await autoUpdater.setScheduledCheckInterval(interval);

      if (kDebugMode) {
        print('Update check interval set to $interval seconds');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to set update interval: $e');
      }
    }
  }

  /// Update the feed URL (for testing or changing update servers)
  static Future<void> updateFeedURL(String newFeedURL) async {
    try {
      await autoUpdater.setFeedURL(newFeedURL);

      if (kDebugMode) {
        print('Feed URL updated to: $newFeedURL');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update feed URL: $e');
      }
    }
  }
}
