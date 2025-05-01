import 'package:flutter/services.dart';

class KeyboardKeyConverter {
  const KeyboardKeyConverter();

  KeyboardKey fromJson(Map<Object?, Object?> json) {
    final map = Map<String, dynamic>.from(json);
    int? keyId = map['keyId'];
    int? usageCode = map['usageCode'];
    if (keyId != null) {
      final logicalKey = LogicalKeyboardKey.findKeyByKeyId(keyId);
      if (logicalKey != null) return logicalKey;
    }
    if (usageCode != null) {
      final physicalKey = PhysicalKeyboardKey.findKeyByCode(usageCode);
      if (physicalKey != null) return physicalKey;
    }
    throw PlatformException(
      code: 'invalid_keyboard_key',
      message: 'Invalid keyboard key',
    );
  }

  Map<String, dynamic> toJson(KeyboardKey object) {
    int? keyId = object is LogicalKeyboardKey ? object.keyId : null;
    int? usageCode = object is PhysicalKeyboardKey ? object.usbHidUsage : null;
    return {
      'keyId': keyId,
      'usageCode': usageCode,
    }..removeWhere((key, value) => value == null);
  }
}