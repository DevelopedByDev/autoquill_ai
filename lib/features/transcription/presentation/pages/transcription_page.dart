import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../recording/presentation/bloc/recording_bloc.dart';
import '../bloc/transcription_bloc.dart';
import '../../../settings/presentation/pages/settings.dart';
import '../../../../widgets/hotkey_handler.dart';

class TranscriptionPage extends StatefulWidget {
  const TranscriptionPage({super.key});

  @override
  State<TranscriptionPage> createState() => _TranscriptionPageState();
}

class _TranscriptionPageState extends State<TranscriptionPage> {
  @override
  void initState() {
    super.initState();
    // Initialize the blocs in the HotkeyHandler after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recordingBloc = context.read<RecordingBloc>();
      final transcriptionBloc = context.read<TranscriptionBloc>();
      HotkeyHandler.setBlocs(recordingBloc, transcriptionBloc);
      if (kDebugMode) {
        print('HotkeyHandler initialized with blocs');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // We don't need to create a new TranscriptionBloc here, as it's already provided in main.dart
    return BlocConsumer<TranscriptionBloc, TranscriptionState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
          
          // Show notification when transcription is completed and copied to clipboard
          if (!state.isLoading && state.transcriptionText != null) {
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
            appBar: AppBar(
              title: const Text('Audio Transcription'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Settings',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SettingsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
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
                                  valueListenable:
                                      Hive.box('settings').listenable(),
                                  builder: (context, box, _) {
                                    final apiKey = box.get('groq_api_key');
                                    if (apiKey == null || apiKey.isEmpty) {
                                      return FloatingActionButton(onPressed: null, tooltip: 'Enter API Key in settings page', backgroundColor: Colors.grey, foregroundColor: Colors.grey.shade300, child: const Icon(Icons.mic),);
                                    }
                                    return FloatingActionButton(onPressed: () {
                                      context.read<RecordingBloc>().add(StartRecording());
                                    }, tooltip: 'Start Recording', backgroundColor: Colors.blue, foregroundColor: Colors.white, child: const Icon(Icons.mic),);
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
                                    .add(StopRecording());
                                context
                                    .read<RecordingBloc>()
                                    .add(StartRecording());
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
                                  valueListenable:
                                      Hive.box('settings').listenable(),
                                  builder: (context, box, _) {
                                    final apiKey = box.get('groq_api_key');
                                    if (apiKey != null) {
                                      return Text(transcriptionState.transcriptionText!);
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
