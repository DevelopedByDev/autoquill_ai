import 'package:autoquill_ai/widgets/hotkey_converter.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:autoquill_ai/core/storage/app_storage.dart';
import 'package:autoquill_ai/widgets/record_hotkey_dialog.dart';
import 'package:autoquill_ai/widgets/hotkey_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _apiKeyController;
  // ignore: unused_field
  String _apiKey = '';

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _loadStoredAPIkey();
    _loadStoredHotkeys();
  }

  Future<void> _loadStoredAPIkey() async {
    final apiKey = await AppStorage.getApiKey();
    if (apiKey != null) {
      setState(() {
        _apiKey = apiKey;
      });
    }
  }

  Future<void> _loadStoredHotkeys() async {
    // Use the centralized HotkeyHandler to load and register all stored hotkeys
    await HotkeyHandler.loadAndRegisterStoredHotkeys();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _handleHotKeyRegister(HotKey hotKey, String setting) async {
    await HotkeyHandler.registerHotKey(hotKey, setting);
  }

  Future<void> _handleClickRegisterNewHotKey(String setting) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RecordHotKeyDialog(
          onHotKeyRecorded: (newHotKey) =>
              _handleHotKeyRegister(newHotKey, setting),
        );
      },
    );
  }

  Future<void> _handleHotKeyUnregister(String setting) async {
    await HotkeyHandler.unregisterHotKey(setting);
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
                                    child: ValueListenableBuilder(
                                      valueListenable:
                                          Hive.box('settings').listenable(),
                                      builder: (context, box, _) {
                                        final hotkeyData =
                                            box.get('transcription_hotkey');
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
                                    _handleClickRegisterNewHotKey(
                                      'transcription_hotkey',
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _handleHotKeyUnregister('transcription_hotkey');
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
                                    child: ValueListenableBuilder(
                                      valueListenable:
                                          Hive.box('settings').listenable(),
                                      builder: (context, box, _) {
                                        final hotkeyData =
                                            box.get('assistant_hotkey');
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
                                    _handleClickRegisterNewHotKey('assistant_hotkey');
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _handleHotKeyUnregister('assistant_hotkey');
                                  },
                                ),
                              ],
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
