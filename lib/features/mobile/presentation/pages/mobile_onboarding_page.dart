import 'package:flutter/foundation.dart';
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

class MobileOnboardingPage extends StatefulWidget {
  final VoidCallback onApiKeySet;

  const MobileOnboardingPage({
    super.key,
    required this.onApiKeySet,
  });

  @override
  State<MobileOnboardingPage> createState() => _MobileOnboardingPageState();
}

class _MobileOnboardingPageState extends State<MobileOnboardingPage>
    with TickerProviderStateMixin {
  final TextEditingController _apiKeyController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    debugPrint('🎬 ONBOARDING: initState called');

    try {
      // Initialize animations
      debugPrint('🎭 ONBOARDING: Initializing animations...');
      _animationController = AnimationController(
        duration: DesignTokens.durationLong,
        vsync: this,
      );

      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ));

      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: DesignTokens.emphasizedCurve,
      ));

      debugPrint('✅ ONBOARDING: Animations initialized');

      // Start animation
      _animationController.forward();
      debugPrint('▶️ ONBOARDING: Animation started');
    } catch (e, stackTrace) {
      debugPrint('❌ ONBOARDING: Error in initState: $e');
      debugPrint('📍 ONBOARDING: Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    debugPrint('🗑️ ONBOARDING: dispose called');
    _animationController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _saveApiKey() {
    debugPrint('💾 ONBOARDING: _saveApiKey called');

    final apiKey = _apiKeyController.text.trim();
    debugPrint('🔑 ONBOARDING: API key length: ${apiKey.length}');

    if (apiKey.isEmpty) {
      debugPrint('⚠️ ONBOARDING: API key is empty');
      BotToast.showText(
        text: 'Please enter your Groq API key',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (!apiKey.startsWith('gsk_')) {
      debugPrint('⚠️ ONBOARDING: API key does not start with gsk_');
      BotToast.showText(
        text: 'Please enter a valid Groq API key (starts with gsk_)',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      // Save the API key using the correct event
      debugPrint('📤 ONBOARDING: Sending SaveApiKey event to bloc');
      context.read<SettingsBloc>().add(SaveApiKey(apiKey));

      BotToast.showText(
        text: 'API key saved successfully!',
        duration: const Duration(seconds: 2),
      );

      // Notify parent that API key is set
      debugPrint('📞 ONBOARDING: Calling onApiKeySet callback');
      widget.onApiKeySet();
    } catch (e, stackTrace) {
      debugPrint('❌ ONBOARDING: Error saving API key: $e');
      debugPrint('📍 ONBOARDING: Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ ONBOARDING: build called');

    try {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      final screenHeight = MediaQuery.of(context).size.height;
      debugPrint(
          '🎨 ONBOARDING: isDarkMode: $isDarkMode, screenHeight: $screenHeight');

      return BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          debugPrint(
              '🔔 ONBOARDING: BlocListener triggered with state: ${state.error}');
          if (state.error?.isNotEmpty ?? false) {
            BotToast.showText(
              text: state.error!,
              duration: const Duration(seconds: 3),
            );
          }
        },
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: isDarkMode
                  ? DesignTokens.darkBackgroundGradient
                  : DesignTokens.backgroundGradient,
            ),
            child: SafeArea(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(DesignTokens.spaceLG),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // App Icon and Welcome
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: DesignTokens.coralGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: DesignTokens.vibrantCoral
                                          .withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.mic_rounded,
                                  size: 60,
                                  color: DesignTokens.trueWhite,
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.05),

                              // Welcome Text
                              Text(
                                'Welcome to\nAutoQuill Mobile',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                      fontWeight: DesignTokens.fontWeightBold,
                                      color: isDarkMode
                                          ? DesignTokens.trueWhite
                                          : DesignTokens.pureBlack,
                                    ),
                              ),

                              const SizedBox(height: DesignTokens.spaceMD),

                              Text(
                                'Capture your thoughts with multilingual transcription',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: isDarkMode
                                          ? DesignTokens.trueWhite
                                              .withValues(alpha: 0.8)
                                          : DesignTokens.pureBlack
                                              .withValues(alpha: 0.7),
                                      fontWeight:
                                          DesignTokens.fontWeightRegular,
                                    ),
                              ),

                              SizedBox(height: screenHeight * 0.08),

                              // API Key Section
                              MinimalistCard(
                                padding:
                                    const EdgeInsets.all(DesignTokens.spaceLG),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(
                                              DesignTokens.spaceXS),
                                          decoration: BoxDecoration(
                                            gradient: DesignTokens.blueGradient,
                                            borderRadius: BorderRadius.circular(
                                                DesignTokens.radiusSM),
                                          ),
                                          child: Icon(
                                            Icons.key_rounded,
                                            color: DesignTokens.trueWhite,
                                            size: DesignTokens.iconSizeSM,
                                          ),
                                        ),
                                        const SizedBox(
                                            width: DesignTokens.spaceSM),
                                        Text(
                                          'Setup Required',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: DesignTokens
                                                    .fontWeightSemiBold,
                                                color: isDarkMode
                                                    ? DesignTokens.trueWhite
                                                    : DesignTokens.pureBlack,
                                              ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                        height: DesignTokens.spaceMD),

                                    Text(
                                      'To get started, you\'ll need a Groq API key. This enables fast, accurate transcription across multiple languages.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: isDarkMode
                                                ? DesignTokens.trueWhite
                                                    .withValues(alpha: 0.8)
                                                : DesignTokens.pureBlack
                                                    .withValues(alpha: 0.7),
                                          ),
                                    ),

                                    const SizedBox(
                                        height: DesignTokens.spaceLG),

                                    // API Key Input
                                    MinimalistInput(
                                      controller: _apiKeyController,
                                      placeholder:
                                          'Enter your Groq API key (gsk_...)',
                                      prefixIcon: Icons.vpn_key_rounded,
                                      isObscured: true,
                                      onSubmitted: (_) => _saveApiKey(),
                                    ),

                                    const SizedBox(
                                        height: DesignTokens.spaceMD),

                                    // Info section
                                    Container(
                                      padding: const EdgeInsets.all(
                                          DesignTokens.spaceMD),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? DesignTokens.trueWhite
                                                .withValues(alpha: 0.05)
                                            : DesignTokens.pureBlack
                                                .withValues(alpha: 0.03),
                                        borderRadius: BorderRadius.circular(
                                            DesignTokens.radiusSM),
                                        border: Border.all(
                                          color: isDarkMode
                                              ? DesignTokens.trueWhite
                                                  .withValues(alpha: 0.1)
                                              : DesignTokens.pureBlack
                                                  .withValues(alpha: 0.08),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline_rounded,
                                                size: DesignTokens.iconSizeXS,
                                                color: isDarkMode
                                                    ? DesignTokens.trueWhite
                                                        .withValues(alpha: 0.6)
                                                    : DesignTokens.pureBlack
                                                        .withValues(alpha: 0.5),
                                              ),
                                              const SizedBox(
                                                  width: DesignTokens.spaceXS),
                                              Text(
                                                'How to get your API key:',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      fontWeight: DesignTokens
                                                          .fontWeightMedium,
                                                      color: isDarkMode
                                                          ? DesignTokens
                                                              .trueWhite
                                                              .withValues(
                                                                  alpha: 0.8)
                                                          : DesignTokens
                                                              .pureBlack
                                                              .withValues(
                                                                  alpha: 0.7),
                                                    ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                              height: DesignTokens.spaceXS),
                                          Text(
                                            '1. Visit console.groq.com\n2. Sign up or log in\n3. Go to API Keys section\n4. Create a new API key\n5. Copy and paste it here',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: isDarkMode
                                                      ? DesignTokens.trueWhite
                                                          .withValues(
                                                              alpha: 0.7)
                                                      : DesignTokens.pureBlack
                                                          .withValues(
                                                              alpha: 0.6),
                                                  height: 1.4,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(
                                        height: DesignTokens.spaceLG),

                                    // Continue Button
                                    SizedBox(
                                      width: double.infinity,
                                      child: MinimalistButton(
                                        label: 'Continue',
                                        onPressed: _saveApiKey,
                                        variant:
                                            MinimalistButtonVariant.primary,
                                        icon: Icons.arrow_forward_rounded,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ ONBOARDING: Error in build: $e');
      debugPrint('📍 ONBOARDING: Stack trace: $stackTrace');

      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Onboarding Build Error'),
              Text('$e'),
            ],
          ),
        ),
      );
    }
  }
}
