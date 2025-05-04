import 'package:autoquill_ai/widgets/hotkey_converter.dart';
import 'package:autoquill_ai/widgets/record_hotkey_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_event.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

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
                    // API Key Section
                    _buildApiKeySection(context, state),
                    const SizedBox(height: 16),
                    
                    // Hotkey Settings Section
                    _buildHotkeySettingsSection(context, state),
                    const SizedBox(height: 32),
                    
                    // Models Section
                    _buildModelsSection(context, state),
                    const SizedBox(height: 20),
                    
                    // Dictionary Section
                    _buildDictionarySection(context, state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildApiKeySection(BuildContext context, SettingsState state) {
    return Column(
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
                  child: TextField(
                    controller: _apiKeyController..text = state.apiKey ?? '',
                    obscureText: !state.isApiKeyVisible,
                    decoration: const InputDecoration(
                      labelText: 'Groq API Key',
                    ),
                    onChanged: (value) {
                      context.read<SettingsBloc>().add(SaveApiKey(value));
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
      ],
    );
  }

  Widget _buildHotkeySettingsSection(BuildContext context, SettingsState state) {
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
        _buildHotkeyRow(context, 'Text mode', 'text_hotkey', state),
        const SizedBox(height: 16),
        _buildHotkeyRow(context, 'Transcription mode', 'transcription_hotkey', state),
        const SizedBox(height: 16),
        _buildHotkeyRow(context, 'Assistant mode', 'assistant_hotkey', state),
        const SizedBox(height: 16),
        _buildHotkeyRow(context, 'Agent mode', 'agent_hotkey', state),
      ],
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
    return HotKeyVirtualView(
      hotKey: hotKeyConverter(hotkeyData),
    );
  }

  Widget _buildModelsSection(BuildContext context, SettingsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Models',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildTranscriptionModelDropdown(context, state),
        const SizedBox(height: 16),
        _buildAssistantModelDropdown(context, state),
        const SizedBox(height: 16),
        _buildAgentModelDropdown(context, state),
      ],
    );
  }

  Widget _buildTranscriptionModelDropdown(BuildContext context, SettingsState state) {
    return Container(
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
            DropdownButton<String>(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistantModelDropdown(BuildContext context, SettingsState state) {
    return Container(
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
            DropdownButton<String>(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentModelDropdown(BuildContext context, SettingsState state) {
    return Container(
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
            DropdownButton<String>(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDictionarySection(BuildContext context, SettingsState state) {
    final TextEditingController wordController = TextEditingController();
    final FocusNode wordFocusNode = FocusNode();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dictionary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add words that are harder for models to spell correctly.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: wordController,
                    focusNode: wordFocusNode,
                    decoration: const InputDecoration(
                      hintText: 'Enter a word',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        context.read<SettingsBloc>().add(AddWordToDictionary(value));
                        wordController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (wordController.text.isNotEmpty) {
                      context.read<SettingsBloc>().add(AddWordToDictionary(wordController.text));
                      wordController.clear();
                      wordFocusNode.requestFocus();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: state.dictionary.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text('No words added yet', style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.dictionary.length,
                      itemBuilder: (context, index) {
                        final word = state.dictionary[index];
                        return ListTile(
                          dense: true,
                          title: Text(word),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: () {
                              context.read<SettingsBloc>().add(RemoveWordFromDictionary(word));
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
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
