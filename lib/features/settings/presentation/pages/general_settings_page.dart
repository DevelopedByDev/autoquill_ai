import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_event.dart';
import 'package:autoquill_ai/features/settings/presentation/widgets/api_key_section.dart';
import 'package:autoquill_ai/features/settings/presentation/widgets/theme_settings_section.dart';
import 'package:autoquill_ai/core/services/auto_update_service.dart';
import 'package:autoquill_ai/core/theme/design_tokens.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

              // Sound Settings Section
              _buildSoundSettingsSection(context),

              const SizedBox(height: 32),

              // Local Transcription Settings Section
              _buildLocalTranscriptionSection(context),

              const SizedBox(height: 32),

              // Data Location Section
              _buildDataLocationSection(context),

              const SizedBox(height: 32),

              // App Updates Section
              _buildAppUpdatesSection(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSoundSettingsSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spaceXS),
                  decoration: BoxDecoration(
                    gradient: DesignTokens.greenGradient,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                  ),
                  child: Icon(
                    Icons.volume_up_rounded,
                    color: DesignTokens.trueWhite,
                    size: DesignTokens.iconSizeSM,
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceSM),
                Text(
                  'Sound Settings',
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
              'Control sound effects and audio notifications throughout the app.',
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enable Sound Effects',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: DesignTokens.fontWeightMedium,
                                    color: isDarkMode
                                        ? DesignTokens.trueWhite
                                        : DesignTokens.pureBlack,
                                  ),
                        ),
                        const SizedBox(height: DesignTokens.spaceXS),
                        Text(
                          'Play audio feedback for recording, typing, and error notifications.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDarkMode
                                        ? DesignTokens.trueWhite
                                            .withValues(alpha: 0.7)
                                        : DesignTokens.pureBlack
                                            .withValues(alpha: 0.6),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceMD),
                  Switch(
                    value: state.soundEnabled,
                    onChanged: (value) {
                      context.read<SettingsBloc>().add(ToggleSound());
                    },
                    activeColor: DesignTokens.vibrantCoral,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocalTranscriptionSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
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
                    Icons.computer_rounded,
                    color: DesignTokens.trueWhite,
                    size: DesignTokens.iconSizeSM,
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceSM),
                Text(
                  'Local Transcription',
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
              'Use local models for transcription without internet connectivity.',
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enable Local Transcription',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: DesignTokens.fontWeightMedium,
                                    color: isDarkMode
                                        ? DesignTokens.trueWhite
                                        : DesignTokens.pureBlack,
                                  ),
                            ),
                            const SizedBox(height: DesignTokens.spaceXS),
                            Text(
                              'Process transcriptions locally using downloaded models.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isDarkMode
                                        ? DesignTokens.trueWhite
                                            .withValues(alpha: 0.7)
                                        : DesignTokens.pureBlack
                                            .withValues(alpha: 0.6),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spaceMD),
                      Switch(
                        value: state.localTranscriptionEnabled,
                        onChanged: (value) {
                          context
                              .read<SettingsBloc>()
                              .add(ToggleLocalTranscription());
                        },
                        activeColor: DesignTokens.vibrantCoral,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                  if (state.localTranscriptionEnabled) ...[
                    const SizedBox(height: DesignTokens.spaceLG),
                    _buildModelSelectionSection(context, state, isDarkMode),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModelSelectionSection(
      BuildContext context, SettingsState state, bool isDarkMode) {
    final models = [
      {
        'name': 'base',
        'size': '~150 MB',
        'description': 'Fastest, good quality'
      },
      {
        'name': 'small',
        'size': '~450 MB',
        'description': 'Good speed and quality'
      },
      {
        'name': 'medium',
        'size': '~1.5 GB',
        'description': 'Balanced performance'
      },
      {
        'name': 'large',
        'size': '~3.1 GB',
        'description': 'High quality, slower'
      },
      {'name': 'turbo', 'size': '~800 MB', 'description': 'Fast and accurate'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Model',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: DesignTokens.fontWeightSemiBold,
                color: isDarkMode
                    ? DesignTokens.trueWhite
                    : DesignTokens.pureBlack,
              ),
        ),
        const SizedBox(height: DesignTokens.spaceSM),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? DesignTokens.trueWhite.withValues(alpha: 0.03)
                : DesignTokens.pureBlack.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
            border: Border.all(
              color: isDarkMode
                  ? DesignTokens.trueWhite.withValues(alpha: 0.08)
                  : DesignTokens.pureBlack.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            children: models.map((model) {
              final isSelected = state.selectedLocalModel == model['name'];
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDarkMode
                          ? DesignTokens.trueWhite.withValues(alpha: 0.05)
                          : DesignTokens.pureBlack.withValues(alpha: 0.03),
                      width: models.last == model ? 0 : 1,
                    ),
                  ),
                ),
                child: RadioListTile<String>(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spaceMD,
                    vertical: DesignTokens.spaceXS,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              model['name']!.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: DesignTokens.fontWeightMedium,
                                    color: isDarkMode
                                        ? DesignTokens.trueWhite
                                        : DesignTokens.pureBlack,
                                  ),
                            ),
                            const SizedBox(height: DesignTokens.spaceXXS),
                            Text(
                              '${model['size']} • ${model['description']}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
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
                      _buildModelActionButton(
                          context, model['name']!, state, isDarkMode),
                    ],
                  ),
                  value: model['name']!,
                  groupValue: state.selectedLocalModel,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<SettingsBloc>().add(SelectLocalModel(value));
                    }
                  },
                  activeColor: DesignTokens.vibrantCoral,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildModelActionButton(BuildContext context, String modelName,
      SettingsState state, bool isDarkMode) {
    final isDownloaded = state.downloadedModels.contains(modelName);
    final isDownloading = state.modelDownloadProgress.containsKey(modelName);
    final downloadProgress = state.modelDownloadProgress[modelName] ?? 0.0;
    final hasError = state.modelDownloadErrors.containsKey(modelName);

    if (isDownloading) {
      // Show progress indicator
      return Container(
        decoration: BoxDecoration(
          color: DesignTokens.vibrantCoral.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
        ),
        width: 60,
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: downloadProgress,
              strokeWidth: 2,
              backgroundColor: DesignTokens.vibrantCoral.withValues(alpha: 0.2),
              valueColor:
                  AlwaysStoppedAnimation<Color>(DesignTokens.vibrantCoral),
            ),
            Text(
              '${(downloadProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: DesignTokens.fontWeightMedium,
                color: DesignTokens.vibrantCoral,
              ),
            ),
          ],
        ),
      );
    } else if (isDownloaded) {
      // Show downloaded indicator with delete option
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: DesignTokens.emeraldGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
            ),
            child: IconButton(
              onPressed: null, // Just shows status
              icon: Icon(
                Icons.check_circle_rounded,
                color: DesignTokens.emeraldGreen,
                size: DesignTokens.iconSizeSM,
              ),
              iconSize: DesignTokens.iconSizeSM,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: const EdgeInsets.all(DesignTokens.spaceXS),
            ),
          ),
          const SizedBox(width: DesignTokens.spaceXS),
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
            ),
            child: IconButton(
              onPressed: () {
                context.read<SettingsBloc>().add(DeleteLocalModel(modelName));
              },
              icon: Icon(
                Icons.delete_rounded,
                color: Colors.red,
                size: DesignTokens.iconSizeSM,
              ),
              iconSize: DesignTokens.iconSizeSM,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: const EdgeInsets.all(DesignTokens.spaceXS),
            ),
          ),
        ],
      );
    } else {
      // Show download button
      return Container(
        decoration: BoxDecoration(
          color: hasError
              ? Colors.red.withValues(alpha: 0.1)
              : DesignTokens.vibrantCoral.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
        ),
        child: IconButton(
          onPressed: () {
            context.read<SettingsBloc>().add(DownloadModel(modelName));
          },
          icon: Icon(
            hasError ? Icons.error_rounded : Icons.download_rounded,
            color: hasError ? Colors.red : DesignTokens.vibrantCoral,
            size: DesignTokens.iconSizeSM,
          ),
          iconSize: DesignTokens.iconSizeSM,
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          padding: const EdgeInsets.all(DesignTokens.spaceXS),
        ),
      );
    }
  }

  Widget _buildDataLocationSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceXS),
              decoration: BoxDecoration(
                gradient: DesignTokens.blueGradient,
                borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
              ),
              child: Icon(
                Icons.folder_rounded,
                color: DesignTokens.trueWhite,
                size: DesignTokens.iconSizeSM,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceSM),
            Text(
              'Data Location',
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
          'Access your app data including transcriptions and recordings.',
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
                  Expanded(
                    child: Text(
                      'App data is stored securely in your system\'s Application Support directory.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDarkMode
                                ? DesignTokens.trueWhite.withValues(alpha: 0.7)
                                : DesignTokens.pureBlack.withValues(alpha: 0.6),
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spaceMD),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openDataLocation(context),
                  icon: Icon(
                    Icons.folder_open_rounded,
                    size: DesignTokens.iconSizeSM,
                  ),
                  label: Text(
                    'Open Data Folder',
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
                gradient: DesignTokens.purpleGradient,
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
          'AutoQuill automatically checks for updates. You can also manually check for updates below. Current version: v1.1.0',
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

  void _openDataLocation(BuildContext context) async {
    try {
      // Get the Application Support directory (same as used in main.dart)
      final directory = await getApplicationSupportDirectory();
      final uri = Uri.file(directory.path);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        BotToast.showText(
          text: 'Data folder opened successfully',
          duration: const Duration(seconds: 2),
        );
      } else {
        throw Exception('Cannot open folder on this platform');
      }
    } catch (e) {
      BotToast.showText(
        text: 'Failed to open data folder: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }
}
