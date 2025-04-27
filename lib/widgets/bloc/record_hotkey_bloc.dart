import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

// Events
abstract class RecordHotkeyEvent extends Equatable {
  const RecordHotkeyEvent();

  @override
  List<Object?> get props => [];
}

class StartRecording extends RecordHotkeyEvent {}

class StopRecording extends RecordHotkeyEvent {}

class UpdateHotkey extends RecordHotkeyEvent {
  final HotKey hotKey;
  const UpdateHotkey(this.hotKey);

  @override
  List<Object?> get props => [hotKey];
}

// States
class RecordHotkeyState extends Equatable {
  final HotKey? hotKey;
  final bool isRecording;

  const RecordHotkeyState({
    this.hotKey,
    this.isRecording = false,
  });

  RecordHotkeyState copyWith({
    HotKey? hotKey,
    bool? isRecording,
  }) {
    return RecordHotkeyState(
      hotKey: hotKey ?? this.hotKey,
      isRecording: isRecording ?? this.isRecording,
    );
  }

  @override
  List<Object?> get props => [hotKey, isRecording];
}

class RecordHotkeyBloc extends Bloc<RecordHotkeyEvent, RecordHotkeyState> {
  RecordHotkeyBloc() : super(const RecordHotkeyState()) {
    on<StartRecording>(_onStartRecording);
    on<StopRecording>(_onStopRecording);
    on<UpdateHotkey>(_onUpdateHotkey);
  }

  void _onStartRecording(StartRecording event, Emitter<RecordHotkeyState> emit) {
    emit(state.copyWith(isRecording: true));
  }

  void _onStopRecording(StopRecording event, Emitter<RecordHotkeyState> emit) {
    emit(state.copyWith(isRecording: false));
  }

  void _onUpdateHotkey(UpdateHotkey event, Emitter<RecordHotkeyState> emit) {
    emit(state.copyWith(hotKey: event.hotKey));
  }
}
