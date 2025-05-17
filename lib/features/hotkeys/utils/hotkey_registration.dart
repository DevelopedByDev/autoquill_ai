import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:autoquill_ai/core/storage/app_storage.dart';
import '../utils/hotkey_converter.dart';

/// Utility class for handling hotkey registration
class HotkeyRegistration {
  // Cache for converted hotkeys to avoid repeated conversions
  static final Map<String, HotKey> _hotkeyCache = {};
  
  // Flag to track if hotkeys have been loaded
  static bool _hotkeysLoaded = false;
  
  /// Registers a hotkey with the system
  static Future<void> registerHotKey(
    HotKey hotKey, 
    String setting, 
    Function(HotKey) keyDownHandler, 
    Function(HotKey) keyUpHandler
  ) async {
    try {
      await hotKeyManager.register(
        hotKey,
        keyDownHandler: keyDownHandler,
        keyUpHandler: keyUpHandler,
      );
      
      // Update cache
      _hotkeyCache[setting] = hotKey;
      
      final keyData = {
        'identifier': hotKey.identifier,
        'key': {
          'keyId': hotKey.key is LogicalKeyboardKey
              ? (hotKey.key as LogicalKeyboardKey).keyId
              : null,
          'usageCode': hotKey.key is PhysicalKeyboardKey
              ? (hotKey.key as PhysicalKeyboardKey).usbHidUsage
              : null,
        },
        'modifiers': hotKey.modifiers?.map((m) => m.name).toList() ?? <String>[],
        'scope': hotKey.scope.name,
      };
      
      await AppStorage.saveHotkey(setting, keyData);
    } catch (e) {
      if (kDebugMode) {
        print('Error registering hotkey for $setting: $e');
      }
    }
  }

  /// Unregisters a hotkey from the system
  static Future<void> unregisterHotKey(String setting) async {
    try {
      // Check cache first
      if (_hotkeyCache.containsKey(setting)) {
        await hotKeyManager.unregister(_hotkeyCache[setting]!);
        _hotkeyCache.remove(setting);
      } else {
        final hotkeyData = Hive.box('settings').get(setting);
        if (hotkeyData != null) {
          final hotkey = hotKeyConverter(hotkeyData);
          await hotKeyManager.unregister(hotkey);
        }
      }
      await AppStorage.deleteHotkey(setting);
    } catch (e) {
      if (kDebugMode) {
        print('Error unregistering hotkey for $setting: $e');
      }
    }
  }

  /// Prepares hotkeys for lazy loading
  /// This method quickly reads hotkeys from storage without registering them
  static Future<void> prepareHotkeys() async {
    if (_hotkeysLoaded) return;
    
    final stopwatch = Stopwatch()..start();
    
    try {
      final settingsBox = Hive.box('settings');
      final transcriptionHotkey = settingsBox.get('transcription_hotkey');
      final assistantHotkey = settingsBox.get('assistant_hotkey');
      
      // Convert hotkeys and store in cache (fast operation)
      if (transcriptionHotkey != null) {
        final hotkey = hotKeyConverter(transcriptionHotkey);
        // Explicitly set the identifier
        final updatedHotkey = HotKey(
          key: hotkey.key,
          modifiers: hotkey.modifiers,
          scope: hotkey.scope,
          identifier: 'transcription_hotkey',
        );
        _hotkeyCache['transcription_hotkey'] = updatedHotkey;
      }
      
      if (assistantHotkey != null) {
        final hotkey = hotKeyConverter(assistantHotkey);
        // Explicitly set the identifier
        final updatedHotkey = HotKey(
          key: hotkey.key,
          modifiers: hotkey.modifiers,
          scope: hotkey.scope,
          identifier: 'assistant_hotkey',
        );
        _hotkeyCache['assistant_hotkey'] = updatedHotkey;
      }
      
      _hotkeysLoaded = true;
      
      if (kDebugMode) {
        print('Prepared hotkeys in ${stopwatch.elapsedMilliseconds}ms');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error preparing hotkeys: $e');
      }
    }
  }

  /// Registers a single hotkey from the cache
  static Future<void> _registerHotkeyFromCache(
    String setting, 
    Function(HotKey) keyDownHandler, 
    Function(HotKey) keyUpHandler
  ) async {
    if (!_hotkeyCache.containsKey(setting)) return;
    
    try {
      final hotkey = _hotkeyCache[setting]!;
      await hotKeyManager.register(
        hotkey,
        keyDownHandler: keyDownHandler,
        keyUpHandler: keyUpHandler,
      );
      
      if (kDebugMode) {
        print('Registered $setting hotkey');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error registering $setting hotkey: $e');
      }
    }
  }

  /// Loads and registers all stored hotkeys from settings in parallel
  static Future<void> loadAndRegisterStoredHotkeys({
    required Function(HotKey) keyDownHandler,
    required Function(HotKey) keyUpHandler,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // First unregister all existing hotkeys to avoid conflicts
      await hotKeyManager.unregisterAll();
      
      // First prepare the hotkeys (fast operation)
      await prepareHotkeys();
      
      // Register hotkeys in parallel
      final futures = <Future>[];
      
      for (final setting in _hotkeyCache.keys) {
        futures.add(_registerHotkeyFromCache(setting, keyDownHandler, keyUpHandler));
      }
      
      // Wait for all registrations to complete
      await Future.wait(futures);
      
      if (kDebugMode) {
        print('Registered all hotkeys in ${stopwatch.elapsedMilliseconds}ms');
        print('Active hotkeys: ${_hotkeyCache.keys.join(', ')}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading and registering hotkeys: $e');
      }
    } finally {
      stopwatch.stop();
    }
  }
  
  /// Reloads all hotkeys from storage and registers them with the system
  /// This ensures that any changes to hotkeys take effect immediately
  static Future<void> reloadAllHotkeys({
    required Function(HotKey) keyDownHandler,
    required Function(HotKey) keyUpHandler,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      if (kDebugMode) {
        print('Reloading all hotkeys to apply changes immediately');
      }
      
      // Reset the loaded flag to force a fresh load from storage
      _hotkeysLoaded = false;
      
      // Clear the cache to ensure we get fresh data
      _hotkeyCache.clear();
      
      // Load and register all hotkeys again
      await loadAndRegisterStoredHotkeys(
        keyDownHandler: keyDownHandler,
        keyUpHandler: keyUpHandler,
      );
      
      if (kDebugMode) {
        print('Hotkeys reloaded successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error reloading hotkeys: $e');
      }
    } finally {
      stopwatch.stop();
    }
  }
}
