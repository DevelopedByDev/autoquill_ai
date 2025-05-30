import 'package:equatable/equatable.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class RecordHotkeyDialogState extends Equatable {
  final HotKey? recordedHotkey;
  final bool isRecording;
  final String? errorMessage;

  const RecordHotkeyDialogState({
    this.recordedHotkey,
    this.isRecording = true,
    this.errorMessage,
  });

  RecordHotkeyDialogState copyWith({
    HotKey? recordedHotkey,
    bool? isRecording,
    String? errorMessage,
  }) {
    return RecordHotkeyDialogState(
      recordedHotkey: recordedHotkey ?? this.recordedHotkey,
      isRecording: isRecording ?? this.isRecording,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [recordedHotkey, isRecording, errorMessage];
}
