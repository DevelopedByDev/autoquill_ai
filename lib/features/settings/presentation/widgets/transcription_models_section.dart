import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/core/theme/design_tokens.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_event.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';
import 'package:autoquill_ai/widgets/minimalist_card.dart';

class TranscriptionModelsSection extends StatelessWidget {
  const TranscriptionModelsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transcription Models',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: DesignTokens.spaceSM),
            Text(
              'Select the model to use for audio transcription.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: DesignTokens.spaceMD),
            _buildTranscriptionModelDropdown(context, state),
          ],
        );
      }
    );
  }

  Widget _buildTranscriptionModelDropdown(BuildContext context, SettingsState state) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return MinimalistCard(
      padding: const EdgeInsets.all(DesignTokens.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Model',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: DesignTokens.fontWeightMedium,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceSM),
          Text(
            'Choose the model that best suits your needs based on accuracy and speed.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMD),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? DesignTokens.darkSurface : DesignTokens.lightSurface,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
            ),
            child: _buildModelOptions(context, state),
          ),
        ],
      ),
    );
  }
  
  Widget _buildModelOptions(BuildContext context, SettingsState state) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        _buildModelOption(
          context,
          'whisper-large-v3',
          'Whisper Large v3',
          'Multilingual with highest accuracy',
          'Best for complex audio or multiple languages',
          state.transcriptionModel == 'whisper-large-v3',
          onTap: () => _selectModel(context, 'whisper-large-v3'),
          isFirst: true,
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: isDarkMode ? DesignTokens.darkDivider : DesignTokens.lightDivider,
        ),
        _buildModelOption(
          context,
          'whisper-large-v3-turbo',
          'Whisper Large v3 Turbo',
          'Multilingual with faster processing',
          'Good balance between speed and accuracy',
          state.transcriptionModel == 'whisper-large-v3-turbo',
          onTap: () => _selectModel(context, 'whisper-large-v3-turbo'),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: isDarkMode ? DesignTokens.darkDivider : DesignTokens.lightDivider,
        ),
        _buildModelOption(
          context,
          'distil-whisper-large-v3-en',
          'Distil Whisper (English)',
          'English-only with fastest processing',
          'Best for quick transcriptions of English audio',
          state.transcriptionModel == 'distil-whisper-large-v3-en',
          onTap: () => _selectModel(context, 'distil-whisper-large-v3-en'),
          isLast: true,
        ),
      ],
    );
  }
  
  Widget _buildModelOption(
    BuildContext context,
    String modelId,
    String title,
    String subtitle,
    String description,
    bool isSelected,
    {required VoidCallback onTap, bool isFirst = false, bool isLast = false}
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? Radius.circular(DesignTokens.radiusMD) : Radius.zero,
        bottom: isLast ? Radius.circular(DesignTokens.radiusMD) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceMD),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: DesignTokens.fontWeightMedium,
                      color: isSelected ? DesignTokens.vibrantCoral : null,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceXXS),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected 
                          ? DesignTokens.vibrantCoral 
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceXXS),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DesignTokens.spaceSM),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? DesignTokens.vibrantCoral 
                      : isDarkMode ? DesignTokens.darkDivider : DesignTokens.lightDivider,
                  width: 2,
                ),
              ),
              child: isSelected 
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: DesignTokens.vibrantCoral,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
  
  void _selectModel(BuildContext context, String modelId) {
    context.read<SettingsBloc>().add(SaveTranscriptionModel(modelId));
  }
}
