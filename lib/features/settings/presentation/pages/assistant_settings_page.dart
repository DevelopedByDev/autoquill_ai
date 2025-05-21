import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_event.dart';
import 'package:autoquill_ai/features/settings/presentation/widgets/assistant_hotkey_settings_section.dart';
import 'package:autoquill_ai/features/settings/presentation/widgets/assistant_models_section.dart';

class AssistantSettingsPage extends StatelessWidget {
  const AssistantSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state.error?.isNotEmpty ?? false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assistant Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Assistant Hotkey Settings Section
              const AssistantHotkeySettingsSection(),
              const SizedBox(height: 32),
              
              // Screenshot toggle section
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Screenshot Settings',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Automatically capture screenshot'),
                        subtitle: const Text(
                          'When enabled, a screenshot will be taken when the assistant hotkey is pressed to provide visual context',
                        ),
                        value: state.assistantScreenshotEnabled,
                        onChanged: (_) {
                          context.read<SettingsBloc>().add(ToggleAssistantScreenshot());
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Assistant Models Section
              const AssistantModelsSection(),
            ],
          ),
        );
      },
    );
  }
}
