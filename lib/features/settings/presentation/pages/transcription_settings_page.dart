import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';
import 'package:autoquill_ai/features/settings/presentation/widgets/transcription_hotkey_settings_section.dart';
import 'package:autoquill_ai/features/settings/presentation/widgets/transcription_models_section.dart';

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
              // Transcription Hotkey Settings Section
              const TranscriptionHotkeySettingsSection(),
              const SizedBox(height: 32),
              
              // Transcription Models Section
              const TranscriptionModelsSection(),
            ],
          ),
        );
      },
    );
  }
}
