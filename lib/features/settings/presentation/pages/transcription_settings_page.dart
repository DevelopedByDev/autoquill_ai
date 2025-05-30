import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/core/theme/design_tokens.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';
import 'package:autoquill_ai/features/settings/presentation/widgets/transcription_hotkey_settings_section.dart';
import 'package:autoquill_ai/features/settings/presentation/widgets/smart_transcription_section.dart';

class TranscriptionSettingsPage extends StatelessWidget {
  const TranscriptionSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state.error?.isNotEmpty ?? false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: DesignTokens.vibrantCoral,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.spaceLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transcription Hotkey Settings Section
              const TranscriptionHotkeySettingsSection(),
              const SizedBox(height: DesignTokens.spaceXXL),

              // Smart Transcription Section
              const SmartTranscriptionSection(),

              // Bottom padding for scrolling
              const SizedBox(height: DesignTokens.spaceXXL),
            ],
          ),
        );
      },
    );
  }
}
