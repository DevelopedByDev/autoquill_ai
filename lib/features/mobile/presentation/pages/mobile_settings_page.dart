import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/core/theme/design_tokens.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_event.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';
import 'package:autoquill_ai/widgets/minimalist_input.dart';
import 'package:autoquill_ai/widgets/minimalist_button.dart';
import 'package:autoquill_ai/widgets/minimalist_card.dart';
import 'package:bot_toast/bot_toast.dart';

class MobileSettingsPage extends StatefulWidget {
  const MobileSettingsPage({super.key});

  @override
  State<MobileSettingsPage> createState() => _MobileSettingsPageState();
}

class _MobileSettingsPageState extends State<MobileSettingsPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _fromPhraseController = TextEditingController();
  final TextEditingController _toPhraseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load the current API key
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<SettingsBloc>().state;
      _apiKeyController.text = state.apiKey ?? '';
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _wordController.dispose();
    _fromPhraseController.dispose();
    _toPhraseController.dispose();
    super.dispose();
  }

  void _saveApiKey() {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      BotToast.showText(
        text: 'Please enter your Groq API key',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (!apiKey.startsWith('gsk_')) {
      BotToast.showText(
        text: 'Please enter a valid Groq API key (starts with gsk_)',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    context.read<SettingsBloc>().add(SaveApiKey(apiKey));
    BotToast.showText(
      text: 'API key updated successfully!',
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state.error?.isNotEmpty ?? false) {
          BotToast.showText(
            text: state.error!,
            duration: const Duration(seconds: 3),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: isDarkMode
                  ? DesignTokens.darkBackgroundGradient
                  : DesignTokens.backgroundGradient,
            ),
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  // App bar
                  SliverAppBar(
                    expandedHeight: 70,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              DesignTokens.vibrantCoral.withValues(alpha: 0.1),
                              DesignTokens.deepBlue.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: DesignTokens.spaceSM,
                              right: DesignTokens.spaceSM,
                              bottom: DesignTokens.spaceXS,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Settings',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: DesignTokens.fontWeightBold,
                                        color: isDarkMode
                                            ? DesignTokens.trueWhite
                                            : DesignTokens.pureBlack,
                                        fontSize: 20,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Configure your AutoQuill experience',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: isDarkMode
                                            ? DesignTokens.trueWhite
                                                .withValues(alpha: 0.8)
                                            : DesignTokens.pureBlack
                                                .withValues(alpha: 0.7),
                                        fontWeight:
                                            DesignTokens.fontWeightRegular,
                                        fontSize: 12,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Settings content
                  SliverPadding(
                    padding: const EdgeInsets.all(DesignTokens.spaceMD),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // API Key Section
                        _buildApiKeySection(context, state, isDarkMode),
                        const SizedBox(height: DesignTokens.spaceXL),

                        // Dictionary Section
                        _buildDictionarySection(context, state, isDarkMode),
                        const SizedBox(height: DesignTokens.spaceXL),

                        // Phrase Replacement Section
                        _buildPhraseReplacementSection(
                            context, state, isDarkMode),
                        const SizedBox(height: DesignTokens.spaceXL),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildApiKeySection(
      BuildContext context, SettingsState state, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceXXS),
              decoration: BoxDecoration(
                gradient: DesignTokens.blueGradient,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
              ),
              child: Icon(
                Icons.key_rounded,
                color: DesignTokens.trueWhite,
                size: DesignTokens.iconSizeSM,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceXS),
            Text(
              'Groq API Key',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: DesignTokens.fontWeightSemiBold,
                    color: isDarkMode
                        ? DesignTokens.trueWhite
                        : DesignTokens.pureBlack,
                    fontSize: 16,
                  ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spaceXS),
        Text(
          'Your API key for accessing Groq\'s transcription services.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDarkMode
                    ? DesignTokens.trueWhite.withValues(alpha: 0.7)
                    : DesignTokens.pureBlack.withValues(alpha: 0.6),
                fontSize: 12,
              ),
        ),
        const SizedBox(height: DesignTokens.spaceSM),
        MinimalistCard(
          padding: const EdgeInsets.all(DesignTokens.spaceSM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MinimalistInput(
                controller: _apiKeyController,
                placeholder: 'Enter your Groq API key (gsk_...)',
                prefixIcon: Icons.vpn_key_rounded,
                isObscured: true,
                onSubmitted: (_) => _saveApiKey(),
              ),
              const SizedBox(height: DesignTokens.spaceSM),
              SizedBox(
                width: double.infinity,
                child: MinimalistButton(
                  label: 'Save API Key',
                  onPressed: _saveApiKey,
                  variant: MinimalistButtonVariant.primary,
                  icon: Icons.save_rounded,
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
              padding: const EdgeInsets.all(DesignTokens.spaceXXS),
              decoration: BoxDecoration(
                gradient: DesignTokens.coralGradient,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
              ),
              child: Icon(
                Icons.book_rounded,
                color: DesignTokens.trueWhite,
                size: DesignTokens.iconSizeSM,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceXS),
            Text(
              'Dictionary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: DesignTokens.fontWeightSemiBold,
                    color: isDarkMode
                        ? DesignTokens.trueWhite
                        : DesignTokens.pureBlack,
                    fontSize: 16,
                  ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spaceXS),
        Text(
          'Add words that are harder for models to spell correctly.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDarkMode
                    ? DesignTokens.trueWhite.withValues(alpha: 0.7)
                    : DesignTokens.pureBlack.withValues(alpha: 0.6),
                fontSize: 12,
              ),
        ),
        const SizedBox(height: DesignTokens.spaceSM),
        MinimalistCard(
          padding: const EdgeInsets.all(DesignTokens.spaceSM),
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
                  const SizedBox(width: DesignTokens.spaceXS),
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
              const SizedBox(height: DesignTokens.spaceSM),
              Container(
                constraints: const BoxConstraints(maxHeight: 160),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
                  border: Border.all(
                    color: isDarkMode
                        ? DesignTokens.trueWhite.withValues(alpha: 0.1)
                        : DesignTokens.pureBlack.withValues(alpha: 0.1),
                  ),
                ),
                child: state.dictionary.isEmpty
                    ? Container(
                        height: 60,
                        alignment: Alignment.center,
                        child: Text(
                          'No words added yet',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDarkMode
                                        ? DesignTokens.trueWhite
                                            .withValues(alpha: 0.5)
                                        : DesignTokens.pureBlack
                                            .withValues(alpha: 0.4),
                                    fontSize: 12,
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
                              horizontal: DesignTokens.spaceSM,
                              vertical: DesignTokens.spaceXS,
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
                                const SizedBox(width: DesignTokens.spaceXS),
                                Expanded(
                                  child: Text(
                                    word,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: isDarkMode
                                              ? DesignTokens.trueWhite
                                              : DesignTokens.pureBlack,
                                          fontSize: 12,
                                        ),
                                  ),
                                ),
                                IconButton(
                                  iconSize: DesignTokens.iconSizeSM,
                                  icon: Icon(
                                    Icons.delete_rounded,
                                    size: DesignTokens.iconSizeSM,
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
              padding: const EdgeInsets.all(DesignTokens.spaceXXS),
              decoration: BoxDecoration(
                gradient: DesignTokens.greenGradient,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
              ),
              child: Icon(
                Icons.find_replace_rounded,
                color: DesignTokens.trueWhite,
                size: DesignTokens.iconSizeSM,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceXS),
            Text(
              'Phrase Replacements',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: DesignTokens.fontWeightSemiBold,
                    color: isDarkMode
                        ? DesignTokens.trueWhite
                        : DesignTokens.pureBlack,
                    fontSize: 16,
                  ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spaceXS),
        Text(
          'Replace phrases in transcriptions with custom text.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDarkMode
                    ? DesignTokens.trueWhite.withValues(alpha: 0.7)
                    : DesignTokens.pureBlack.withValues(alpha: 0.6),
                fontSize: 12,
              ),
        ),
        const SizedBox(height: DesignTokens.spaceSM),
        MinimalistCard(
          padding: const EdgeInsets.all(DesignTokens.spaceSM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input fields
              MinimalistInput(
                controller: _fromPhraseController,
                placeholder: 'From phrase',
                prefixIcon: Icons.text_fields_rounded,
              ),
              const SizedBox(height: DesignTokens.spaceXS),
              MinimalistInput(
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
              const SizedBox(height: DesignTokens.spaceSM),
              SizedBox(
                width: double.infinity,
                child: MinimalistButton(
                  label: 'Add Replacement',
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
                  icon: Icons.add_rounded,
                ),
              ),
              const SizedBox(height: DesignTokens.spaceSM),
              Container(
                constraints: const BoxConstraints(maxHeight: 160),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
                  border: Border.all(
                    color: isDarkMode
                        ? DesignTokens.trueWhite.withValues(alpha: 0.1)
                        : DesignTokens.pureBlack.withValues(alpha: 0.1),
                  ),
                ),
                child: state.phraseReplacements.isEmpty
                    ? Container(
                        height: 60,
                        alignment: Alignment.center,
                        child: Text(
                          'No phrase replacements added yet',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDarkMode
                                        ? DesignTokens.trueWhite
                                            .withValues(alpha: 0.5)
                                        : DesignTokens.pureBlack
                                            .withValues(alpha: 0.4),
                                    fontSize: 12,
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
                            padding: const EdgeInsets.all(DesignTokens.spaceSM),
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
                                const SizedBox(width: DesignTokens.spaceXS),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${entry.key} → ${entry.value}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontWeight:
                                                  DesignTokens.fontWeightMedium,
                                              color: isDarkMode
                                                  ? DesignTokens.trueWhite
                                                  : DesignTokens.pureBlack,
                                              fontSize: 12,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  iconSize: DesignTokens.iconSizeSM,
                                  icon: Icon(
                                    Icons.delete_rounded,
                                    size: DesignTokens.iconSizeSM,
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
