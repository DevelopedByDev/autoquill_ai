import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class HotkeyDisplay extends StatelessWidget {
  final HotKey? hotkey;
  final bool showIcon;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  const HotkeyDisplay({
    super.key,
    required this.hotkey,
    this.showIcon = true,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.w500,
    this.textColor,
    this.backgroundColor,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
  });

  factory HotkeyDisplay.forPlatform({
    Key? key,
    required HotKey? hotkey,
    bool showIcon = true,
    double fontSize = 14.0,
    FontWeight fontWeight = FontWeight.w500,
    Color? textColor,
    Color? backgroundColor,
    Color? borderColor,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
  }) {
    return HotkeyDisplay(
      key: key,
      hotkey: hotkey,
      showIcon: showIcon,
      fontSize: fontSize,
      fontWeight: fontWeight,
      textColor: textColor,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultTextColor = textColor ?? Theme.of(context).colorScheme.onSurface;
    final defaultBorderColor = borderColor ?? 
        (hotkey != null 
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
            : Colors.grey);
    final defaultBackgroundColor = backgroundColor ?? Theme.of(context).colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: defaultBackgroundColor,
        border: Border.all(color: defaultBorderColor),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon) ...[              
              Icon(
                Icons.keyboard,
                size: 18,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              hotkey != null
                  ? _formatHotkey(hotkey!)
                  : 'None configured',
              style: TextStyle(
                fontWeight: fontWeight,
                fontSize: fontSize,
                color: hotkey != null 
                    ? defaultTextColor
                    : defaultTextColor.withValues(alpha: 0.7),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatHotkey(HotKey hotkey) {
    if (Platform.isMacOS) {
      return _formatMacHotkey(hotkey);
    } else {
      return _formatStandardHotkey(hotkey);
    }
  }

  String _formatStandardHotkey(HotKey hotkey) {
    String keyText = '';
    if (hotkey.modifiers?.contains(HotKeyModifier.alt) ?? false) {
      keyText += 'Alt+';
    }
    if (hotkey.modifiers?.contains(HotKeyModifier.control) ?? false) {
      keyText += 'Ctrl+';
    }
    if (hotkey.modifiers?.contains(HotKeyModifier.shift) ?? false) {
      keyText += 'Shift+';
    }
    if (hotkey.modifiers?.contains(HotKeyModifier.meta) ?? false) {
      keyText += 'Win+';
    }
    
    keyText += hotkey.key.keyLabel;
    
    return keyText;
  }

  String _formatMacHotkey(HotKey hotkey) {
    String keyText = '';
    
    // Use Unicode symbols for Mac modifiers
    if (hotkey.modifiers?.contains(HotKeyModifier.meta) ?? false) {
      keyText += '⌘ '; // Command symbol
    }
    if (hotkey.modifiers?.contains(HotKeyModifier.shift) ?? false) {
      keyText += '⇧ '; // Shift symbol
    }
    if (hotkey.modifiers?.contains(HotKeyModifier.alt) ?? false) {
      keyText += '⌥ '; // Option/Alt symbol
    }
    if (hotkey.modifiers?.contains(HotKeyModifier.control) ?? false) {
      keyText += '⌃ '; // Control symbol
    }
    
    // Add the key itself
    keyText += _getMacKeySymbol(hotkey.key);
    
    return keyText;
  }

  String _getMacKeySymbol(KeyboardKey key) {
    // Convert common keys to their Mac symbols
    switch (key.keyLabel) {
      case 'Arrow Up':
        return '↑';
      case 'Arrow Down':
        return '↓';
      case 'Arrow Left':
        return '←';
      case 'Arrow Right':
        return '→';
      case 'Enter':
        return '↩';
      case 'Tab':
        return '⇥';
      case 'Escape':
        return '⎋';
      case 'Delete':
        return '⌫';
      case 'Page Up':
        return '⇞';
      case 'Page Down':
        return '⇟';
      case 'Home':
        return '↖';
      case 'End':
        return '↘';
      case 'Space':
        return 'Space';
      default:
        // For letter keys and others, just use the label
        return key.keyLabel;
    }
  }
}
