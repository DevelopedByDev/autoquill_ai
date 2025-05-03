import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:autoquill_ai/core/storage/app_storage.dart';
import 'package:autoquill_ai/widgets/hotkey_converter.dart';

/// A centralized class for handling keyboard hotkeys throughout the application
class HotkeyHandler {
  // Cache for converted hotkeys to avoid repeated conversions
  static final Map<String, HotKey> _hotkeyCache = {};
  
  // Flag to track if hotkeys have been loaded
  static bool _hotkeysLoaded = false;
  
  /// Handles keyDown events for any registered hotkey
  static void keyDownHandler(HotKey hotKey) {
    String log = 'keyDown ${hotKey.debugName} (${hotKey.scope})';
    BotToast.showText(text: log);
    if (kDebugMode) {
      print("keyDown ${hotKey.debugName} (${hotKey.scope})");
    }
  }

  /// Handles keyUp events for any registered hotkey
  static void keyUpHandler(HotKey hotKey) {
    String log = 'keyUp   ${hotKey.debugName} (${hotKey.scope})';
    BotToast.showText(text: log);
    if (kDebugMode) {
      print("keyUp ${hotKey.debugName} (${hotKey.scope})");
    }
  }

  /// Registers a hotkey with the system
  static Future<void> registerHotKey(HotKey hotKey, String setting) async {
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
        _hotkeyCache['transcription_hotkey'] = hotKeyConverter(transcriptionHotkey);
      }
      
      if (assistantHotkey != null) {
        _hotkeyCache['assistant_hotkey'] = hotKeyConverter(assistantHotkey);
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
  static Future<void> _registerHotkeyFromCache(String setting) async {
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
  static Future<void> loadAndRegisterStoredHotkeys() async {
    final stopwatch = Stopwatch()..start();
    
    // First prepare the hotkeys (fast operation)
    await prepareHotkeys();
    
    // Register hotkeys in parallel
    final futures = <Future>[];
    
    for (final setting in _hotkeyCache.keys) {
      futures.add(_registerHotkeyFromCache(setting));
    }
    
    // Wait for all registrations to complete
    await Future.wait(futures);
    
    if (kDebugMode) {
      print('Registered all hotkeys in ${stopwatch.elapsedMilliseconds}ms');
    }
    stopwatch.stop();
  }
  
  /// Loads hotkeys in background after UI is rendered
  static void lazyLoadHotkeys() {
    // Delay registration slightly to allow UI to render first
    Future.delayed(const Duration(milliseconds: 100), () async {
      await loadAndRegisterStoredHotkeys();
    });
  }
}
