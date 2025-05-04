import 'package:autoquill_ai/widgets/hotkey_converter.dart';
import 'package:autoquill_ai/widgets/record_hotkey_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({
    super.key,
  });

  final TextEditingController _apiKeyController = TextEditingController();


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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  const Text(
                    'API Key',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: BlocBuilder<SettingsBloc, SettingsState>(
                              builder: (context, state) {
                                _apiKeyController.text = state.apiKey ?? '';
                                return TextField(
                                  controller: _apiKeyController,
                                  obscureText: !state.isApiKeyVisible,
                                  decoration: const InputDecoration(
                                    labelText: 'Groq API Key',
                                  ),
                                  onChanged: (value) {
                                    context.read<SettingsBloc>().add(SaveApiKey(value));
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
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
                                icon: const Icon(Icons.save),
                                onPressed: () {
                                  final apiKey = _apiKeyController.text;
                                  if (apiKey.isNotEmpty) {
                                    context.read<SettingsBloc>().add(SaveApiKey(apiKey));
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _apiKeyController.clear();
                                  context
                                      .read<SettingsBloc>()
                                      .add(DeleteApiKey());
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Hotkey Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Text('Text mode'),
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
                                    child: BlocBuilder<SettingsBloc, SettingsState>(
                                      builder: (context, state) {
                                        final hotkeyData = state.storedHotkeys['text_hotkey'];
                                        if (hotkeyData == null) {
                                          return const Text('None configured');
                                        }
                                        return HotKeyVirtualView(
                                          hotKey: hotKeyConverter(hotkeyData),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showRecordHotkeyDialog(context, 'text_hotkey');
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    context.read<SettingsBloc>().add(
                                          const DeleteHotkey('text_hotkey'),
                                        );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Text('Transcription mode'),
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
                                    child: BlocBuilder<SettingsBloc, SettingsState>(
                                      builder: (context, state) {
                                        final hotkeyData = state.storedHotkeys['transcription_hotkey'];
                                        if (hotkeyData == null) {
                                          return const Text('None configured');
                                        }
                                        return HotKeyVirtualView(
                                          hotKey: hotKeyConverter(hotkeyData),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showRecordHotkeyDialog(context, 'transcription_hotkey');
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    context.read<SettingsBloc>().add(
                                          const DeleteHotkey('transcription_hotkey'),
                                        );
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Text('Assistant mode'),
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
                                    child: BlocBuilder<SettingsBloc, SettingsState>(
                                      builder: (context, state) {
                                        final hotkeyData = state.storedHotkeys['assistant_hotkey'];
                                        if (hotkeyData == null) {
                                          return const Text('None configured');
                                        }
                                        return HotKeyVirtualView(
                                          hotKey: hotKeyConverter(hotkeyData),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showRecordHotkeyDialog(context, 'assistant_hotkey');
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    context.read<SettingsBloc>().add(
                                          const DeleteHotkey('assistant_hotkey'),
                                        );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Text('Agent mode'),
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
                                    child: BlocBuilder<SettingsBloc, SettingsState>(
                                      builder: (context, state) {
                                        final hotkeyData = state.storedHotkeys['agent_hotkey'];
                                        if (hotkeyData == null) {
                                          return const Text('None configured');
                                        }
                                        return HotKeyVirtualView(
                                          hotKey: hotKeyConverter(hotkeyData),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showRecordHotkeyDialog(context, 'agent_hotkey');
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    context.read<SettingsBloc>().add(
                                          const DeleteHotkey('agent_hotkey'),
                                        );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  const Text(
                    'Models',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Transcription model selection
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Text('Transcription model'),
                          const Spacer(),
                          BlocBuilder<SettingsBloc, SettingsState>(
                            builder: (context, state) {
                              return DropdownButton<String>(
                                value: state.transcriptionModel,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    context.read<SettingsBloc>().add(
                                          SaveTranscriptionModel(newValue),
                                        );
                                  }
                                },
                                items: [
                                  DropdownMenuItem(
                                    value: 'whisper-large-v3',
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('whisper-large-v3'),
                                        Text(
                                          'multilingual, more accurate',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'whisper-large-v3-turbo',
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('whisper-large-v3-turbo'),
                                        Text(
                                          'multilingual, faster',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'distil-whisper-large-v3-en',
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('distil-whisper-large-v3-en'),
                                        Text(
                                          'english, fastest',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Assistant model selection
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Text('Assistant model'),
                          const Spacer(),
                          BlocBuilder<SettingsBloc, SettingsState>(
                            builder: (context, state) {
                              return DropdownButton<String>(
                                value: state.assistantModel,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    context.read<SettingsBloc>().add(
                                          SaveAssistantModel(newValue),
                                        );
                                  }
                                },
                                items: [
                                  DropdownMenuItem(
                                    value: 'llama-3.3-70b-versatile',
                                    child: const Text('llama-3.3-70b-versatile'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'gemma2-9b-it',
                                    child: const Text('gemma2-9b-it'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'llama3-70b-8192',
                                    child: const Text('llama3-70b-8192'),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Agent model selection
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Text('Agent model'),
                          const Spacer(),
                          BlocBuilder<SettingsBloc, SettingsState>(
                            builder: (context, state) {
                              return DropdownButton<String>(
                                value: state.agentModel,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    context.read<SettingsBloc>().add(
                                          SaveAgentModel(newValue),
                                        );
                                  }
                                },
                                items: [
                                  DropdownMenuItem(
                                    value: 'compound-beta-mini',
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('compound-beta-mini'),
                                        Text(
                                          'search only',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'compound-beta',
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('compound-beta'),
                                        Text(
                                          'search + code execution',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'meta-llama/llama-4-scout-17b-16e-instruct',
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('compound-beta + llama 4 17b-16e-instruct'),
                                        Text(
                                          'search + code execution + screen context',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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
