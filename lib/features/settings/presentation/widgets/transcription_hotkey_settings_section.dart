import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/core/theme/design_tokens.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_event.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';
import 'package:autoquill_ai/widgets/hotkey_converter.dart';
import 'package:autoquill_ai/widgets/hotkey_display.dart';
import 'package:autoquill_ai/widgets/minimalist_card.dart';
import 'package:autoquill_ai/widgets/minimalist_button.dart';
import 'package:autoquill_ai/widgets/record_hotkey_dialog.dart';

class TranscriptionHotkeySettingsSection extends StatelessWidget {
  const TranscriptionHotkeySettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hotkey Settings',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: DesignTokens.spaceSM),
          Text(
            'Configure keyboard shortcuts for transcription features.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: DesignTokens.spaceMD),
          _buildHotkeyRow(
              context, 'Transcription mode', 'transcription_hotkey', state),
          const SizedBox(height: DesignTokens.spaceMD),
          _buildPushToTalkSection(context, state),
        ],
      );
    });
  }

  Widget _buildHotkeyRow(BuildContext context, String label, String hotkeyKey,
      SettingsState state) {
    return MinimalistCard(
      padding: const EdgeInsets.all(DesignTokens.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: DesignTokens.fontWeightMedium,
                ),
          ),
          const SizedBox(height: DesignTokens.spaceSM),
          Row(
            children: [
              Expanded(
                child: _buildHotkeyDisplay(context, hotkeyKey, state),
              ),
              const SizedBox(width: DesignTokens.spaceSM),
              MinimalistButton(
                variant: MinimalistButtonVariant.icon,
                icon: Icons.edit,
                onPressed: () {
                  _showRecordHotkeyDialog(context, hotkeyKey);
                },
              ),
              const SizedBox(width: DesignTokens.spaceXS),
              MinimalistButton(
                variant: MinimalistButtonVariant.icon,
                icon: Icons.delete_outline,
                onPressed: () {
                  context.read<SettingsBloc>().add(DeleteHotkey(hotkeyKey));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHotkeyDisplay(
      BuildContext context, String hotkeyKey, SettingsState state) {
    final hotkeyData = state.storedHotkeys[hotkeyKey];
    final hotKey = hotkeyData != null ? hotKeyConverter(hotkeyData) : null;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return HotkeyDisplay.forPlatform(
      hotkey: hotKey,
      showIcon: false,
      fontSize: DesignTokens.bodyMedium,
      padding: const EdgeInsets.symmetric(
        vertical: DesignTokens.spaceSM,
        horizontal: DesignTokens.spaceMD,
      ),
      backgroundColor:
          isDarkMode ? DesignTokens.darkSurface : DesignTokens.lightSurface,
      borderColor: hotKey != null
          ? DesignTokens.vibrantCoral.withValues(alpha: 0.5)
          : Colors.grey.withValues(alpha: 0.3),
    );
  }

  Future<void> _showRecordHotkeyDialog(
      BuildContext context, String mode) async {
    context.read<SettingsBloc>().add(StartHotkeyRecording(mode));

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return RecordHotKeyDialog(
          currentMode: mode,
          onHotKeyRecorded: (newHotKey) {
            context.read<SettingsBloc>().add(SaveHotkey(newHotKey));
          },
        );
      },
    );
  }

  Widget _buildPushToTalkSection(BuildContext context, SettingsState state) {
    return MinimalistCard(
      padding: const EdgeInsets.all(DesignTokens.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Push-to-Talk',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: DesignTokens.fontWeightMedium,
                    ),
              ),
              Switch(
                value: state.pushToTalkEnabled,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(TogglePushToTalk());
                },
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceXS),
          Text(
            'Hold down the hotkey to record, release to transcribe',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: DesignTokens.spaceMD),
          Opacity(
            opacity:
                state.pushToTalkEnabled ? 1.0 : DesignTokens.opacityDisabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Push-to-Talk Hotkey',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: DesignTokens.spaceSM),
                Row(
                  children: [
                    Expanded(
                      child: _buildHotkeyDisplay(
                          context, 'push_to_talk_hotkey', state),
                    ),
                    const SizedBox(width: DesignTokens.spaceSM),
                    MinimalistButton(
                      variant: MinimalistButtonVariant.icon,
                      icon: Icons.edit,
                      isDisabled: !state.pushToTalkEnabled,
                      onPressed: state.pushToTalkEnabled
                          ? () {
                              _showPushToTalkHotkeyDialog(context);
                            }
                          : null,
                    ),
                    const SizedBox(width: DesignTokens.spaceXS),
                    MinimalistButton(
                      variant: MinimalistButtonVariant.icon,
                      icon: Icons.delete_outline,
                      isDisabled: !state.pushToTalkEnabled,
                      onPressed: state.pushToTalkEnabled
                          ? () {
                              context
                                  .read<SettingsBloc>()
                                  .add(DeletePushToTalkHotkey());
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPushToTalkHotkeyDialog(BuildContext context) async {
    context.read<SettingsBloc>().add(StartPushToTalkHotkeyRecording());

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return RecordHotKeyDialog(
          currentMode: 'push_to_talk_hotkey',
          onHotKeyRecorded: (newHotKey) {
            context.read<SettingsBloc>().add(SavePushToTalkHotkey(newHotKey));
          },
        );
      },
    );
  }
}
