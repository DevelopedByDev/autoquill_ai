import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/core/theme/design_tokens.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_event.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';
import 'package:autoquill_ai/widgets/minimalist_card.dart';

class AssistantModelsSection extends StatelessWidget {
  const AssistantModelsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assistant Models',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: DesignTokens.spaceSM),
          Text(
            'Select the model to use for AI assistant responses.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: DesignTokens.spaceMD),
          _buildAssistantModelSelection(context, state),
        ],
      );
    });
  }

  Widget _buildAssistantModelSelection(
      BuildContext context, SettingsState state) {
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
            'Choose the model that best suits your assistant needs based on performance and capabilities.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: DesignTokens.spaceMD),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? DesignTokens.darkSurface
                  : DesignTokens.lightSurface,
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
          'llama-3.3-70b-versatile',
          'Llama 3.3 70B Versatile',
          'Most capable model with balanced performance',
          'Best for complex reasoning and comprehensive responses',
          state.assistantModel == 'llama-3.3-70b-versatile',
          onTap: () => _selectModel(context, 'llama-3.3-70b-versatile'),
          isFirst: true,
        ),
        Divider(
          height: 1,
          thickness: 1,
          color:
              isDarkMode ? DesignTokens.darkDivider : DesignTokens.lightDivider,
        ),
        _buildModelOption(
          context,
          'llama3-70b-8192',
          'Llama 3 70B',
          'High-performance model with extended context',
          'Excellent for detailed analysis and long conversations',
          state.assistantModel == 'llama3-70b-8192',
          onTap: () => _selectModel(context, 'llama3-70b-8192'),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color:
              isDarkMode ? DesignTokens.darkDivider : DesignTokens.lightDivider,
        ),
        _buildModelOption(
          context,
          'gemma2-9b-it',
          'Gemma 2 9B Instruct',
          'Lightweight model with fast responses',
          'Good for quick tasks and simple interactions',
          state.assistantModel == 'gemma2-9b-it',
          onTap: () => _selectModel(context, 'gemma2-9b-it'),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildModelOption(BuildContext context, String modelId, String title,
      String subtitle, String description, bool isSelected,
      {required VoidCallback onTap,
      bool isFirst = false,
      bool isLast = false}) {
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
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.8),
                        ),
                  ),
                  const SizedBox(height: DesignTokens.spaceXXS),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
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
                      : isDarkMode
                          ? DesignTokens.darkDivider
                          : DesignTokens.lightDivider,
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
    context.read<SettingsBloc>().add(SaveAssistantModel(modelId));
  }
}
