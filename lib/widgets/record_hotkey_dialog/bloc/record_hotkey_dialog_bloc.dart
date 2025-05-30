import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../features/hotkeys/core/hotkey_handler.dart';
import 'record_hotkey_dialog_event.dart';
import 'record_hotkey_dialog_state.dart';

class RecordHotkeyDialogBloc
    extends Bloc<RecordHotkeyDialogEvent, RecordHotkeyDialogState> {
  final String? currentMode;

  RecordHotkeyDialogBloc({this.currentMode})
      : super(const RecordHotkeyDialogState()) {
    on<RecordHotkey>(_onRecordHotkey);
    on<ConfirmHotkey>(_onConfirmHotkey);
    on<CancelRecording>(_onCancelRecording);

    // Suppress other hotkeys when dialog opens
    HotkeyHandler.setHotkeyRecordingDialogOpen(true);
  }

  @override
  Future<void> close() {
    // Re-enable other hotkeys when dialog closes
    HotkeyHandler.setHotkeyRecordingDialogOpen(false);
    return super.close();
  }

  void _onRecordHotkey(
      RecordHotkey event, Emitter<RecordHotkeyDialogState> emit) {
    // Validate the hotkey for conflicts
    final conflictResult =
        HotkeyHandler.validateHotkey(event.hotkey, currentMode);

    if (conflictResult.hasConflict) {
      final conflictingModeName =
          HotkeyHandler.getModeFriendlyName(conflictResult.conflictingMode!);
      emit(state.copyWith(
        recordedHotkey: event.hotkey,
        errorMessage:
            'This hotkey is already assigned to $conflictingModeName. Please choose a different combination.',
      ));

      if (kDebugMode) {
        print(
            'Hotkey conflict detected: ${event.hotkey.debugName} is already used by ${conflictResult.conflictingMode}');
      }
    } else {
      emit(state.copyWith(
        recordedHotkey: event.hotkey,
        errorMessage: null, // Clear any previous error
      ));

      if (kDebugMode) {
        print('Hotkey recorded without conflict: ${event.hotkey.debugName}');
      }
    }
  }

  void _onConfirmHotkey(
      ConfirmHotkey event, Emitter<RecordHotkeyDialogState> emit) {
    // Only confirm if there are no conflicts
    if (state.errorMessage == null) {
      emit(state.copyWith(
        isRecording: false,
      ));
    }
  }

  void _onCancelRecording(
      CancelRecording event, Emitter<RecordHotkeyDialogState> emit) {
    emit(state.copyWith(
      isRecording: false,
      recordedHotkey: null,
      errorMessage: null,
    ));
  }
}
