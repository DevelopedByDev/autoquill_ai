import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'features/settings/bloc/settings_bloc.dart';
import 'features/settings/bloc/settings_event.dart';
import 'features/settings/bloc/settings_state.dart';
import 'widgets/record_hotkey_dialog.dart';

class SettingsPage extends StatelessWidget {
  final TextEditingController groqAPIKeyController;

  const SettingsPage({
    super.key,
    required this.groqAPIKeyController,
  });

  String? _getHotkeyDisplayName(HotKey? hotKey) {
    if (hotKey == null) return null;
    final modifiers = hotKey.modifiers?.map((m) => m.toString().split('.').last).join('+') ?? '';
    final key = hotKey.keyCode.toString().split('.').last;
    return modifiers.isEmpty ? key : '$modifiers+$key';
  }

  Future<void> _showManageHotkeysDialog(BuildContext context, SettingsState state) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Hotkeys'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.transcriptionHotKey != null) ...[              
              ListTile(
                title: Text(_getHotkeyDisplayName(state.transcriptionHotKey) ?? ''),
                subtitle: const Text('Transcription hotkey'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    context.read<SettingsBloc>().add(DeleteHotkey());
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ] else
              const Text('No hotkeys saved'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
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
                  // API Key Section
                  const Text(
                    'API Key',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: groqAPIKeyController,
                              obscureText: !state.isApiKeyVisible,
                              decoration: InputDecoration(
                                hintText: 'Enter your Groq API key',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    state.isApiKeyVisible ? Icons.visibility_off : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    context.read<SettingsBloc>().add(ToggleApiKeyVisibility());
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              context.read<SettingsBloc>().add(
                                SaveApiKey(groqAPIKeyController.text),
                              );
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Hotkey Section
                  const Text(
                    'Hotkey Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      title: Text(_getHotkeyDisplayName(state.transcriptionHotKey) ?? 'No hotkey set'),
                      subtitle: const Text('Click to record a new hotkey'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.transcriptionHotKey != null)
                            IconButton(
                              icon: const Icon(Icons.settings),
                              onPressed: () => _showManageHotkeysDialog(context, state),
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: state.isRecordingHotkey
                                ? null
                                : () async {
                                    context.read<SettingsBloc>().add(StartRecordingHotkey());
                                    final result = await showDialog<HotKey>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => const RecordHotkeyDialog(),
                                    );

                                    if (result != null) {
                                      if (context.mounted) {
                                        context.read<SettingsBloc>().add(SaveHotkey(result));
                                      }
                                    } else {
                                      if (context.mounted) {
                                        context.read<SettingsBloc>().add(StopRecordingHotkey());
                                      }
                                    }
                                  },
                          ),
                        ],
                      ),
                    ),
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
