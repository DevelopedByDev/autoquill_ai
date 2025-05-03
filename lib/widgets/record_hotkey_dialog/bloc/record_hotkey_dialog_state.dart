import 'package:equatable/equatable.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class RecordHotkeyDialogState extends Equatable {
  final HotKey? recordedHotkey;
  final bool isRecording;

  const RecordHotkeyDialogState({
    this.recordedHotkey,
    this.isRecording = true,
  });

  RecordHotkeyDialogState copyWith({
    HotKey? recordedHotkey,
    bool? isRecording,
  }) {
    return RecordHotkeyDialogState(
      recordedHotkey: recordedHotkey ?? this.recordedHotkey,
      isRecording: isRecording ?? this.isRecording,
    );
  }

  @override
  List<Object?> get props => [recordedHotkey, isRecording];
}
