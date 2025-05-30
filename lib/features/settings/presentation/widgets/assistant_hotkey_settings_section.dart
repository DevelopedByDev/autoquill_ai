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

class AssistantHotkeySettingsSection extends StatelessWidget {
  const AssistantHotkeySettingsSection({super.key});

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
            'Configure keyboard shortcuts for assistant features.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: DesignTokens.spaceMD),
          _buildHotkeyRow(context, 'Assistant mode', 'assistant_hotkey', state),
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
}
