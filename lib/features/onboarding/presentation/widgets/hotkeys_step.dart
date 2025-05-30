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
              'Configure hotkeys to quickly access AutoQuill features',
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

            // Push-to-talk hotkey (moved to first position)
            BlocBuilder<OnboardingBloc, OnboardingState>(
              buildWhen: (previous, current) =>
                  previous.pushToTalkHotkey != current.pushToTalkHotkey,
              builder: (context, state) {
                return _buildHotkeyCard(
                  context,
                  icon: Icons.push_pin,
                  title: 'Push-to-Talk Hotkey',
                  description:
                      'Hold this combination to record while pressed (default: Option+Space on Mac, Alt+Space on Windows)',
                  hotkey: state.pushToTalkHotkey,
                  onRecordHotkey: (hotkey) {
                    context.read<OnboardingBloc>().add(
                          UpdatePushToTalkHotkey(hotkey: hotkey),
                        );
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            // Transcription hotkey
            BlocBuilder<OnboardingBloc, OnboardingState>(
              buildWhen: (previous, current) =>
                  previous.transcriptionEnabled !=
                      current.transcriptionEnabled ||
                  previous.transcriptionHotkey != current.transcriptionHotkey ||
                  previous.smartTranscriptionEnabled !=
                      current.smartTranscriptionEnabled,
              builder: (context, state) {
                if (!state.transcriptionEnabled) {
                  return const SizedBox.shrink();
                }

                final hotkeyCard = _buildHotkeyCard(
                  context,
                  icon: Icons.mic,
                  title: 'Transcription Hotkey',
                  description:
                      'Press this combination to start transcribing audio',
                  hotkey: state.transcriptionHotkey,
                  onRecordHotkey: (hotkey) {
                    context.read<OnboardingBloc>().add(
                          UpdateTranscriptionHotkey(hotkey: hotkey),
                        );
                  },
                );

                // Add smart transcription toggle if transcription is enabled
                if (state.transcriptionEnabled) {
                  final smartTranscriptionToggle = Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: BlocBuilder<OnboardingBloc, OnboardingState>(
                      buildWhen: (previous, current) =>
                          previous.smartTranscriptionEnabled !=
                          current.smartTranscriptionEnabled,
                      builder: (context, smartTranscriptionState) {
                        return SwitchListTile(
                          title: const Text('Smart Transcription'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Enhance transcriptions with intelligent formatting, emoji conversion, and proper casing. Slower but more polished results.',
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Examples:',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      '• "heart emoji" → ❤️',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    const Text(
                                      '• "in all caps excited" → "EXCITED"',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    const Text(
                                      '• "number 1 apples, number 2 bananas" → numbered list',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    const Text(
                                      '• "john dot doe at email dot com" → john.doe@email.com',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'You can change this in Settings later.',
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                          value:
                              smartTranscriptionState.smartTranscriptionEnabled,
                          onChanged: (value) {
                            context.read<OnboardingBloc>().add(
                                  UpdateSmartTranscriptionPreference(
                                      enabled: value),
                                );
                          },
                          dense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 8),
                        );
                      },
                    ),
                  );

                  return Column(
                    children: [
                      hotkeyCard,
                      const SizedBox(height: 16),
                      smartTranscriptionToggle,
                    ],
                  );
                }

                return hotkeyCard;
              },
            ),

            // Add spacing if both hotkeys are shown
            BlocBuilder<OnboardingBloc, OnboardingState>(
              buildWhen: (previous, current) =>
                  previous.transcriptionEnabled !=
                      current.transcriptionEnabled ||
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
                  description:
                      'Press this combination to open the AI assistant',
                  hotkey: state.assistantHotkey,
                  onRecordHotkey: (hotkey) {
                    context.read<OnboardingBloc>().add(
                          UpdateAssistantHotkey(hotkey: hotkey),
                        );
                  },
                );

                // Add screenshot toggle if assistant is enabled
                if (state.assistantEnabled) {
                  final screenshotToggle = Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: BlocBuilder<OnboardingBloc, OnboardingState>(
                      buildWhen: (previous, current) =>
                          previous.assistantScreenshotEnabled !=
                          current.assistantScreenshotEnabled,
                      builder: (context, screenshotState) {
                        return SwitchListTile(
                          title: const Text('Auto-capture screenshot'),
                          subtitle: const Text(
                            'Automatically take a screenshot when assistant is activated to provide visual context, slower but more powerful. You can change this in Settings later.',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: screenshotState.assistantScreenshotEnabled,
                          onChanged: (value) {
                            context.read<OnboardingBloc>().add(
                                  UpdateAssistantScreenshotPreference(
                                      enabled: value),
                                );
                          },
                          dense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 8),
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
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
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
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
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
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color
                                ?.withValues(alpha: 0.7),
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
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 200,
                    maxWidth: 350, // Allow more space for longer hotkeys
                  ),
                  child: HotkeyDisplay.forPlatform(
                    hotkey: hotkey,
                    textColor: Theme.of(context).colorScheme.onSurface,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    borderColor: hotkey != null
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.5)
                        : Colors.grey,
                    showIcon: false, // Remove icon to save space
                    fontSize: 13, // Slightly smaller font for longer text
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
                  // icon: const Icon(
                  //   Icons.keyboard,
                  //   color: Colors.white,
                  // ),
                  label: const Text('Change Hotkey'),
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
          currentMode:
              null, // In onboarding, we don't exclude any existing hotkeys
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
