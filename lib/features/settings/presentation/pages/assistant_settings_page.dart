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
              // Assistant Hotkey Settings Section
              const AssistantHotkeySettingsSection(),
              const SizedBox(height: DesignTokens.spaceXXL),

              // Screenshot Settings Section
              _buildScreenshotSettingsSection(context, state),
              const SizedBox(height: DesignTokens.spaceXXL),

              // Assistant Models Section
              const AssistantModelsSection(),

              // Bottom padding for scrolling
              const SizedBox(height: DesignTokens.spaceXXL),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScreenshotSettingsSection(
      BuildContext context, SettingsState state) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceXS),
              decoration: BoxDecoration(
                gradient: DesignTokens.purpleGradient,
                borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
              ),
              child: Icon(
                Icons.screenshot_rounded,
                color: DesignTokens.trueWhite,
                size: DesignTokens.iconSizeSM,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceSM),
            Text(
              'Screenshot Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: DesignTokens.fontWeightSemiBold,
                    color: isDarkMode
                        ? DesignTokens.trueWhite
                        : DesignTokens.pureBlack,
                  ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spaceSM),
        Text(
          'Configure automatic screenshot capture for visual context.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDarkMode
                    ? DesignTokens.trueWhite.withValues(alpha: 0.7)
                    : DesignTokens.pureBlack.withValues(alpha: 0.6),
              ),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Auto-capture Screenshot',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: DesignTokens.fontWeightMedium,
                                    color: isDarkMode
                                        ? DesignTokens.trueWhite
                                        : DesignTokens.pureBlack,
                                  ),
                        ),
                        const SizedBox(height: DesignTokens.spaceXS),
                        Text(
                          'When enabled, a screenshot will be taken when the assistant hotkey is pressed to provide visual context for more accurate responses.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDarkMode
                                        ? DesignTokens.trueWhite
                                            .withValues(alpha: 0.6)
                                        : DesignTokens.pureBlack
                                            .withValues(alpha: 0.5),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceMD),
                  Switch(
                    value: state.assistantScreenshotEnabled,
                    onChanged: (_) {
                      context
                          .read<SettingsBloc>()
                          .add(ToggleAssistantScreenshot());
                    },
                    activeColor: DesignTokens.vibrantCoral,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
