import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';
import 'package:autoquill_ai/features/settings/presentation/pages/general_settings_page.dart';
import 'package:autoquill_ai/features/settings/presentation/pages/transcription_settings_page.dart';
import 'package:autoquill_ai/features/settings/presentation/pages/assistant_settings_page.dart';
import 'package:autoquill_ai/features/settings/presentation/pages/output_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 0;

  static const List<Map<String, dynamic>> _settingsSections = [
    {
      'title': 'General',
      'icon': Icons.settings,
      'page': GeneralSettingsPage(),
    },
    {
      'title': 'Transcription',
      'icon': Icons.mic,
      'page': TranscriptionSettingsPage(),
    },
    {
      'title': 'Assistant',
      'icon': Icons.smart_toy_outlined,
      'page': AssistantSettingsPage(),
    },
    {
      'title': 'Output',
      'icon': Icons.output,
      'page': OutputSettingsPage(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
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
          body: Row(
            children: [
              // Navigation Rail
              Container(
                width: 200,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1.0,
                    ),
                  ),
                ),
                child: ListView.builder(
                  itemCount: _settingsSections.length,
                  itemBuilder: (context, index) {
                    final section = _settingsSections[index];
                    return ListTile(
                      leading: Icon(section['icon'] as IconData),
                      title: Text(section['title'] as String),
                      selected: _selectedIndex == index,
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    );
                  },
                ),
              ),
              // Main Content
              Expanded(
                child: _settingsSections[_selectedIndex]['page'] as Widget,
              ),
            ],
          ),
        );
      },
    );
  }
}
