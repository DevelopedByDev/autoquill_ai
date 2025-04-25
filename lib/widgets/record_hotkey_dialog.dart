import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class RecordHotkeyDialog extends StatefulWidget {
  const RecordHotkeyDialog({super.key});

  @override
  State<RecordHotkeyDialog> createState() => _RecordHotkeyDialogState();
}

class _RecordHotkeyDialogState extends State<RecordHotkeyDialog> {
  HotKey? _hotKey;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record Hotkey'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Press a key combination\n(e.g., Ctrl + Shift + Alt + A)',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: HotKeyRecorder(
              onHotKeyRecorded: (hotKey) {
                setState(() {
                  _hotKey = hotKey;
                });
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _hotKey = null;
            });
          },
          child: const Text('Restart'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _hotKey != null ? () => Navigator.of(context).pop(_hotKey) : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
