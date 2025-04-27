import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'bloc/record_hotkey_bloc.dart';

class RecordHotkeyDialog extends StatelessWidget {
  const RecordHotkeyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecordHotkeyBloc()..add(StartRecording()),
      child: BlocBuilder<RecordHotkeyBloc, RecordHotkeyState>(
        builder: (context, state) {
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
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: HotKeyRecorder(
                    onHotKeyRecorded: (hotKey) {
                      context.read<RecordHotkeyBloc>().add(UpdateHotkey(hotKey));
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  context.read<RecordHotkeyBloc>().add(StopRecording());
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<RecordHotkeyBloc>().add(StopRecording());
                  Navigator.pop(context, state.hotKey);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
