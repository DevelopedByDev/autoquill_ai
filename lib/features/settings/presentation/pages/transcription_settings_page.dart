import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/core/theme/design_tokens.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_event.dart';
import 'package:autoquill_ai/features/settings/presentation/widgets/transcription_hotkey_settings_section.dart';
import 'package:autoquill_ai/features/settings/presentation/widgets/smart_transcription_section.dart';
import 'package:autoquill_ai/core/services/whisper_kit_service.dart';
import 'package:bot_toast/bot_toast.dart';

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
              const SizedBox(height: DesignTokens.spaceXXL),

              // Local Transcription Settings Section
              _buildLocalTranscriptionSection(context),

              // Bottom padding for scrolling
              const SizedBox(height: DesignTokens.spaceXXL),
            ],
          ),
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
                // border: Border.all(
                //   color: isDarkMode
                //       ? DesignTokens.trueWhite.withValues(alpha: 0.1)
                //       : DesignTokens.pureBlack.withValues(alpha: 0.08),
                // ),
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

  /// Maps display names to actual model names
  String _getDisplayName(String modelName) {
    switch (modelName) {
      case 'base':
        return 'base';
      case 'small_216MB':
        return 'small';
      case 'medium':
        return 'medium';
      case 'large-v3_947MB':
        return 'large';
      case 'large-v3-v20240930_turbo_632MB':
        return 'turbo (recommended)';
      default:
        return modelName.toUpperCase();
    }
  }

  Widget _buildModelSelectionSection(
      BuildContext context, SettingsState state, bool isDarkMode) {
    final models = [
      {
        'name': 'large-v3-v20240930_turbo_632MB',
        'size': '~632 MB',
        'description': 'Very high accuracy, high speed'
      },
      {
        'name': 'large-v3_947MB',
        'size': '~947 MB',
        'description': 'Highest accuracy, slowest speed'
      },
      {
        'name': 'medium',
        'size': '~1.5 GB',
        'description': 'Medium accuracy, medium speed'
      },
      {
        'name': 'small_216MB',
        'size': '~216 MB',
        'description': 'Low accuracy, fast speed'
      },
      {
        'name': 'base',
        'size': '~150 MB',
        'description': 'Lowest accuracy, fastest speed'
      },
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
            // border: Border.all(
            //   color: isDarkMode
            //       ? DesignTokens.trueWhite.withValues(alpha: 0.08)
            //       : DesignTokens.pureBlack.withValues(alpha: 0.05),
            // ),
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
                              _getDisplayName(model['name']!),
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
                  onChanged: state.downloadedModels.contains(model['name']!)
                      ? (value) {
                          if (value != null) {
                            context
                                .read<SettingsBloc>()
                                .add(SelectLocalModel(value));
                          }
                        }
                      : null, // Disable radio button if model not downloaded
                  activeColor: DesignTokens.vibrantCoral,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: DesignTokens.spaceMD),
        _buildOpenModelsDirectoryButton(context, isDarkMode),
        const SizedBox(height: DesignTokens.spaceXS),
        _buildHelpSection(context, state, isDarkMode),
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

  Widget _buildOpenModelsDirectoryButton(
      BuildContext context, bool isDarkMode) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _openModelsDirectory(context),
            icon: Icon(
              Icons.folder_open_rounded,
              size: DesignTokens.iconSizeSM,
            ),
            label: Text(
              'Open Models Folder',
              style: TextStyle(
                fontWeight: DesignTokens.fontWeightMedium,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode
                  ? DesignTokens.trueWhite.withValues(alpha: 0.1)
                  : DesignTokens.pureBlack.withValues(alpha: 0.08),
              foregroundColor:
                  isDarkMode ? DesignTokens.trueWhite : DesignTokens.pureBlack,
              padding: const EdgeInsets.symmetric(
                vertical: DesignTokens.spaceSM,
                horizontal: DesignTokens.spaceMD,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                side: BorderSide(
                  color: isDarkMode
                      ? DesignTokens.trueWhite.withValues(alpha: 0.2)
                      : DesignTokens.pureBlack.withValues(alpha: 0.1),
                ),
              ),
              elevation: 0,
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpSection(
      BuildContext context, SettingsState state, bool isDarkMode) {
    // Check if there are any download errors
    final hasDownloadErrors = state.modelDownloadErrors.isNotEmpty;
    final hasAuthErrors = state.modelDownloadErrors.values.any((error) =>
        error.toLowerCase().contains('authorization') ||
        error.toLowerCase().contains('authorizationrequired'));

    if (!hasDownloadErrors) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignTokens.spaceSM),
      decoration: BoxDecoration(
        color: hasAuthErrors
            ? Colors.orange.withValues(alpha: 0.1)
            : Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
        // border: Border.all(
        //   color: hasAuthErrors
        //       ? Colors.orange.withValues(alpha: 0.3)
        //       : Colors.blue.withValues(alpha: 0.3),
        // ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasAuthErrors
                    ? Icons.warning_rounded
                    : Icons.help_outline_rounded,
                color: hasAuthErrors ? Colors.orange : Colors.blue,
                size: DesignTokens.iconSizeSM,
              ),
              const SizedBox(width: DesignTokens.spaceXS),
              Text(
                hasAuthErrors ? 'Authorization Required' : 'Download Help',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: DesignTokens.fontWeightSemiBold,
                      color: hasAuthErrors ? Colors.orange : Colors.blue,
                    ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceXS),
          Text(
            hasAuthErrors
                ? 'Model downloads require a Hugging Face token. Run the setup script or manually configure authentication.'
                : 'Having trouble downloading models? Check the README for troubleshooting steps.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDarkMode
                      ? DesignTokens.trueWhite.withValues(alpha: 0.8)
                      : DesignTokens.pureBlack.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: DesignTokens.spaceSM),
          Row(
            children: [
              if (hasAuthErrors) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showTokenSetupInstructions(context),
                    icon: Icon(
                      Icons.key_rounded,
                      size: DesignTokens.iconSizeXS,
                    ),
                    label: Text(
                      'Setup Token',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: DesignTokens.fontWeightMedium,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: DesignTokens.spaceXS,
                        horizontal: DesignTokens.spaceSM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusXS),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceXS),
              ],
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showTroubleshootingInfo(context),
                  icon: Icon(
                    Icons.info_outline_rounded,
                    size: DesignTokens.iconSizeXS,
                  ),
                  label: Text(
                    'More Help',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: DesignTokens.fontWeightMedium,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        hasAuthErrors ? Colors.orange : Colors.blue,
                    side: BorderSide(
                      color: hasAuthErrors ? Colors.orange : Colors.blue,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: DesignTokens.spaceXS,
                      horizontal: DesignTokens.spaceSM,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusXS),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openModelsDirectory(BuildContext context) async {
    try {
      final success = await WhisperKitService.openModelsDirectory();

      if (success) {
        BotToast.showText(
          text: 'Models folder opened successfully',
          duration: const Duration(seconds: 2),
        );
      } else {
        throw Exception('Failed to open models directory');
      }
    } catch (e) {
      BotToast.showText(
        text: 'Failed to open models folder: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _showTokenSetupInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.key_rounded, color: Colors.orange),
            const SizedBox(width: 8),
            Text('Setup Hugging Face Token'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To download WhisperKit models, you need a Hugging Face access token:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '1. Go to https://huggingface.co/',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '2. Create a free account',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '3. Visit Settings → Access Tokens',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '4. Create a token with "Read" permissions',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Run in Terminal:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    './setup_hf_token.sh',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showTroubleshootingInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline_rounded, color: Colors.blue),
            const SizedBox(width: 8),
            Text('Download Troubleshooting'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Common solutions for model download issues:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildTroubleshootingItem(
              context,
              'Authorization Required',
              'Set up a Hugging Face token using the setup script',
            ),
            _buildTroubleshootingItem(
              context,
              'Network Issues',
              'Check your internet connection and try again',
            ),
            _buildTroubleshootingItem(
              context,
              'Manual Download',
              'Download models manually from huggingface.co/argmaxinc/whisperkit-coreml',
            ),
            _buildTroubleshootingItem(
              context,
              'Use Cloud Only',
              'Disable local transcription and use OpenAI API instead',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingItem(
      BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $title',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            '  $description',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
