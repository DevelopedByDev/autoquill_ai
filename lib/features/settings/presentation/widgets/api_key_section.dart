import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_event.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';

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
            const Text(
              'API Key',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _apiKeyController,
                        obscureText: !state.isApiKeyVisible,
                        decoration: const InputDecoration(
                          labelText: 'Groq API Key',
                        ),
                        onChanged: (value) {
                          context.read<SettingsBloc>().add(SaveApiKey(value));
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            state.isApiKeyVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            context
                                .read<SettingsBloc>()
                                .add(ToggleApiKeyVisibility());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.save),
                          onPressed: () {
                            final apiKey = _apiKeyController.text;
                            if (apiKey.isNotEmpty) {
                              context.read<SettingsBloc>().add(SaveApiKey(apiKey));
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _apiKeyController.clear();
                            context
                                .read<SettingsBloc>()
                                .add(DeleteApiKey());
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
    );
  }
}
