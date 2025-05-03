import 'package:flutter_bloc/flutter_bloc.dart';
import 'record_hotkey_dialog_event.dart';
import 'record_hotkey_dialog_state.dart';

class RecordHotkeyDialogBloc extends Bloc<RecordHotkeyDialogEvent, RecordHotkeyDialogState> {
  RecordHotkeyDialogBloc() : super(const RecordHotkeyDialogState()) {
    on<RecordHotkey>(_onRecordHotkey);
    on<ConfirmHotkey>(_onConfirmHotkey);
    on<CancelRecording>(_onCancelRecording);
  }

  void _onRecordHotkey(RecordHotkey event, Emitter<RecordHotkeyDialogState> emit) {
    emit(state.copyWith(
      recordedHotkey: event.hotkey,
    ));
  }

  void _onConfirmHotkey(ConfirmHotkey event, Emitter<RecordHotkeyDialogState> emit) {
    emit(state.copyWith(
      isRecording: false,
    ));
  }

  void _onCancelRecording(CancelRecording event, Emitter<RecordHotkeyDialogState> emit) {
    emit(state.copyWith(
      isRecording: false,
      recordedHotkey: null,
    ));
  }
}
