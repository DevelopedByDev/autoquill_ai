import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/core/theme/design_tokens.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_event.dart';
import 'package:autoquill_ai/features/settings/presentation/widgets/assistant_hotkey_settings_section.dart';
import 'package:autoquill_ai/features/settings/presentation/widgets/assistant_models_section.dart';
import 'package:autoquill_ai/widgets/minimalist_card.dart';

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
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Assistant Settings',
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
                // Assistant Hotkey Settings Section
                const AssistantHotkeySettingsSection(),
                const SizedBox(height: DesignTokens.spaceLG),
                
                // Screenshot Settings Section
                _buildScreenshotSettingsSection(context, state),
                const SizedBox(height: DesignTokens.spaceLG),
                
                // Assistant Models Section
                const AssistantModelsSection(),

                // Bottom padding for scrolling
                const SizedBox(height: DesignTokens.spaceLG),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScreenshotSettingsSection(BuildContext context, SettingsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Screenshot Settings',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: DesignTokens.spaceSM),
        Text(
          'Configure automatic screenshot capture for visual context.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: DesignTokens.spaceMD),
        MinimalistCard(
          padding: const EdgeInsets.all(DesignTokens.spaceMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Auto-capture Screenshot',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: DesignTokens.fontWeightMedium,
                    ),
                  ),
                  Switch(
                    value: state.assistantScreenshotEnabled,
                    onChanged: (_) {
                      context.read<SettingsBloc>().add(ToggleAssistantScreenshot());
                    },
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spaceXS),
              Text(
                'When enabled, a screenshot will be taken when the assistant hotkey is pressed to provide visual context for more accurate responses.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
