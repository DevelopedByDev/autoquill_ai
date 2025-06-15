import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/core/theme/design_tokens.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_event.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';
import 'package:autoquill_ai/widgets/minimalist_card.dart';

class SmartTranscriptionSection extends StatelessWidget {
  const SmartTranscriptionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
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
                  Icons.menu_open_rounded,
                  color: DesignTokens.trueWhite,
                  size: DesignTokens.iconSizeSM,
                ),
              ),
              const SizedBox(width: DesignTokens.spaceSM),
              Text(
                'Smart Transcription',
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
          _buildSmartTranscriptionToggle(context, state),
        ],
      );
    });
  }

  Widget _buildSmartTranscriptionToggle(
      BuildContext context, SettingsState state) {
    return MinimalistCard(
      padding: const EdgeInsets.all(DesignTokens.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Smart Transcription',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: DesignTokens.fontWeightMedium,
                    ),
              ),
              Switch(
                value: state.smartTranscriptionEnabled,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(ToggleSmartTranscription());
                },
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceXS),
          Text(
            'When enabled, transcriptions are enhanced with intelligent formatting including emoji conversion, proper casing, numbered lists, and email formatting.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
          if (state.smartTranscriptionEnabled) ...[
            const SizedBox(height: DesignTokens.spaceSM),
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceSM),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Examples:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: DesignTokens.fontWeightMedium,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: DesignTokens.spaceXS),
                  Text(
                    '• "heart emoji" → ❤️\n'
                    '• "in all caps excited" → "EXCITED"\n'
                    '• "number 1 apples, number 2 bananas" → numbered list\n'
                    '• "john dot doe at email dot com" → john.doe@email.com',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.8),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
