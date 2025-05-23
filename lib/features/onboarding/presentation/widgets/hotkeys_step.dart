import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:autoquill_ai/widgets/hotkey_display.dart';

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
                color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
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
                
                final hotkeyCard = _buildHotkeyCard(
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
                
                // Add screenshot toggle if assistant is enabled
                if (state.assistantEnabled) {
                  final screenshotToggle = Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: BlocBuilder<OnboardingBloc, OnboardingState>(
                      buildWhen: (previous, current) => 
                        previous.assistantScreenshotEnabled != current.assistantScreenshotEnabled,
                      builder: (context, screenshotState) {
                        return SwitchListTile(
                          title: const Text('Auto-capture screenshot'),
                          subtitle: const Text(
                            'Automatically take a screenshot when assistant is activated to provide visual context',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: screenshotState.assistantScreenshotEnabled,
                          onChanged: (value) {
                            context.read<OnboardingBloc>().add(
                              UpdateAssistantScreenshotPreference(enabled: value),
                            );
                          },
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        );
                      },
                    ),
                  );
                  
                  return Column(
                    children: [
                      hotkeyCard,
                      const SizedBox(height: 16),
                      screenshotToggle,
                    ],
                  );
                }
                
                return hotkeyCard;
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 220,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: hotkey != null 
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                        : Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  child: HotkeyDisplay.forPlatform(
                    hotkey: hotkey,
                    textColor: Theme.of(context).colorScheme.onSurface,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    borderColor: hotkey != null 
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                        : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 180,
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
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: hotkey != null ? onTestHotkey : null,
                icon: const Icon(Icons.play_arrow),
                tooltip: 'Test Hotkey',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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

  // Removed _formatHotkey method as it's now handled by the HotkeyDisplay widget
}

// Using RecordHotKeyDialog from the app settings
