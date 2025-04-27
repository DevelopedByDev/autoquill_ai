import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'features/settings/bloc/settings_bloc.dart';
import 'features/settings/bloc/settings_event.dart';
import 'features/settings/bloc/settings_state.dart';

class SettingsPage extends StatefulWidget {
  final TextEditingController groqAPIKeyController;

  const SettingsPage({
    super.key,
    required this.groqAPIKeyController,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  HotKey? _hotKey;

  Future<void> _showHotkeyDialog(BuildContext context, String mode) {
    HotKey? recordedHotkey;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configure $mode Hotkey'),
        content: Container(
          height: 120,
          child: Column(
            children: [
              Text('Press the desired hotkey combination for $mode'),
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
                    if (recordedHotkey != null)
                    Text(recordedHotkey.toString()),
                    HotKeyRecorder(
                      onHotKeyRecorded: (hotKey) {
                        recordedHotkey = hotKey;
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: widget.groqAPIKeyController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your Groq API key',
                                    border: OutlineInputBorder(),
                                  ),
                                  obscureText: !state.isApiKeyVisible,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  state.isApiKeyVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => context
                                    .read<SettingsBloc>()
                                    .add(ToggleApiKeyVisibility()),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  widget.groqAPIKeyController.clear();
                                  context.read<SettingsBloc>().add(
                                        DeleteApiKey(),
                                      );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.save),
                                onPressed: () => context
                                    .read<SettingsBloc>()
                                    .add(SaveApiKey(widget.groqAPIKeyController.text)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your API key is stored securely on your device.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Hotkey Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        ListTile(
                          title: const Text('Transcription Mode'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('No hotkey configured'),
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
                              const Text('No hotkey configured'),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showHotkeyDialog(context, 'Assistant Mode'),
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
          );
        },
      ),
    );
  }
}
