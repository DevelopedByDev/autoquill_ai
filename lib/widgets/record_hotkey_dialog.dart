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
  });

  final ValueChanged<HotKey> onHotKeyRecorded;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecordHotkeyDialogBloc(),
      child: BlocConsumer<RecordHotkeyDialogBloc, RecordHotkeyDialogState>(
        listener: (context, state) {
          if (!state.isRecording && state.recordedHotkey != null) {
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
                  const Text('The `HotKeyRecorder` widget will record your hotkey.'),
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
                            context.read<RecordHotkeyDialogBloc>().add(RecordHotkey(hotKey));
                          },
                        ),
                      ],
                    ),
                  ),
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
                onPressed: state.recordedHotkey == null
                    ? null
                    : () {
                        context.read<RecordHotkeyDialogBloc>().add(ConfirmHotkey());
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