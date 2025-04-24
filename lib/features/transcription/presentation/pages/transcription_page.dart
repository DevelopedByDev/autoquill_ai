import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../recording/presentation/bloc/recording_bloc.dart';

class TranscriptionPage extends StatelessWidget {
  TranscriptionPage({super.key});
  final TextEditingController groqAPIKeyController  = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Transcription'),
      ),
      body: BlocBuilder<RecordingBloc, RecordingState>(
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Groq API Key',
                      hintText: 'Something like gsk_0DLKkuapGSFY8...',
                    ),
                    controller: groqAPIKeyController,
                  ),
                ),
                if (!state.isRecording) ...[  // Show record button when not recording
                  FloatingActionButton(
                    onPressed: () {
                      context.read<RecordingBloc>().add(StartRecording());
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.mic),
                  ),
                ] else ...[  // Show control buttons when recording
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
                        child: Icon(state.isPaused ? Icons.play_arrow : Icons.pause),
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
              ],
            ),
          );
        },
      ),
    );
  }
}
