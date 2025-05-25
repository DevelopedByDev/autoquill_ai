import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_state.dart';
import '../../../../widgets/hotkey_display.dart';
import '../../../hotkeys/services/test_page_manager.dart';

class TestHotkeysStep extends StatefulWidget {
  const TestHotkeysStep({super.key});

  @override
  State<TestHotkeysStep> createState() => _TestHotkeysStepState();
}

class _TestHotkeysStepState extends State<TestHotkeysStep> {
  final TextEditingController _transcriptionController =
      TextEditingController();
  final TextEditingController _assistantController = TextEditingController();
  final TextEditingController _pushToTalkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Controllers start empty - users will see hint text instead

    // Register this test page to receive transcription results directly
    TestPageManager.registerTestPage(
      onPushToTalkResult: _handlePushToTalkResult,
      onTranscriptionResult: _handleTranscriptionResult,
      onAssistantResult: _handleAssistantResult,
    );
  }

  @override
  void dispose() {
    // Unregister the test page
    TestPageManager.unregisterTestPage();

    _transcriptionController.dispose();
    _assistantController.dispose();
    _pushToTalkController.dispose();
    super.dispose();
  }

  void _handlePushToTalkResult(String text) {
    if (mounted) {
      setState(() {
        _pushToTalkController.text = text;
      });
    }
  }

  void _handleTranscriptionResult(String text) {
    if (mounted) {
      setState(() {
        _transcriptionController.text = text;
      });
    }
  }

  void _handleAssistantResult(String text) {
    if (mounted) {
      setState(() {
        _assistantController.text = text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Step title
                Text(
                  'Test Your Hotkeys',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Try your hotkeys in the text fields below to make sure they work correctly',
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

                // Push-to-talk test field
                if (state.pushToTalkHotkey != null)
                  _buildTestField(
                    context,
                    title: 'Push-to-Talk Mode',
                    description: 'Hold your push-to-talk hotkey while typing',
                    hotkey: state.pushToTalkHotkey!,
                    controller: _pushToTalkController,
                    icon: Icons.push_pin,
                    hintText: state.smartTranscriptionEnabled
                        ? 'Hold your push-to-talk key and say: "heart emoji excited in all caps" (Smart Transcription enabled)'
                        : 'Hold your push-to-talk key and say: "Hello, this is a test"',
                    smartTranscriptionEnabled: state.smartTranscriptionEnabled,
                  ),

                if (state.pushToTalkHotkey != null) const SizedBox(height: 24),

                // Transcription test field
                if (state.transcriptionEnabled &&
                    state.transcriptionHotkey != null)
                  _buildTestField(
                    context,
                    title: 'Transcription Mode',
                    description: 'Press your transcription hotkey to activate',
                    hotkey: state.transcriptionHotkey!,
                    controller: _transcriptionController,
                    icon: Icons.mic,
                    hintText: state.smartTranscriptionEnabled
                        ? 'Press your transcription key and say: "heart emoji excited in all caps" (Smart Transcription enabled)'
                        : 'Press your transcription key and say: "The quick brown fox jumps over the lazy dog"',
                    smartTranscriptionEnabled: state.smartTranscriptionEnabled,
                  ),

                if (state.transcriptionEnabled &&
                    state.transcriptionHotkey != null)
                  const SizedBox(height: 24),

                // Assistant test field
                if (state.assistantEnabled && state.assistantHotkey != null)
                  _buildTestField(
                    context,
                    title: 'Assistant Mode',
                    description: 'Press your assistant hotkey to activate',
                    hotkey: state.assistantHotkey!,
                    controller: _assistantController,
                    icon: Icons.chat_bubble_outline,
                    hintText:
                        'Press your assistant key and ask: "Write me a tweet about the benefits of vitamin supplementation"',
                  ),

                const SizedBox(height: 32),

                // Info section
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
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Testing Tips',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Click in a text field and try your hotkeys',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Hotkeys should work from any application when AutoQuill is running',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• You can change these hotkeys later in Settings',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTestField(
    BuildContext context, {
    required String title,
    required String description,
    required hotkey,
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool smartTranscriptionEnabled = false,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if (smartTranscriptionEnabled &&
                            (title.contains('Transcription') ||
                                title.contains('Push-to-Talk'))) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'SMART',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
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

          const SizedBox(height: 12),

          // Hotkey display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: HotkeyDisplay(
                  hotkey: hotkey,
                  textColor: Theme.of(context).colorScheme.onSurface,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  borderColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Test text field
          TextField(
            controller: controller,
            maxLines: 2,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
              hintText: hintText,
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
