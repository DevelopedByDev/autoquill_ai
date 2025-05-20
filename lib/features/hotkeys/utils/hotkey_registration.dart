import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:autoquill_ai/core/settings/settings_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:autoquill_ai/core/storage/app_storage.dart';
import '../utils/hotkey_converter.dart';

/// Utility class for handling hotkey registration
class HotkeyRegistration {
  // Cache for converted hotkeys to avoid repeated conversions
  static final Map<String, HotKey> _hotkeyCache = {};
  
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
    // Clear the cache to ensure we have the latest settings
    _hotkeyCache.clear();
    
    final stopwatch = Stopwatch()..start();
    
    try {
      final settingsBox = Hive.box('settings');
      
      if (kDebugMode) {
        print('Checking for hotkeys in settings box...');
        print('Settings box keys: ${settingsBox.keys.toList()}');
      }
      
      // Try multiple ways to get the hotkeys to ensure we find them
      dynamic transcriptionHotkey = settingsBox.get('transcription_hotkey');
      dynamic assistantHotkey = settingsBox.get('assistant_hotkey');
      
      // If hotkeys are not found, try the settings service
      if (transcriptionHotkey == null || assistantHotkey == null) {
        final settingsService = SettingsService();
        if (transcriptionHotkey == null) {
          final hotkeyMap = settingsService.getTranscriptionHotkey();
          if (hotkeyMap != null) {
            transcriptionHotkey = hotkeyMap;
            if (kDebugMode) {
              print('Loaded transcription hotkey from settings service: $transcriptionHotkey');
            }
          }
        }
        
        if (assistantHotkey == null) {
          final hotkeyMap = settingsService.getAssistantHotkey();
          if (hotkeyMap != null) {
            assistantHotkey = hotkeyMap;
            if (kDebugMode) {
              print('Loaded assistant hotkey from settings service: $assistantHotkey');
            }
          }
        }
      }
      
      if (kDebugMode) {
        print('Transcription hotkey from settings: $transcriptionHotkey');
        print('Assistant hotkey from settings: $assistantHotkey');
      }
      
      // Convert hotkeys and store in cache (fast operation)
      if (transcriptionHotkey != null) {
        try {
          final hotkey = hotKeyConverter(transcriptionHotkey);
          // Explicitly set the identifier
          final updatedHotkey = HotKey(
            key: hotkey.key,
            modifiers: hotkey.modifiers,
            scope: hotkey.scope,
            identifier: 'transcription_hotkey',
          );
          _hotkeyCache['transcription_hotkey'] = updatedHotkey;
          
          if (kDebugMode) {
            print('Successfully cached transcription hotkey: ${updatedHotkey.toJson()}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error converting transcription hotkey: $e');
          }
        }
      }
      
      if (assistantHotkey != null) {
        try {
          final hotkey = hotKeyConverter(assistantHotkey);
          // Explicitly set the identifier
          final updatedHotkey = HotKey(
            key: hotkey.key,
            modifiers: hotkey.modifiers,
            scope: hotkey.scope,
            identifier: 'assistant_hotkey',
          );
          _hotkeyCache['assistant_hotkey'] = updatedHotkey;
          
          if (kDebugMode) {
            print('Successfully cached assistant hotkey: ${updatedHotkey.toJson()}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error converting assistant hotkey: $e');
          }
        }
      }
      
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
  
  /// Reloads all hotkeys from storage and registers them
  /// This is used when hotkeys are changed in settings
  static Future<void> reloadAllHotkeys({
    required Function(HotKey) keyDownHandler,
    required Function(HotKey) keyUpHandler,
  }) async {
    try {
      // First unregister all existing hotkeys to avoid conflicts
      await hotKeyManager.unregisterAll();
      
      // Prepare hotkeys from storage
      await prepareHotkeys();
      
      // Register hotkeys from cache
      await _registerHotkeyFromCache(
        'transcription_hotkey',
        keyDownHandler,
        keyUpHandler,
      );
      
      await _registerHotkeyFromCache(
        'assistant_hotkey',
        keyDownHandler,
        keyUpHandler,
      );
      
      if (kDebugMode) {
        print('All hotkeys reloaded and registered');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error reloading hotkeys: $e');
      }
    }
  }
  
  /// Ensures hotkeys are properly loaded after onboarding
  /// This is called when the app starts after onboarding is completed
  static Future<void> ensureHotkeysLoadedAfterOnboarding() async {
    try {
      if (kDebugMode) {
        print('Ensuring hotkeys are properly loaded after onboarding');
      }
      
      final settingsBox = Hive.box('settings');
      final settingsService = SettingsService();
      
      // Check if transcription hotkey exists in Hive
      if (settingsBox.get('transcription_hotkey') == null) {
        // Try to get it from the settings service
        final hotkeyMap = settingsService.getTranscriptionHotkey();
        if (hotkeyMap != null) {
          // Save it to Hive for consistency
          await settingsBox.put('transcription_hotkey', hotkeyMap);
          if (kDebugMode) {
            print('Saved transcription hotkey to Hive from settings service');
          }
        }
      }
      
      // Check if assistant hotkey exists in Hive
      if (settingsBox.get('assistant_hotkey') == null) {
        // Try to get it from the settings service
        final hotkeyMap = settingsService.getAssistantHotkey();
        if (hotkeyMap != null) {
          // Save it to Hive for consistency
          await settingsBox.put('assistant_hotkey', hotkeyMap);
          if (kDebugMode) {
            print('Saved assistant hotkey to Hive from settings service');
          }
        }
      }
      
      // Clear the cache to ensure hotkeys are reloaded
      _hotkeyCache.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Error ensuring hotkeys are loaded after onboarding: $e');
      }
    }
  }
}
