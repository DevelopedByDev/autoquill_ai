import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';
import 'package:autoquill_ai/features/settings/presentation/widgets/api_key_section.dart';
import 'package:autoquill_ai/features/settings/presentation/widgets/theme_settings_section.dart';
import 'package:autoquill_ai/core/services/auto_update_service.dart';
import 'package:autoquill_ai/core/theme/design_tokens.dart';
import 'package:bot_toast/bot_toast.dart';

class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

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
              // API Key Section
              ApiKeySection(),
              const SizedBox(height: 32),

              // Theme Settings Section
              ThemeSettingsSection(),

              const SizedBox(height: 32),

              // App Updates Section
              _buildAppUpdatesSection(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppUpdatesSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceXS),
              decoration: BoxDecoration(
                gradient: DesignTokens.coralGradient,
                borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
              ),
              child: Icon(
                Icons.system_update_rounded,
                color: DesignTokens.trueWhite,
                size: DesignTokens.iconSizeSM,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceSM),
            Text(
              'App Updates',
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
          'AutoQuill automatically checks for updates. You can also manually check for updates below.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDarkMode
                    ? DesignTokens.trueWhite.withValues(alpha: 0.7)
                    : DesignTokens.pureBlack.withValues(alpha: 0.6),
              ),
        ),
        const SizedBox(height: DesignTokens.spaceMD),
        Container(
          padding: const EdgeInsets.all(DesignTokens.spaceMD),
          decoration: BoxDecoration(
            color: isDarkMode
                ? DesignTokens.trueWhite.withValues(alpha: 0.05)
                : DesignTokens.pureBlack.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
            border: Border.all(
              color: isDarkMode
                  ? DesignTokens.trueWhite.withValues(alpha: 0.1)
                  : DesignTokens.pureBlack.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: DesignTokens.iconSizeXS,
                    color: isDarkMode
                        ? DesignTokens.trueWhite.withValues(alpha: 0.6)
                        : DesignTokens.pureBlack.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: DesignTokens.spaceXS),
                  Text(
                    'Current Version: 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? DesignTokens.trueWhite.withValues(alpha: 0.7)
                              : DesignTokens.pureBlack.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spaceMD),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _checkForUpdates(context),
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: DesignTokens.iconSizeSM,
                  ),
                  label: Text(
                    'Check for Updates',
                    style: TextStyle(
                      fontWeight: DesignTokens.fontWeightMedium,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.vibrantCoral,
                    foregroundColor: DesignTokens.trueWhite,
                    padding: const EdgeInsets.symmetric(
                      vertical: DesignTokens.spaceSM,
                      horizontal: DesignTokens.spaceMD,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusSM),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _checkForUpdates(BuildContext context) async {
    // Show loading toast
    BotToast.showLoading(
      duration: const Duration(seconds: 3),
    );

    try {
      await AutoUpdateService.checkForUpdates();

      // Show success message
      BotToast.showText(
        text: 'Update check completed successfully!',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      // Show error message
      BotToast.showText(
        text: 'Failed to check for updates: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }
}
