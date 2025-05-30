import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import 'record_hotkey_dialog/bloc/record_hotkey_dialog_bloc.dart';
import 'record_hotkey_dialog/bloc/record_hotkey_dialog_event.dart';
import 'record_hotkey_dialog/bloc/record_hotkey_dialog_state.dart';

class RecordHotKeyDialog extends StatelessWidget {
  const RecordHotKeyDialog({
    super.key,
    required this.onHotKeyRecorded,
    this.currentMode,
  });

  final ValueChanged<HotKey> onHotKeyRecorded;
  final String? currentMode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecordHotkeyDialogBloc(currentMode: currentMode),
      child: BlocConsumer<RecordHotkeyDialogBloc, RecordHotkeyDialogState>(
        listener: (context, state) {
          if (!state.isRecording &&
              state.recordedHotkey != null &&
              state.errorMessage == null) {
            onHotKeyRecorded(state.recordedHotkey!);
            Navigator.of(context).pop();
          } else if (!state.isRecording && state.recordedHotkey == null) {
            // Cancel was pressed
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  const Text(
                      'Press the hotkey you want to use to start recording:'),
                  Container(
                    width: 100,
                    height: 60,
                    margin: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        HotKeyRecorder(
                          onHotKeyRecorded: (hotKey) {
                            context
                                .read<RecordHotkeyDialogBloc>()
                                .add(RecordHotkey(hotKey));
                          },
                        ),
                      ],
                    ),
                  ),
                  // Show error message if there's a conflict
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.error,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: Theme.of(context).colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  context.read<RecordHotkeyDialogBloc>().add(CancelRecording());
                },
              ),
              TextButton(
                onPressed:
                    state.recordedHotkey == null || state.errorMessage != null
                        ? null
                        : () {
                            context
                                .read<RecordHotkeyDialogBloc>()
                                .add(ConfirmHotkey());
                          },
                child: const Text('OK'),
              ),
            ],
          );
        },
      ),
    );
  }
}
