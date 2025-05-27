import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/core/constants/language_codes.dart';
import 'package:autoquill_ai/core/theme/design_tokens.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_event.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';
import 'package:autoquill_ai/widgets/minimalist_card.dart';
import 'package:autoquill_ai/widgets/minimalist_input.dart';
import 'package:autoquill_ai/widgets/minimalist_button.dart';

class OutputSettingsPage extends StatelessWidget {
  OutputSettingsPage({super.key});

  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _fromPhraseController = TextEditingController();
  final TextEditingController _toPhraseController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state.error?.isNotEmpty ?? false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: DesignTokens.vibrantCoral,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.spaceLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLanguageSection(context, state, isDarkMode),
              const SizedBox(height: DesignTokens.spaceXXL),
              _buildDictionarySection(context, state, isDarkMode),
              const SizedBox(height: DesignTokens.spaceXXL),
              _buildPhraseReplacementSection(context, state, isDarkMode),
              const SizedBox(height: DesignTokens.spaceXXL),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageSection(
      BuildContext context, SettingsState state, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceXS),
              decoration: BoxDecoration(
                gradient: DesignTokens.blueGradient,
                borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
              ),
              child: Icon(
                Icons.language_rounded,
                color: DesignTokens.trueWhite,
                size: DesignTokens.iconSizeSM,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceSM),
            Text(
              'Language Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: DesignTokens.fontWeightSemiBold,
                    color: isDarkMode
                        ? DesignTokens.trueWhite
                        : DesignTokens.pureBlack,
                  ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spaceSM),
        Text(
          'Select the language for transcription output and text processing.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDarkMode
                    ? DesignTokens.trueWhite.withValues(alpha: 0.7)
                    : DesignTokens.pureBlack.withValues(alpha: 0.6),
              ),
        ),
        const SizedBox(height: DesignTokens.spaceMD),
        MinimalistCard(
          padding: const EdgeInsets.all(DesignTokens.spaceMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Output Language',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: DesignTokens.fontWeightMedium,
                      color: isDarkMode
                          ? DesignTokens.trueWhite
                          : DesignTokens.pureBlack,
                    ),
              ),
              const SizedBox(height: DesignTokens.spaceSM),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                  border: Border.all(
                    color: isDarkMode
                        ? DesignTokens.trueWhite.withValues(alpha: 0.2)
                        : DesignTokens.pureBlack.withValues(alpha: 0.1),
                  ),
                ),
                child: DropdownButtonFormField<LanguageCode>(
                  value: state.selectedLanguage,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(DesignTokens.spaceMD),
                    prefixIcon: Icon(
                      Icons.translate_rounded,
                      color: isDarkMode
                          ? DesignTokens.trueWhite.withValues(alpha: 0.6)
                          : DesignTokens.pureBlack.withValues(alpha: 0.5),
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? DesignTokens.trueWhite
                            : DesignTokens.pureBlack,
                      ),
                  dropdownColor: isDarkMode
                      ? DesignTokens.pureBlack
                      : DesignTokens.trueWhite,
                  items: languageCodes
                      .map((language) => DropdownMenuItem(
                            value: language,
                            child: Text(
                              language.name,
                              style: TextStyle(
                                color: isDarkMode
                                    ? DesignTokens.trueWhite
                                    : DesignTokens.pureBlack,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (language) {
                    if (language != null) {
                      context.read<SettingsBloc>().add(SaveLanguage(language));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDictionarySection(
      BuildContext context, SettingsState state, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceXS),
              decoration: BoxDecoration(
                gradient: DesignTokens.coralGradient,
                borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
              ),
              child: Icon(
                Icons.book_rounded,
                color: DesignTokens.trueWhite,
                size: DesignTokens.iconSizeSM,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceSM),
            Text(
              'Dictionary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: DesignTokens.fontWeightSemiBold,
                    color: isDarkMode
                        ? DesignTokens.trueWhite
                        : DesignTokens.pureBlack,
                  ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spaceSM),
        Text(
          'Add words that are harder for models to spell correctly.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDarkMode
                    ? DesignTokens.trueWhite.withValues(alpha: 0.7)
                    : DesignTokens.pureBlack.withValues(alpha: 0.6),
              ),
        ),
        const SizedBox(height: DesignTokens.spaceMD),
        MinimalistCard(
          padding: const EdgeInsets.all(DesignTokens.spaceMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: MinimalistInput(
                      controller: _wordController,
                      placeholder: 'Enter a word',
                      prefixIcon: Icons.edit_rounded,
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
                  const SizedBox(width: DesignTokens.spaceSM),
                  MinimalistButton(
                    label: 'Add',
                                         onPressed: () {
                       if (_wordController.text.isNotEmpty) {
                         context
                             .read<SettingsBloc>()
                             .add(AddWordToDictionary(_wordController.text));
                         _wordController.clear();
                       }
                     },
                    variant: MinimalistButtonVariant.primary,
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spaceMD),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                  border: Border.all(
                    color: isDarkMode
                        ? DesignTokens.trueWhite.withValues(alpha: 0.1)
                        : DesignTokens.pureBlack.withValues(alpha: 0.1),
                  ),
                ),
                child: state.dictionary.isEmpty
                    ? Container(
                        height: 80,
                        alignment: Alignment.center,
                        child: Text(
                          'No words added yet',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDarkMode
                                        ? DesignTokens.trueWhite
                                            .withValues(alpha: 0.5)
                                        : DesignTokens.pureBlack
                                            .withValues(alpha: 0.4),
                                  ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: state.dictionary.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: isDarkMode
                              ? DesignTokens.trueWhite.withValues(alpha: 0.1)
                              : DesignTokens.pureBlack.withValues(alpha: 0.1),
                        ),
                        itemBuilder: (context, index) {
                          final word = state.dictionary[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DesignTokens.spaceMD,
                              vertical: DesignTokens.spaceSM,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.label_rounded,
                                  size: DesignTokens.iconSizeXS,
                                  color: isDarkMode
                                      ? DesignTokens.trueWhite
                                          .withValues(alpha: 0.6)
                                      : DesignTokens.pureBlack
                                          .withValues(alpha: 0.5),
                                ),
                                const SizedBox(width: DesignTokens.spaceSM),
                                Expanded(
                                  child: Text(
                                    word,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: isDarkMode
                                              ? DesignTokens.trueWhite
                                              : DesignTokens.pureBlack,
                                        ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_rounded,
                                    size: DesignTokens.iconSizeXS,
                                    color: DesignTokens.vibrantCoral,
                                  ),
                                  onPressed: () {
                                    context
                                        .read<SettingsBloc>()
                                        .add(RemoveWordFromDictionary(word));
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhraseReplacementSection(
      BuildContext context, SettingsState state, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceXS),
              decoration: BoxDecoration(
                gradient: DesignTokens.greenGradient,
                borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
              ),
              child: Icon(
                Icons.find_replace_rounded,
                color: DesignTokens.trueWhite,
                size: DesignTokens.iconSizeSM,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceSM),
            Text(
              'Phrase Replacements',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: DesignTokens.fontWeightSemiBold,
                    color: isDarkMode
                        ? DesignTokens.trueWhite
                        : DesignTokens.pureBlack,
                  ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spaceSM),
        Text(
          'Replace phrases in transcriptions with custom text (e.g., "link to calendar" → "https://calendar.google.com").',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDarkMode
                    ? DesignTokens.trueWhite.withValues(alpha: 0.7)
                    : DesignTokens.pureBlack.withValues(alpha: 0.6),
              ),
        ),
        const SizedBox(height: DesignTokens.spaceMD),
        MinimalistCard(
          padding: const EdgeInsets.all(DesignTokens.spaceMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: MinimalistInput(
                      controller: _fromPhraseController,
                      placeholder: 'From phrase',
                      prefixIcon: Icons.text_fields_rounded,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceSM),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: isDarkMode
                        ? DesignTokens.trueWhite.withValues(alpha: 0.6)
                        : DesignTokens.pureBlack.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: DesignTokens.spaceSM),
                  Expanded(
                    flex: 2,
                    child: MinimalistInput(
                      controller: _toPhraseController,
                      placeholder: 'To phrase',
                      prefixIcon: Icons.text_snippet_rounded,
                      onSubmitted: (value) {
                        if (_fromPhraseController.text.isNotEmpty &&
                            value.isNotEmpty) {
                          context.read<SettingsBloc>().add(AddPhraseReplacement(
                              _fromPhraseController.text, value));
                          _fromPhraseController.clear();
                          _toPhraseController.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceSM),
                  MinimalistButton(
                    label: 'Add',
                    onPressed: () {
                      if (_fromPhraseController.text.isNotEmpty &&
                          _toPhraseController.text.isNotEmpty) {
                        context.read<SettingsBloc>().add(AddPhraseReplacement(
                            _fromPhraseController.text,
                            _toPhraseController.text));
                        _fromPhraseController.clear();
                        _toPhraseController.clear();
                      }
                    },
                    variant: MinimalistButtonVariant.primary,
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spaceMD),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                  border: Border.all(
                    color: isDarkMode
                        ? DesignTokens.trueWhite.withValues(alpha: 0.1)
                        : DesignTokens.pureBlack.withValues(alpha: 0.1),
                  ),
                ),
                child: state.phraseReplacements.isEmpty
                    ? Container(
                        height: 80,
                        alignment: Alignment.center,
                        child: Text(
                          'No phrase replacements added yet',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDarkMode
                                        ? DesignTokens.trueWhite
                                            .withValues(alpha: 0.5)
                                        : DesignTokens.pureBlack
                                            .withValues(alpha: 0.4),
                                  ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: state.phraseReplacements.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: isDarkMode
                              ? DesignTokens.trueWhite.withValues(alpha: 0.1)
                              : DesignTokens.pureBlack.withValues(alpha: 0.1),
                        ),
                        itemBuilder: (context, index) {
                          final entry =
                              state.phraseReplacements.entries.elementAt(index);
                          return Container(
                            padding: const EdgeInsets.all(DesignTokens.spaceMD),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.swap_horiz_rounded,
                                  size: DesignTokens.iconSizeXS,
                                  color: isDarkMode
                                      ? DesignTokens.trueWhite
                                          .withValues(alpha: 0.6)
                                      : DesignTokens.pureBlack
                                          .withValues(alpha: 0.5),
                                ),
                                const SizedBox(width: DesignTokens.spaceSM),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${entry.key} → ${entry.value}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight:
                                                  DesignTokens.fontWeightMedium,
                                              color: isDarkMode
                                                  ? DesignTokens.trueWhite
                                                  : DesignTokens.pureBlack,
                                            ),
                                      ),
                                      const SizedBox(
                                          height: DesignTokens.spaceXS),
                                      Text(
                                        'Replace "${entry.key}" with "${entry.value}"',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: isDarkMode
                                                  ? DesignTokens.trueWhite
                                                      .withValues(alpha: 0.6)
                                                  : DesignTokens.pureBlack
                                                      .withValues(alpha: 0.5),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_rounded,
                                    size: DesignTokens.iconSizeXS,
                                    color: DesignTokens.vibrantCoral,
                                  ),
                                  onPressed: () {
                                    context.read<SettingsBloc>().add(
                                        RemovePhraseReplacement(entry.key));
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
