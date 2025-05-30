import 'package:autoquill_ai/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:autoquill_ai/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:autoquill_ai/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class ApiKeyStep extends StatefulWidget {
  const ApiKeyStep({super.key});

  @override
  State<ApiKeyStep> createState() => _ApiKeyStepState();
}

class _ApiKeyStepState extends State<ApiKeyStep> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Step title
            Text(
              'Connect to Groq',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              'Enter your Groq API key to power AutoQuill',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // API key input field
            BlocBuilder<OnboardingBloc, OnboardingState>(
              buildWhen: (previous, current) =>
                  previous.apiKey != current.apiKey ||
                  previous.apiKeyStatus != current.apiKeyStatus,
              builder: (context, state) {
                // Update controller if API key is set in state but not in controller
                if (state.apiKey.isNotEmpty && _apiKeyController.text.isEmpty) {
                  _apiKeyController.text = state.apiKey;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Groq API Key',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _apiKeyController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: 'Enter your Groq API key',
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .hintColor
                              .withValues(alpha: 0.7),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                            width: 1.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                        prefixIcon: Icon(
                          Icons.vpn_key,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.7),
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Toggle visibility
                            IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Theme.of(context)
                                    .iconTheme
                                    .color
                                    ?.withValues(alpha: 0.7),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            // Clear button
                            if (_apiKeyController.text.isNotEmpty)
                              IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color
                                      ?.withValues(alpha: 0.7),
                                ),
                                onPressed: () {
                                  _apiKeyController.clear();
                                  context.read<OnboardingBloc>().add(
                                        const UpdateApiKey(apiKey: ''),
                                      );
                                },
                              ),
                          ],
                        ),
                        // Show validation status
                        errorText:
                            state.apiKeyStatus == ApiKeyValidationStatus.invalid
                                ? 'Invalid API key'
                                : null,
                        // Show loading indicator
                        suffixIconConstraints:
                            const BoxConstraints(minWidth: 100),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onChanged: (value) {
                        context.read<OnboardingBloc>().add(
                              UpdateApiKey(apiKey: value),
                            );
                      },
                    ),
                    const SizedBox(height: 8),

                    // Validation status
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child:
                          _buildValidationStatus(context, state.apiKeyStatus),
                    ),

                    // Validate button
                    const SizedBox(height: 16),
                    Center(
                      child: SizedBox(
                        width: 160,
                        child: ElevatedButton(
                          onPressed: state.apiKeyStatus !=
                                      ApiKeyValidationStatus.validating &&
                                  _apiKeyController.text.isNotEmpty
                              ? () {
                                  context.read<OnboardingBloc>().add(
                                        ValidateApiKey(
                                            apiKey: _apiKeyController.text),
                                      );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: state.apiKeyStatus ==
                                  ApiKeyValidationStatus.validating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Validate Key'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Help section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Where to get a Groq API key?',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '1. Create a free account at groq.com (click the button below)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '2. Go to API Keys section in your dashboard and click "Create API key"',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '3. Name it "AutoQuill", click Submit',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '4. Copy the API key, click Done and paste the key in the field above',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: SizedBox(
                      width: 160,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('groq.com'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          final Uri url =
                              Uri.parse('https://console.groq.com/keys');
                          try {
                            await url_launcher.launchUrl(url);
                          } catch (e) {
                            // Handle error if URL can't be launched
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Could not open URL')),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationStatus(
      BuildContext context, ApiKeyValidationStatus status) {
    switch (status) {
      case ApiKeyValidationStatus.valid:
        return Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'API key is valid',
              style: TextStyle(
                color: Colors.green,
                fontSize: 14,
              ),
            ),
          ],
        );
      case ApiKeyValidationStatus.invalid:
        return Row(
          children: [
            Icon(
              Icons.error,
              color: Theme.of(context).colorScheme.error,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'API key is invalid',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            ),
          ],
        );
      case ApiKeyValidationStatus.validating:
        return Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Validating...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 14,
              ),
            ),
          ],
        );
      case ApiKeyValidationStatus.initial:
        return const SizedBox.shrink();
    }
  }
}
