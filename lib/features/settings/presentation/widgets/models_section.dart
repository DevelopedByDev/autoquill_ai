import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_event.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';

class ModelsSection extends StatelessWidget {
  const ModelsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Models',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTranscriptionModelDropdown(context, state),
            const SizedBox(height: 16),
            _buildAssistantModelDropdown(context, state),
            const SizedBox(height: 16),
            _buildAgentModelDropdown(context, state),
          ],
        );
      }
    );
  }

  Widget _buildTranscriptionModelDropdown(BuildContext context, SettingsState state) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Text('Transcription model'),
            const Spacer(),
            DropdownButton<String>(
              value: state.transcriptionModel,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  context.read<SettingsBloc>().add(
                        SaveTranscriptionModel(newValue),
                      );
                }
              },
              items: [
                DropdownMenuItem(
                  value: 'whisper-large-v3',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('whisper-large-v3'),
                      Text(
                        'multilingual, more accurate',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'whisper-large-v3-turbo',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('whisper-large-v3-turbo'),
                      Text(
                        'multilingual, faster',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'distil-whisper-large-v3-en',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('distil-whisper-large-v3-en'),
                      Text(
                        'english, fastest',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistantModelDropdown(BuildContext context, SettingsState state) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Text('Assistant model'),
            const Spacer(),
            DropdownButton<String>(
              value: state.assistantModel,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  context.read<SettingsBloc>().add(
                        SaveAssistantModel(newValue),
                      );
                }
              },
              items: [
                DropdownMenuItem(
                  value: 'llama-3.3-70b-versatile',
                  child: const Text('llama-3.3-70b-versatile'),
                ),
                DropdownMenuItem(
                  value: 'gemma2-9b-it',
                  child: const Text('gemma2-9b-it'),
                ),
                DropdownMenuItem(
                  value: 'llama3-70b-8192',
                  child: const Text('llama3-70b-8192'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentModelDropdown(BuildContext context, SettingsState state) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Text('Agent model'),
            const Spacer(),
            DropdownButton<String>(
              value: state.agentModel,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  context.read<SettingsBloc>().add(
                        SaveAgentModel(newValue),
                      );
                }
              },
              items: [
                DropdownMenuItem(
                  value: 'compound-beta-mini',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('compound-beta-mini'),
                      Text(
                        'search only',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'compound-beta',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('compound-beta'),
                      Text(
                        'search + code execution',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'meta-llama/llama-4-scout-17b-16e-instruct',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('compound-beta + llama 4 17b-16e-instruct'),
                      Text(
                        'search + code execution + screen context',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
