import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'features/settings/bloc/settings_bloc.dart';
import 'features/settings/bloc/settings_event.dart';
import 'features/settings/bloc/settings_state.dart';

class SettingsPage extends StatelessWidget {
  final TextEditingController groqAPIKeyController;

  const SettingsPage({
    super.key,
    required this.groqAPIKeyController,
  });

  void _showHotkeyDialog(BuildContext context, String mode) {
    context.read<SettingsBloc>().add(StartHotkeyRecording(mode));

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<SettingsBloc>(),
        child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) => AlertDialog(
          title: Text('Configure $mode Hotkey'),
          content: SizedBox(
            height: 120,
            child: Column(
              children: [
                Text('Press the desired hotkey combination for $mode.\nThe keys you press will appear in the box below:'),
                const SizedBox(height: 16),
                Container(
                  width: 200,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (state.recordedHotkey != null)
                        Text(
                          '${state.recordedHotkey!.modifiers?.map((m) => m.toString()).join('+')}${state.recordedHotkey!.modifiers?.isEmpty ?? true ? '' : '+'}${state.recordedHotkey!.key}',
                        ),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        width: 300,
                        height: 60,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            HotKeyRecorder(
                              onHotKeyRecorded: (hotKey) {
                                context.read<SettingsBloc>().add(UpdateRecordedHotkey(hotKey));
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<SettingsBloc>().add(CancelHotkeyRecording());
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (state.recordedHotkey != null) {
                  context.read<SettingsBloc>().add(SaveHotkey(state.recordedHotkey!));
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc()..add(LoadSettings()),
      child: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Settings'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'API Key Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: groqAPIKeyController,
                          obscureText: !state.isApiKeyVisible,
                          decoration: const InputDecoration(
                            labelText: 'Groq API Key',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              state.isApiKeyVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              context
                                  .read<SettingsBloc>()
                                  .add(ToggleApiKeyVisibility());
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              groqAPIKeyController.clear();
                              context.read<SettingsBloc>().add(DeleteApiKey());
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.save),
                            onPressed: () {
                              context.read<SettingsBloc>().add(
                                    SaveApiKey(
                                      groqAPIKeyController.text,
                                    ),
                                  );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Hotkey Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListView(
                    shrinkWrap: true,
                    children: [
                      ListTile(
                        title: const Text('Transcription Mode'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.transcriptionHotkey != null
                                  ? '${state.transcriptionHotkey!.modifiers?.map((m) => m.toString()).join('+')}${state.transcriptionHotkey!.modifiers?.isEmpty ?? true ? '' : '+'}${state.transcriptionHotkey!.key}'
                                  : 'No hotkey configured',
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showHotkeyDialog(context, 'Transcription Mode'),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Assistant Mode'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.assistantHotkey != null
                                  ? '${state.assistantHotkey!.modifiers?.map((m) => m.toString()).join('+')}${state.assistantHotkey!.modifiers?.isEmpty ?? true ? '' : '+'}${state.assistantHotkey!.key}'
                                  : 'No hotkey configured',
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showHotkeyDialog(context, 'Assistant Mode'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
