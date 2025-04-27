import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/app_storage.dart';
import '../../../recording/presentation/bloc/recording_bloc.dart';
import '../bloc/transcription_bloc.dart';
import '../../../../settings.dart';

class TranscriptionPage extends StatelessWidget {
  const TranscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TranscriptionBloc(
        repository: context.read(),
      )..add(InitializeTranscription()),
      child: BlocConsumer<TranscriptionBloc, TranscriptionState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, transcriptionState) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Audio Transcription'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Settings',
                  onPressed: () {
                    AppStorage.getApiKey().then((apiKey) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SettingsPage(
                            groqAPIKeyController: TextEditingController(text: apiKey ?? ''),
                          ),
                        ),
                      ).then((_) {
                        // Refresh API key after settings page is closed
                        context.read<TranscriptionBloc>().add(
                              InitializeTranscription(),
                            );
                      });
                    });
                  },
                ),
              ],
            ),
            body: BlocConsumer<RecordingBloc, RecordingState>(
              listener: (context, state) {
                if (state is RecordingComplete && state.recordedFilePath != null) {
                  context.read<TranscriptionBloc>().add(
                    StartTranscription(state.recordedFilePath!),
                  );
                }
              },
              builder: (context, recordingState) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!recordingState.isRecording) ...[  // Show record button when not recording
                        FloatingActionButton(
                          onPressed: () {
                            context.read<RecordingBloc>().add(StartRecording());
                          },
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          child: const Icon(Icons.mic),
                        ),
                      ] else ...[  // Show recording controls when recording
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FloatingActionButton(
                              onPressed: () {
                                if (recordingState.isPaused) {
                                  context.read<RecordingBloc>().add(ResumeRecording());
                                } else {
                                  context.read<RecordingBloc>().add(PauseRecording());
                                }
                              },
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              child: Icon(
                                recordingState.isPaused ? Icons.play_arrow : Icons.pause,
                              ),
                            ),
                            const SizedBox(width: 16),
                            FloatingActionButton(
                              onPressed: () {
                                context.read<RecordingBloc>().add(StopRecording());
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              child: const Icon(Icons.stop),
                            ),
                            const SizedBox(width: 16),
                            FloatingActionButton(
                              onPressed: () {
                                context.read<RecordingBloc>().add(StopRecording());
                                context.read<RecordingBloc>().add(StartRecording());
                              },
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              child: const Icon(Icons.refresh),
                            ),
                            const SizedBox(width: 16),
                            FloatingActionButton(
                              onPressed: () {
                                context.read<RecordingBloc>().add(CancelRecording());
                                context.read<TranscriptionBloc>().add(ClearTranscription());
                              },
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                              child: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ],
                      if (transcriptionState.isLoading) ...[  
                        const SizedBox(height: 20),
                        const CircularProgressIndicator(),
                      ] else if (transcriptionState.transcriptionText != null) ...[  
                        const SizedBox(height: 20),
                        const Text('Transcription:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(transcriptionState.transcriptionText!),
                        ),
                      ]
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
