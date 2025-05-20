import 'package:autoquill_ai/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:autoquill_ai/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:autoquill_ai/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseToolsStep extends StatelessWidget {
  const ChooseToolsStep({Key? key}) : super(key: key);

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
              'How do you want to use AutoQuill?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Description
            Text(
              'Choose one or both options below',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            
            // Transcription tool card
            BlocBuilder<OnboardingBloc, OnboardingState>(
              buildWhen: (previous, current) => 
                previous.transcriptionEnabled != current.transcriptionEnabled,
              builder: (context, state) {
                return _buildToolCard(
                  context,
                  icon: Icons.mic,
                  title: 'Transcribe',
                  description: 'Convert speech to clean text',
                  isSelected: state.transcriptionEnabled,
                  onToggle: (value) {
                    context.read<OnboardingBloc>().add(
                      UpdateSelectedTools(
                        transcriptionEnabled: value,
                        assistantEnabled: state.assistantEnabled,
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            
            // Assistant tool card
            BlocBuilder<OnboardingBloc, OnboardingState>(
              buildWhen: (previous, current) => 
                previous.assistantEnabled != current.assistantEnabled,
              builder: (context, state) {
                return _buildToolCard(
                  context,
                  icon: Icons.chat_bubble_outline,
                  title: 'Assistant',
                  description: 'Ask questions, get answers instantly',
                  isSelected: state.assistantEnabled,
                  onToggle: (value) {
                    context.read<OnboardingBloc>().add(
                      UpdateSelectedTools(
                        transcriptionEnabled: state.transcriptionEnabled,
                        assistantEnabled: value,
                      ),
                    );
                  },
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Warning message if no tool is selected
            BlocBuilder<OnboardingBloc, OnboardingState>(
              buildWhen: (previous, current) => 
                previous.canProceedFromToolSelection != current.canProceedFromToolSelection,
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: !state.canProceedFromToolSelection
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Please select at least one option to continue',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required Function(bool) onToggle,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
          width: 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isSelected,
            onChanged: onToggle,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
