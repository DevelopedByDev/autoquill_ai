import 'package:autoquill_ai/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:autoquill_ai/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompletedStep extends StatelessWidget {
  const CompletedStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success animation
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Completion title
                Text(
                  'You\'re All Set!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Description
                Text(
                  'AutoQuill AI is ready to help you transcribe and assist',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Hotkey reminders
                if (state.transcriptionEnabled)
                  _buildHotkeyReminder(
                    context,
                    icon: Icons.mic,
                    title: 'Transcription',
                    hotkeyText: _formatHotkey(state.transcriptionHotkey),
                  ),
                
                if (state.transcriptionEnabled && state.assistantEnabled)
                  const SizedBox(height: 24),
                
                if (state.assistantEnabled)
                  _buildHotkeyReminder(
                    context,
                    icon: Icons.chat_bubble_outline,
                    title: 'Assistant',
                    hotkeyText: _formatHotkey(state.assistantHotkey),
                  ),
                
                const SizedBox(height: 48),
                
                // Get started button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigation is handled in onboarding_page.dart
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                    ),
                    child: const Text(
                      'Start Using AutoQuill AI',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHotkeyReminder(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String hotkeyText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Press $hotkeyText',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatHotkey(dynamic hotkey) {
    if (hotkey == null) {
      return 'No hotkey set';
    }
    
    try {
      final List<String> parts = [];
      
      if (hotkey.modifiers != null) {
        for (final modifier in hotkey.modifiers) {
          switch (modifier.toString()) {
            case 'KeyModifier.alt':
              parts.add('Alt');
              break;
            case 'KeyModifier.control':
              parts.add('Ctrl');
              break;
            case 'KeyModifier.shift':
              parts.add('Shift');
              break;
            case 'KeyModifier.meta':
              parts.add('⌘');
              break;
          }
        }
      }
      
      // Add the key code in a user-friendly format
      final keyCodeStr = hotkey.keyCode.toString().split('.').last;
      parts.add(keyCodeStr == 'space' ? 'Space' : keyCodeStr.replaceFirst('key', '').toUpperCase());
      
      return parts.join(' + ');
    } catch (e) {
      return 'Custom Hotkey';
    }
  }
}
