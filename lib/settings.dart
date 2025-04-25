import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'core/storage/app_storage.dart';

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
  HotKey? _transcriptionHotKey;
  bool _isRecordingHotkey = false;
  bool _isApiKeyVisible = false;

  @override
  void initState() {
    super.initState();
    _loadSavedHotkey();
    _loadSavedApiKey();
  }

  Future<void> _loadSavedHotkey() async {
    // TODO: Load saved hotkey from local storage
  }

  void _loadSavedApiKey() {
    final savedApiKey = AppStorage.getApiKey();
    if (savedApiKey != null) {
      widget.groqAPIKeyController.text = savedApiKey;
    }
  }

  Future<void> _saveApiKey() async {
    final apiKey = widget.groqAPIKeyController.text.trim();
    if (apiKey.isNotEmpty) {
      await AppStorage.saveApiKey(apiKey);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API Key saved successfully')),
      );
    }
  }

  String? _getHotkeyDisplayName(HotKey? hotKey) {
    if (hotKey == null) return null;
    final modifiers = hotKey.modifiers?.map((m) => m.toString().split('.').last).join('+') ?? '';
    final key = hotKey.keyCode.toString().split('.').last;
    return modifiers.isEmpty ? key : '$modifiers+$key';
  }

  Future<void> _startRecordingHotkey() async {
    setState(() {
      _isRecordingHotkey = true;
    });

    final result = await showDialog<HotKey>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _RecordHotkeyDialog(),
    );

    if (result != null) {
      await _registerHotkey(result);
      setState(() {
        _transcriptionHotKey = result;
        _isRecordingHotkey = false;
      });
    } else {
      setState(() {
        _isRecordingHotkey = false;
      });
    }
  }

  Future<void> _registerHotkey(HotKey hotKey) async {
    if (_transcriptionHotKey != null) {
      await hotKeyManager.unregister(_transcriptionHotKey!);
    }

    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) {
        print("${hotKey.modifiers?.map((m) => m.toString().split('.').last).join('+') ?? ''}+${hotKey.keyCode.toString().split('.').last}");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              'API Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.groqAPIKeyController,
                    obscureText: !_isApiKeyVisible,
                    decoration: InputDecoration(
                      labelText: 'Groq API Key',
                      hintText: 'Something like gsk_0DLKkuapGSFY8...',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isApiKeyVisible ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isApiKeyVisible = !_isApiKeyVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveApiKey,
                  child: const Text('Save'),
                ),
              ],
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
                title: Text(_getHotkeyDisplayName(_transcriptionHotKey) ?? 'No hotkey set'),
                subtitle: const Text('Click to set transcription hotkey'),
                trailing: _isRecordingHotkey
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.keyboard),
                onTap: _isRecordingHotkey ? null : _startRecordingHotkey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordHotkeyDialog extends StatefulWidget {
  @override
  State<_RecordHotkeyDialog> createState() => _RecordHotkeyDialogState();
}

class _RecordHotkeyDialogState extends State<_RecordHotkeyDialog> {
  HotKey? _hotKey;

  @override
  Widget build(BuildContext context) {
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
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: HotKeyRecorder(
              onHotKeyRecorded: (hotKey) {
                setState(() {
                  _hotKey = hotKey;
                });
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _hotKey = null;
            });
          },
          child: const Text('Restart'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _hotKey != null ? () => Navigator.of(context).pop(_hotKey) : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
