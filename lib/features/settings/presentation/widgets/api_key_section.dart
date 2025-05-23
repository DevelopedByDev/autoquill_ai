import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/core/theme/design_tokens.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_event.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';
import 'package:autoquill_ai/widgets/minimalist_card.dart';
import 'package:autoquill_ai/widgets/minimalist_input.dart';
import 'package:autoquill_ai/widgets/minimalist_button.dart';

class ApiKeySection extends StatelessWidget {
  ApiKeySection({super.key});

  final TextEditingController _apiKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        _apiKeyController.text = state.apiKey ?? '';
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API Key',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: DesignTokens.spaceSM),
            Text(
              'Enter your Groq API key to use transcription and assistant features.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: DesignTokens.spaceMD),
            MinimalistCard(
              padding: const EdgeInsets.all(DesignTokens.spaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MinimalistInput(
                          controller: _apiKeyController,
                          label: 'Groq API Key',
                          placeholder: 'Enter your API key here',
                          isObscured: !state.isApiKeyVisible,
                          showObscureToggle: true,
                          prefixIcon: Icons.key,
                          onChanged: (value) {
                            // We'll save on button press instead of on every change
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spaceMD),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MinimalistButton(
                        variant: MinimalistButtonVariant.secondary,
                        label: 'Clear',
                        icon: Icons.delete_outline,
                        onPressed: () {
                          _apiKeyController.clear();
                          context.read<SettingsBloc>().add(DeleteApiKey());
                        },
                      ),
                      const SizedBox(width: DesignTokens.spaceSM),
                      MinimalistButton(
                        variant: MinimalistButtonVariant.primary,
                        label: 'Save API Key',
                        icon: Icons.save,
                        onPressed: () {
                          final apiKey = _apiKeyController.text;
                          if (apiKey.isNotEmpty) {
                            context.read<SettingsBloc>().add(SaveApiKey(apiKey));
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (state.apiKey?.isNotEmpty ?? false) ...[  
              const SizedBox(height: DesignTokens.spaceSM),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: DesignTokens.vibrantCoral,
                    size: 16,
                  ),
                  const SizedBox(width: DesignTokens.spaceXS),
                  Text(
                    'API key saved',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: DesignTokens.vibrantCoral,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
