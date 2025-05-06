import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:autoquill_ai/widgets/keyboard_key_converter.dart';

/// Converts stored hotkey data into a HotKey object
HotKey hotKeyConverter(dynamic data) {
  final hotkeyData = Map<String, dynamic>.from(data as Map);
  final identifier = hotkeyData['identifier'] as String?;
  final keyMap = hotkeyData['key'];
  if (keyMap == null) {
    // If no key data, default to 'A' key
    return HotKey(
      identifier: identifier,
      key: LogicalKeyboardKey.keyA,
      scope: HotKeyScope.system,
    );
  }
  final keyData = Map<Object?, Object?>.from(keyMap as Map);
  final keyboardKey = const KeyboardKeyConverter().fromJson(keyData);
  return HotKey(
    identifier: identifier,
    key: keyboardKey,
    modifiers: (hotkeyData['modifiers'] as List<dynamic>?)
        ?.map((m) => HotKeyModifier.values.firstWhere(
              (mod) => mod.name == m,
              orElse: () => HotKeyModifier.control,
            ))
        .toList() ?? <HotKeyModifier>[],
    scope: HotKeyScope.values.firstWhere(
      (s) => s.name == hotkeyData['scope'],
      orElse: () => HotKeyScope.system,
    ),
  );
}
