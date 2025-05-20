import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';
import 'package:autoquill_ai/features/settings/presentation/widgets/hotkey_settings_section.dart';
import 'package:autoquill_ai/features/settings/presentation/widgets/models_section.dart';

class TranscriptionSettingsPage extends StatelessWidget {
  const TranscriptionSettingsPage({super.key});

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
              // Hotkey Settings Section
              const HotkeySettingsSection(),
              const SizedBox(height: 32),
              
              // Models Section
              const ModelsSection(),
            ],
          ),
        );
      },
    );
  }
}
