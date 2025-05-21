import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../../../../widgets/record_hotkey_dialog.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class HotkeysStep extends StatelessWidget {
  const HotkeysStep({super.key});

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
              'Set Your Shortcuts',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Description
            Text(
              'Configure hotkeys to quickly access AutoQuill AI features',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            
            // Transcription hotkey
            BlocBuilder<OnboardingBloc, OnboardingState>(
              buildWhen: (previous, current) => 
                previous.transcriptionEnabled != current.transcriptionEnabled ||
                previous.transcriptionHotkey != current.transcriptionHotkey,
              builder: (context, state) {
                if (!state.transcriptionEnabled) {
                  return const SizedBox.shrink();
                }
                
                return _buildHotkeyCard(
                  context,
                  icon: Icons.mic,
                  title: 'Transcription Hotkey',
                  description: 'Press this combination to start transcribing audio',
                  hotkey: state.transcriptionHotkey,
                  onRecordHotkey: (hotkey) {
                    context.read<OnboardingBloc>().add(
                      UpdateTranscriptionHotkey(hotkey: hotkey),
                    );
                  },
                  onTestHotkey: () {
                    // Show a snackbar to simulate transcription
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transcription started! (Test)'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
            ),
            
            // Add spacing if both hotkeys are shown
            BlocBuilder<OnboardingBloc, OnboardingState>(
              buildWhen: (previous, current) => 
                previous.transcriptionEnabled != current.transcriptionEnabled ||
                previous.assistantEnabled != current.assistantEnabled,
              builder: (context, state) {
                return state.transcriptionEnabled && state.assistantEnabled
                    ? const SizedBox(height: 24)
                    : const SizedBox.shrink();
              },
            ),
            
            // Assistant hotkey
            BlocBuilder<OnboardingBloc, OnboardingState>(
              buildWhen: (previous, current) => 
                previous.assistantEnabled != current.assistantEnabled ||
                previous.assistantHotkey != current.assistantHotkey,
              builder: (context, state) {
                if (!state.assistantEnabled) {
                  return const SizedBox.shrink();
                }
                
                return _buildHotkeyCard(
                  context,
                  icon: Icons.chat_bubble_outline,
                  title: 'Assistant Hotkey',
                  description: 'Press this combination to open the AI assistant',
                  hotkey: state.assistantHotkey,
                  onRecordHotkey: (hotkey) {
                    context.read<OnboardingBloc>().add(
                      UpdateAssistantHotkey(hotkey: hotkey),
                    );
                  },
                  onTestHotkey: () {
                    // Show a snackbar to simulate assistant
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Assistant opened! (Test)'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Tip section
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
                        Icons.lightbulb_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hotkey Tips',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Choose hotkeys that are easy to remember',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Avoid conflicts with system shortcuts',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• You can change these later in Settings',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotkeyCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required HotKey? hotkey,
    required Function(HotKey) onRecordHotkey,
    required VoidCallback onTestHotkey,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
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
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Current hotkey display
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      hotkey != null
                          ? _formatHotkey(hotkey)
                          : 'None configured',
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.keyboard),
                  label: const Text('Record Hotkey'),
                  onPressed: () async {
                    final result = await _showHotkeyRecorderDialog(context);
                    if (result != null) {
                      onRecordHotkey(result);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: hotkey != null ? onTestHotkey : null,
                icon: const Icon(Icons.play_arrow),
                tooltip: 'Test Hotkey',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<HotKey?> _showHotkeyRecorderDialog(BuildContext context) async {
    HotKey? result;
    
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return RecordHotKeyDialog(
          onHotKeyRecorded: (hotkey) {
            result = hotkey;
          },
        );
      },
    );
    
    return result;
  }
  
  // Removed unused method

  String _formatHotkey(HotKey hotkey) {
    // Create a simple text representation of the hotkey
    String keyText = '';
    if (hotkey.modifiers?.contains(HotKeyModifier.alt) ?? false) {
      keyText += 'Alt+';
    }
    if (hotkey.modifiers?.contains(HotKeyModifier.control) ?? false) {
      keyText += 'Ctrl+';
    }
    if (hotkey.modifiers?.contains(HotKeyModifier.shift) ?? false) {
      keyText += 'Shift+';
    }
    if (hotkey.modifiers?.contains(HotKeyModifier.meta) ?? false) {
      keyText += 'Cmd+';
    }
    
    keyText += hotkey.key.keyLabel;
    
    return keyText;
  }
}

// Using RecordHotKeyDialog from the app settings
