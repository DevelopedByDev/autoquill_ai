import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/core/theme/design_tokens.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';
import 'package:autoquill_ai/features/settings/presentation/widgets/transcription_hotkey_settings_section.dart';
import 'package:autoquill_ai/features/settings/presentation/widgets/transcription_models_section.dart';
import 'package:autoquill_ai/features/settings/presentation/widgets/smart_transcription_section.dart';

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
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Transcription Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: DesignTokens.fontWeightMedium,
                  ),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(DesignTokens.spaceMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transcription Hotkey Settings Section
                const TranscriptionHotkeySettingsSection(),
                const SizedBox(height: DesignTokens.spaceLG),

                // Smart Transcription Section
                const SmartTranscriptionSection(),
                const SizedBox(height: DesignTokens.spaceLG),

                // Transcription Models Section
                const TranscriptionModelsSection(),

                // Bottom padding for scrolling
                const SizedBox(height: DesignTokens.spaceLG),
              ],
            ),
          ),
        );
      },
    );
  }
}
