import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/core/constants/language_codes.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_event.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';
import 'package:autoquill_ai/features/settings/presentation/widgets/dictionary_section.dart';

class OutputSettingsPage extends StatelessWidget {
  const OutputSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state.error?.isNotEmpty ?? false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Selection Section
              const Text(
                'Language',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<LanguageCode>(
                value: state.selectedLanguage,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: languageCodes.map((language) => DropdownMenuItem(
                  value: language,
                  child: Text(language.name),
                )).toList(),
                onChanged: (language) {
                  if (language != null) {
                    context.read<SettingsBloc>().add(SaveLanguage(language));
                  }
                },
              ),
              const SizedBox(height: 24),
              // Dictionary Section
              DictionarySection(),
            ],
          ),
        );
      },
    );
  }
}
