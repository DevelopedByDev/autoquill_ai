import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_event.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';
import 'package:autoquill_ai/widgets/hotkey_converter.dart';
import 'package:autoquill_ai/widgets/record_hotkey_dialog.dart';

class TranscriptionHotkeySettingsSection extends StatelessWidget {
  const TranscriptionHotkeySettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hotkey Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildHotkeyRow(context, 'Transcription mode', 'transcription_hotkey', state),
          ],
        );
      }
    );
  }

  Widget _buildHotkeyRow(BuildContext context, String label, String hotkeyKey, SettingsState state) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text(label),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildHotkeyDisplay(hotkeyKey, state),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showRecordHotkeyDialog(context, hotkeyKey);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    context.read<SettingsBloc>().add(DeleteHotkey(hotkeyKey));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotkeyDisplay(String hotkeyKey, SettingsState state) {
    final hotkeyData = state.storedHotkeys[hotkeyKey];
    if (hotkeyData == null) {
      return const Text('None configured');
    }
    final hotKey = hotKeyConverter(hotkeyData);
    
    // Create a simple text representation of the hotkey
    String keyText = '';
    if (hotKey.modifiers?.contains(HotKeyModifier.alt) ?? false) {
      keyText += 'Alt+';
    }
    if (hotKey.modifiers?.contains(HotKeyModifier.control) ?? false) {
      keyText += 'Ctrl+';
    }
    if (hotKey.modifiers?.contains(HotKeyModifier.shift) ?? false) {
      keyText += 'Shift+';
    }
    if (hotKey.modifiers?.contains(HotKeyModifier.meta) ?? false) {
      keyText += 'Cmd+';
    }
    
    keyText += hotKey.key.keyLabel;
    
    return Text(keyText);
  }

  Future<void> _showRecordHotkeyDialog(BuildContext context, String mode) async {
    context.read<SettingsBloc>().add(StartHotkeyRecording(mode));
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return RecordHotKeyDialog(
          onHotKeyRecorded: (newHotKey) {
            context.read<SettingsBloc>().add(SaveHotkey(newHotKey));
          },
        );
      },
    );
  }
}
