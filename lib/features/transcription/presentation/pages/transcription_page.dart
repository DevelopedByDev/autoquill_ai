import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../recording/presentation/bloc/recording_bloc.dart';
import '../bloc/transcription_bloc.dart';

class TranscriptionPage extends StatefulWidget {
  const TranscriptionPage({super.key});

  @override
  State<TranscriptionPage> createState() => _TranscriptionPageState();
}

class _TranscriptionPageState extends State<TranscriptionPage> {

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TranscriptionBloc, TranscriptionState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }

        // Show notification when transcription is completed and copied to clipboard
        // But only for transcriptions initiated from the UI, not from hotkeys
        // We can detect this by checking if the previous state had isLoading=true
        if (!state.isLoading &&
            state.transcriptionText != null &&
            state.previouslyLoading == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transcription copied to clipboard'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, transcriptionState) {
        return Scaffold(
          body: BlocConsumer<RecordingBloc, RecordingState>(
            listener: (context, state) {
              if (state is RecordingComplete &&
                  state.recordedFilePath != null) {
                context.read<TranscriptionBloc>().add(
                      StartTranscription(state.recordedFilePath!),
                    );
                // Show toast notification when transcription starts
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transcribing audio...')),
                );
              }
            },
            builder: (context, recordingState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!recordingState.isRecording) ...[
                      // Show record button when not recording
                      BlocBuilder<TranscriptionBloc, TranscriptionState>(
                        builder: (context, state) {
                          return ValueListenableBuilder(
                            valueListenable: Hive.box('settings').listenable(),
                            builder: (context, box, _) {
                              final apiKey = box.get('groq_api_key');
                              if (apiKey == null || apiKey.isEmpty) {
                                return FloatingActionButton(
                                  onPressed: null,
                                  tooltip: 'Enter API Key in settings page',
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.grey.shade300,
                                  child: const Icon(Icons.mic),
                                );
                              }
                              return FloatingActionButton(
                                onPressed: () {
                                  context
                                      .read<RecordingBloc>()
                                      .add(StartRecording());
                                },
                                tooltip: 'Start Recording',
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                child: const Icon(Icons.mic),
                              );
                            },
                          );
                        },
                      ),
                    ] else ...[
                      // Show recording controls when recording
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FloatingActionButton(
                            onPressed: () {
                              if (recordingState.isPaused) {
                                context
                                    .read<RecordingBloc>()
                                    .add(ResumeRecording());
                              } else {
                                context
                                    .read<RecordingBloc>()
                                    .add(PauseRecording());
                              }
                            },
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            child: Icon(
                              recordingState.isPaused
                                  ? Icons.play_arrow
                                  : Icons.pause,
                            ),
                          ),
                          const SizedBox(width: 16),
                          FloatingActionButton(
                            onPressed: () {
                              context
                                  .read<RecordingBloc>()
                                  .add(StopRecording());
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            child: const Icon(Icons.stop),
                          ),
                          const SizedBox(width: 16),
                          FloatingActionButton(
                            onPressed: () {
                              context
                                  .read<RecordingBloc>()
                                  .add(RestartRecording());
                            },
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            child: const Icon(Icons.refresh),
                          ),
                          const SizedBox(width: 16),
                          FloatingActionButton(
                            onPressed: () {
                              context
                                  .read<RecordingBloc>()
                                  .add(CancelRecording());
                              context
                                  .read<TranscriptionBloc>()
                                  .add(ClearTranscription());
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
                    ] else if (transcriptionState.transcriptionText !=
                        null) ...[
                      const SizedBox(height: 20),
                      const Text('Transcription:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ValueListenableBuilder(
                          valueListenable: Hive.box('settings').listenable(),
                          builder: (context, box, _) {
                            final apiKey = box.get('groq_api_key');
                            if (apiKey != null) {
                              return Text(
                                  transcriptionState.transcriptionText!);
                            }
                            return Text('Enter API Key in settings page');
                          },
                        ),
                      ),
                    ]
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
