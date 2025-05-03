import 'package:equatable/equatable.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

abstract class RecordHotkeyDialogEvent extends Equatable {
  const RecordHotkeyDialogEvent();

  @override
  List<Object?> get props => [];
}

class RecordHotkey extends RecordHotkeyDialogEvent {
  final HotKey hotkey;
  
  const RecordHotkey(this.hotkey);
  
  @override
  List<Object?> get props => [hotkey];
}

class ConfirmHotkey extends RecordHotkeyDialogEvent {}

class CancelRecording extends RecordHotkeyDialogEvent {}
