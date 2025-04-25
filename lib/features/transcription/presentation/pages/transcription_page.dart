import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../recording/presentation/bloc/recording_bloc.dart';
import '../../domain/repositories/transcription_repository.dart';

class TranscriptionPage extends StatefulWidget {
  const TranscriptionPage({super.key});

  @override
  State<TranscriptionPage> createState() => _TranscriptionPageState();
}

class _TranscriptionPageState extends State<TranscriptionPage> {
  final TextEditingController groqAPIKeyController = TextEditingController();
  String? transcriptionText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Transcription'),
      ),
      body: BlocConsumer<RecordingBloc, RecordingState>(
        listener: (context, state) {
          if (state is RecordingComplete) {
            _handleTranscription(state.recordedFilePath!);
          }
        },
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: groqAPIKeyController,
                    decoration: const InputDecoration(
                      labelText: 'Groq API Key',
                      hintText: 'Something like gsk_0DLKkuapGSFY8...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (!state.isRecording) ...[  // Show record button when not recording
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
                          if (state.isPaused) {
                            context.read<RecordingBloc>().add(ResumeRecording());
                          } else {
                            context.read<RecordingBloc>().add(PauseRecording());
                          }
                        },
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        child: Icon(
                          state.isPaused ? Icons.play_arrow : Icons.pause,
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
                        },
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
                if (transcriptionText != null) ...[  
                  const SizedBox(height: 20),
                  const Text('Transcription:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(transcriptionText!),
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleTranscription(String audioPath) async {
    if (groqAPIKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Groq API key')),
      );
      return;
    }

    try {
      final repository = context.read<TranscriptionRepository>();
      final response = await repository.transcribeAudio(audioPath, groqAPIKeyController.text);
      setState(() {
        transcriptionText = response.text;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transcription failed: $e')),
      );
    }
  }
}
