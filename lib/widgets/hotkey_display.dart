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
  final bool compact;

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
    this.compact = false,
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
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    bool compact = false,
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
      compact: compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultTextColor =
        textColor ?? Theme.of(context).colorScheme.onSurface;
    final defaultBorderColor = borderColor ??
        (hotkey != null
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
            : Colors.grey);
    final defaultBackgroundColor =
        backgroundColor ?? Theme.of(context).colorScheme.surface;

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
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                hotkey != null ? _formatHotkey(hotkey!) : 'None configured',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: fontWeight,
                  fontSize: fontSize,
                  color: hotkey != null
                      ? defaultTextColor
                      : defaultTextColor.withValues(alpha: 0.7),
                  letterSpacing: 0.3,
                ),
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
    List<String> parts = [];

    // Add modifiers with both label and symbol (or just symbols in compact mode)
    if (hotkey.modifiers?.contains(HotKeyModifier.meta) ?? false) {
      parts.add(compact ? '⌘' : 'Cmd ⌘');
    }
    if (hotkey.modifiers?.contains(HotKeyModifier.control) ?? false) {
      parts.add(compact ? '⌃' : 'Control ⌃');
    }
    if (hotkey.modifiers?.contains(HotKeyModifier.alt) ?? false) {
      parts.add(compact ? '⌥' : 'Option ⌥');
    }
    if (hotkey.modifiers?.contains(HotKeyModifier.shift) ?? false) {
      parts.add(compact ? '⇧' : 'Shift ⇧');
    }

    // Add the key itself with label and symbol if applicable
    parts.add(compact
        ? _getMacKeySymbolCompact(hotkey.key)
        : _getMacKeySymbol(hotkey.key));

    // Join with " + " separator (or just concatenate in compact mode)
    return compact ? parts.join('') : parts.join(' + ');
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
        return 'Space ␣';
      default:
        // For letter keys and others, just use the label
        return key.keyLabel;
    }
  }

  String _getMacKeySymbolCompact(KeyboardKey key) {
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
        return '␣';
      default:
        // For letter keys and others, just use the label
        return key.keyLabel;
    }
  }
}
