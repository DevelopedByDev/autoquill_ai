import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/transcription_repository.dart';

// Events
abstract class TranscriptionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// States
abstract class TranscriptionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TranscriptionInitial extends TranscriptionState {}

class TranscriptionBloc extends Bloc<TranscriptionEvent, TranscriptionState> {
  final TranscriptionRepository repository;

  TranscriptionBloc({required this.repository}) : super(TranscriptionInitial());
}
