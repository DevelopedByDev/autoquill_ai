import 'package:hive_flutter/hive_flutter.dart';
import 'package:autoquill_ai/core/storage/app_storage.dart';
import 'package:autoquill_ai/record_hotkey_dialog.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:hotkey_manager_platform_interface/src/hotkey.dart';

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

  @override
  void dispose() {
    super.dispose();
  }

  void _keyDownHandler(HotKey hotKey) {
    String log = 'keyDown ${hotKey.debugName} (${hotKey.scope})';
    BotToast.showText(text: log);
    if (kDebugMode) {
      print(log);
    }
  }

  void _keyUpHandler(HotKey hotKey) {
    String log = 'keyUp   ${hotKey.debugName} (${hotKey.scope})';
    BotToast.showText(text: log);
    if (kDebugMode) {
      print(log);
    }
  }

  Future<void> _handleHotKeyRegister(HotKey hotKey, String setting) async {
    await hotKeyManager.register(
      hotKey,
      keyDownHandler: _keyDownHandler,
      keyUpHandler: _keyUpHandler,
    );
    final keyData = {
      'keyCode': hotKey.key.toString(),
      'modifiers': {
        'alt': hotKey.modifiers?.contains(HotKeyModifier.alt) ?? false,
        'control': hotKey.modifiers?.contains(HotKeyModifier.control) ?? false,
        'shift': hotKey.modifiers?.contains(HotKeyModifier.shift) ?? false,
        'meta': hotKey.modifiers?.contains(HotKeyModifier.meta) ?? false,
      },
    };
    await AppStorage.saveHotkey(setting, keyData);

  }

  Future<void> _handleClickRegisterNewHotKey(String setting) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RecordHotKeyDialog(
          onHotKeyRecorded: (newHotKey) => _handleHotKeyRegister(newHotKey, setting),
        );
      },
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
                              controller: widget.groqAPIKeyController,
                              obscureText: !state.isApiKeyVisible,
                              decoration: const InputDecoration(
                                labelText: 'Groq API Key',
                              ),
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
                              icon: const Icon(Icons.save),
                              onPressed: () {
                                context
                                    .read<SettingsBloc>()
                                    .add(SaveApiKey(widget.groqAPIKeyController.text));
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                widget.groqAPIKeyController.clear();
                                context.read<SettingsBloc>().add(DeleteApiKey());
                              },
                            ),
                          ],
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
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ValueListenableBuilder(
                                valueListenable: Hive.box('settings').listenable(),
                                builder: (context, box, _) {
                                  final hotkeyData = box.get('transcription_hotkey');
                                  if (hotkeyData == null) return const Text('None configured');
                                  
                                  final modifiers = hotkeyData['modifiers'] as Map;
                                  final parts = <String>[];
                                  
                                  if (modifiers['control'] == true) parts.add('Ctrl');
                                  if (modifiers['alt'] == true) parts.add('Alt');
                                  if (modifiers['shift'] == true) parts.add('Shift');
                                  if (modifiers['meta'] == true) parts.add('Cmd');
                                  
                                  parts.add(hotkeyData['keyCode'].toString().replaceAll('PhysicalKeyboardKey.', ''));
                                  
                                  return Text(parts.join(' + '));
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _handleClickRegisterNewHotKey('transcription_hotkey');
                            }
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
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ValueListenableBuilder(
                                valueListenable: Hive.box('settings').listenable(),
                                builder: (context, box, _) {
                                  final hotkeyData = box.get('assistant_hotkey');
                                  if (hotkeyData == null) return const Text('None configured');
                                  
                                  final modifiers = hotkeyData['modifiers'] as Map;
                                  final parts = <String>[];
                                  
                                  if (modifiers['control'] == true) parts.add('Ctrl');
                                  if (modifiers['alt'] == true) parts.add('Alt');
                                  if (modifiers['shift'] == true) parts.add('Shift');
                                  if (modifiers['meta'] == true) parts.add('Cmd');
                                  
                                  parts.add(hotkeyData['keyCode'].toString().replaceAll('PhysicalKeyboardKey.', ''));
                                  
                                  return Text(parts.join(' + '));
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _handleClickRegisterNewHotKey('assistant_hotkey');
                            }
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
