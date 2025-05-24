import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_event.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';

class DictionarySection extends StatelessWidget {
  DictionarySection({super.key});

  final TextEditingController _wordController = TextEditingController();
  final FocusNode _wordFocusNode = FocusNode();
  final TextEditingController _fromPhraseController = TextEditingController();
  final TextEditingController _toPhraseController = TextEditingController();
  final FocusNode _fromPhraseFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dictionary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add words that are harder for models to spell correctly.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _wordController,
                      focusNode: _wordFocusNode,
                      decoration: const InputDecoration(
                        hintText: 'Enter a word',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          context
                              .read<SettingsBloc>()
                              .add(AddWordToDictionary(value));
                          _wordController.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_wordController.text.isNotEmpty) {
                        context
                            .read<SettingsBloc>()
                            .add(AddWordToDictionary(_wordController.text));
                        _wordController.clear();
                        _wordFocusNode.requestFocus();
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: state.dictionary.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text('No words added yet',
                              style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.dictionary.length,
                        itemBuilder: (context, index) {
                          final word = state.dictionary[index];
                          return ListTile(
                            dense: true,
                            title: Text(word),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () {
                                context
                                    .read<SettingsBloc>()
                                    .add(RemoveWordFromDictionary(word));
                              },
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 32),
              // Phrase Replacement Section
              const Text(
                'Phrase Replacements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Replace phrases in transcriptions with custom text (e.g., "link to calendar" → "https://calendar.google.com").',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _fromPhraseController,
                      focusNode: _fromPhraseFocusNode,
                      decoration: const InputDecoration(
                        hintText: 'From phrase',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _toPhraseController,
                      decoration: const InputDecoration(
                        hintText: 'To phrase',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (value) {
                        if (_fromPhraseController.text.isNotEmpty &&
                            value.isNotEmpty) {
                          context.read<SettingsBloc>().add(AddPhraseReplacement(
                              _fromPhraseController.text, value));
                          _fromPhraseController.clear();
                          _toPhraseController.clear();
                          _fromPhraseFocusNode.requestFocus();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_fromPhraseController.text.isNotEmpty &&
                          _toPhraseController.text.isNotEmpty) {
                        context.read<SettingsBloc>().add(AddPhraseReplacement(
                            _fromPhraseController.text,
                            _toPhraseController.text));
                        _fromPhraseController.clear();
                        _toPhraseController.clear();
                        _fromPhraseFocusNode.requestFocus();
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: state.phraseReplacements.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text('No phrase replacements added yet',
                              style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.phraseReplacements.length,
                        itemBuilder: (context, index) {
                          final entry =
                              state.phraseReplacements.entries.elementAt(index);
                          return ListTile(
                            dense: true,
                            title: Text('${entry.key} → ${entry.value}'),
                            subtitle: Text(
                                'Replace "${entry.key}" with "${entry.value}"',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () {
                                context
                                    .read<SettingsBloc>()
                                    .add(RemovePhraseReplacement(entry.key));
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
