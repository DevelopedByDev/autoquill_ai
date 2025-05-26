import 'dart:io';
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
  static Future<void> registerHotKey(HotKey hotKey, String setting,
      Function(HotKey) keyDownHandler, Function(HotKey) keyUpHandler) async {
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
        'modifiers':
            hotKey.modifiers?.map((m) => m.name).toList() ?? <String>[],
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
      dynamic pushToTalkHotkey = settingsBox.get('push_to_talk_hotkey');

      // If hotkeys are not found, try the settings service
      if (transcriptionHotkey == null || assistantHotkey == null) {
        final settingsService = SettingsService();
        if (transcriptionHotkey == null) {
          final hotkeyMap = settingsService.getTranscriptionHotkey();
          if (hotkeyMap != null) {
            transcriptionHotkey = hotkeyMap;
            if (kDebugMode) {
              print(
                  'Loaded transcription hotkey from settings service: $transcriptionHotkey');
            }
          }
        }

        if (assistantHotkey == null) {
          final hotkeyMap = settingsService.getAssistantHotkey();
          if (hotkeyMap != null) {
            assistantHotkey = hotkeyMap;
            if (kDebugMode) {
              print(
                  'Loaded assistant hotkey from settings service: $assistantHotkey');
            }
          }
        }
      }

      if (kDebugMode) {
        print('Transcription hotkey from settings: $transcriptionHotkey');
        print('Assistant hotkey from settings: $assistantHotkey');
        print('Push-to-talk hotkey from settings: $pushToTalkHotkey');
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
            print(
                'Successfully cached transcription hotkey: ${updatedHotkey.toJson()}');
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
            print(
                'Successfully cached assistant hotkey: ${updatedHotkey.toJson()}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error converting assistant hotkey: $e');
          }
        }
      }

      if (pushToTalkHotkey != null) {
        try {
          final hotkey = hotKeyConverter(pushToTalkHotkey);
          // Explicitly set the identifier
          final updatedHotkey = HotKey(
            key: hotkey.key,
            modifiers: hotkey.modifiers,
            scope: hotkey.scope,
            identifier: 'push_to_talk_hotkey',
          );
          _hotkeyCache['push_to_talk_hotkey'] = updatedHotkey;

          if (kDebugMode) {
            print(
                'Successfully cached push-to-talk hotkey: ${updatedHotkey.toJson()}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error converting push-to-talk hotkey: $e');
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
  static Future<void> _registerHotkeyFromCache(String setting,
      Function(HotKey) keyDownHandler, Function(HotKey) keyUpHandler) async {
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

  /// Registers the Esc key for cancelling recordings
  static Future<void> _registerEscapeKey(
      Function(HotKey) keyDownHandler, Function(HotKey) keyUpHandler) async {
    try {
      final escapeHotkey = HotKey(
        key: LogicalKeyboardKey.escape,
        modifiers: [],
        scope: HotKeyScope.system,
        identifier: 'escape_cancel',
      );

      await hotKeyManager.register(
        escapeHotkey,
        keyDownHandler: keyDownHandler,
        keyUpHandler: keyUpHandler,
      );

      if (kDebugMode) {
        print('Registered escape key for cancellation');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error registering escape key: $e');
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
        futures.add(
            _registerHotkeyFromCache(setting, keyDownHandler, keyUpHandler));
      }

      // Register the Esc key for cancellation
      futures.add(_registerEscapeKey(keyDownHandler, keyUpHandler));

      // Wait for all registrations to complete
      await Future.wait(futures);

      if (kDebugMode) {
        print('Registered all hotkeys in ${stopwatch.elapsedMilliseconds}ms');
        print('Active hotkeys: ${_hotkeyCache.keys.join(', ')}, escape_cancel');
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

      await _registerHotkeyFromCache(
        'push_to_talk_hotkey',
        keyDownHandler,
        keyUpHandler,
      );

      // If push-to-talk hotkey is not set, register the default one
      if (!_hotkeyCache.containsKey('push_to_talk_hotkey')) {
        await _registerDefaultPushToTalkHotkey(keyDownHandler, keyUpHandler);
      }

      // Always register the escape key for cancellation
      await _registerEscapeKey(keyDownHandler, keyUpHandler);

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

      // Check if push-to-talk hotkey exists in Hive
      if (settingsBox.get('push_to_talk_hotkey') == null) {
        // Create default push-to-talk hotkey
        await _saveDefaultPushToTalkHotkey();
        if (kDebugMode) {
          print('Created default push-to-talk hotkey');
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

  /// Register the default push-to-talk hotkey
  static Future<void> _registerDefaultPushToTalkHotkey(
      Function(HotKey) keyDownHandler, Function(HotKey) keyUpHandler) async {
    try {
      // Create the default push-to-talk hotkey
      final defaultHotkey = await _createDefaultPushToTalkHotkey();

      // Register the hotkey
      await hotKeyManager.register(
        defaultHotkey,
        keyDownHandler: keyDownHandler,
        keyUpHandler: keyUpHandler,
      );

      // Save to cache
      _hotkeyCache['push_to_talk_hotkey'] = defaultHotkey;

      if (kDebugMode) {
        print(
            'Registered default push-to-talk hotkey: ${defaultHotkey.toJson()}');
      }

      // Save to settings
      await _saveDefaultPushToTalkHotkey();
    } catch (e) {
      if (kDebugMode) {
        print('Error registering default push-to-talk hotkey: $e');
      }
    }
  }

  /// Create the default push-to-talk hotkey based on platform
  static Future<HotKey> _createDefaultPushToTalkHotkey() async {
    // Use Alt (which maps to Option on Mac) + Space as the default
    final modifiers = <HotKeyModifier>[HotKeyModifier.alt];

    // Create the hotkey with Space key
    return HotKey(
      key: LogicalKeyboardKey.space,
      modifiers: modifiers,
      scope: HotKeyScope.system,
      identifier: 'push_to_talk_hotkey',
    );
  }

  /// Save the default push-to-talk hotkey to settings
  static Future<void> _saveDefaultPushToTalkHotkey() async {
    try {
      final defaultHotkey = await _createDefaultPushToTalkHotkey();

      // Convert to storable format
      final keyData = {
        'identifier': defaultHotkey.identifier,
        'key': {
          'keyId': defaultHotkey.key is LogicalKeyboardKey
              ? (defaultHotkey.key as LogicalKeyboardKey).keyId
              : null,
          'usageCode': defaultHotkey.key is PhysicalKeyboardKey
              ? (defaultHotkey.key as PhysicalKeyboardKey).usbHidUsage
              : null,
        },
        'modifiers':
            defaultHotkey.modifiers?.map((m) => m.name).toList() ?? <String>[],
        'scope': defaultHotkey.scope.name,
      };

      // Save to Hive
      final settingsBox = Hive.box('settings');
      await settingsBox.put('push_to_talk_hotkey', keyData);

      if (kDebugMode) {
        print('Saved default push-to-talk hotkey to settings');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving default push-to-talk hotkey: $e');
      }
    }
  }
}
