// Core imports
import 'package:autoquill_ai/core/storage/app_storage.dart';
import 'package:autoquill_ai/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:autoquill_ai/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:autoquill_ai/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:autoquill_ai/features/onboarding/presentation/widgets/api_key_step.dart';
// Choose Tools step removed
import 'package:autoquill_ai/features/onboarding/presentation/widgets/completed_step.dart';
import 'package:autoquill_ai/features/onboarding/presentation/widgets/hotkeys_step.dart';
import 'package:autoquill_ai/features/onboarding/presentation/widgets/test_hotkeys_step.dart';
import 'package:autoquill_ai/features/onboarding/presentation/widgets/permissions_step.dart';
import 'package:autoquill_ai/features/onboarding/presentation/widgets/preferences_step.dart';
import 'package:autoquill_ai/features/onboarding/presentation/widgets/welcome_step.dart';
import 'package:autoquill_ai/core/theme/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: DesignTokens.durationMedium,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: DesignTokens.emphasizedCurve,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => OnboardingBloc()..add(InitializeOnboarding()),
      child: BlocConsumer<OnboardingBloc, OnboardingState>(
        listenWhen: (previous, current) =>
            previous.currentStep != current.currentStep ||
            previous.themeMode != current.themeMode,
        listener: (context, state) {
          if (state.currentStep == OnboardingStep.completed) {
            // Use a more robust approach to restart the app
            // This will ensure all providers are properly initialized
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Close the current onboarding page
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
            });
          } else {
            // Animate to the current step
            _pageController.animateToPage(
              state.currentStep.index,
              duration: DesignTokens.durationMedium,
              curve: DesignTokens.emphasizedCurve,
            );

            // Update progress animation
            final progress = (state.currentStep.index) /
                (OnboardingStep.completed.index - 1);
            _progressAnimationController.animateTo(progress);

            // Apply theme changes immediately
            if (state.themeMode == ThemeMode.light) {
              AppStorage.settingsBox.put('theme_mode', 'light');
            } else if (state.themeMode == ThemeMode.dark) {
              AppStorage.settingsBox.put('theme_mode', 'dark');
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    DesignTokens.vibrantCoral.withValues(alpha: 0.15),
                    DesignTokens.deepBlue.withValues(alpha: 0.1),
                    DesignTokens.emeraldGreen.withValues(alpha: 0.05),
                    isDarkMode
                        ? DesignTokens.pureBlack
                        : DesignTokens.trueWhite,
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Top padding for window controls
                    const SizedBox(height: DesignTokens.spaceXL),

                    // Enhanced progress indicator
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spaceLG),
                      child: Column(
                        children: [
                          // Progress bar with custom styling
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(DesignTokens.radiusXS),
                              color: isDarkMode
                                  ? DesignTokens.darkSurfaceVariant
                                  : DesignTokens.lightSurfaceVariant,
                            ),
                            child: AnimatedBuilder(
                              animation: _progressAnimation,
                              builder: (context, child) {
                                return LinearProgressIndicator(
                                  value: _progressAnimation.value,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    DesignTokens.vibrantCoral,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      DesignTokens.radiusXS),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: DesignTokens.spaceSM),

                          // Step indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Step ${state.currentStep.index + 1} of ${OnboardingStep.completed.index}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isDarkMode
                                          ? DesignTokens.trueWhite
                                              .withValues(alpha: 0.7)
                                          : DesignTokens.pureBlack
                                              .withValues(alpha: 0.6),
                                      fontWeight: DesignTokens.fontWeightMedium,
                                    ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DesignTokens.spaceSM,
                                  vertical: DesignTokens.spaceXXS,
                                ),
                                decoration: BoxDecoration(
                                  gradient: DesignTokens.coralGradient,
                                  borderRadius: BorderRadius.circular(
                                      DesignTokens.radiusSM),
                                ),
                                child: Text(
                                  _getStepName(state.currentStep),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: DesignTokens.trueWhite,
                                        fontWeight:
                                            DesignTokens.fontWeightMedium,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: DesignTokens.spaceXL),

                    // Page content with enhanced styling
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.spaceMD),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? DesignTokens.darkSurfaceElevated
                                  .withValues(alpha: 0.95)
                              : DesignTokens.trueWhite.withValues(alpha: 0.95),
                          borderRadius:
                              BorderRadius.circular(DesignTokens.radiusLG),
                          boxShadow: isDarkMode
                              ? DesignTokens.cardShadowDark
                              : DesignTokens.cardShadow,
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(DesignTokens.radiusLG),
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: const [
                              WelcomeStep(),
                              PermissionsStep(),
                              // ChooseToolsStep removed
                              ApiKeyStep(),
                              HotkeysStep(),
                              TestHotkeysStep(),
                              PreferencesStep(),
                              CompletedStep(),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Enhanced navigation buttons
                    if (state.currentStep != OnboardingStep.completed)
                      Container(
                        padding: const EdgeInsets.all(DesignTokens.spaceLG),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back button with enhanced styling
                            if (state.currentStep != OnboardingStep.welcome)
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      DesignTokens.radiusMD),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    context
                                        .read<OnboardingBloc>()
                                        .add(NavigateToPreviousStep());
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: isDarkMode
                                        ? DesignTokens.darkSurfaceElevated
                                        : DesignTokens.trueWhite,
                                    foregroundColor: isDarkMode
                                        ? DesignTokens.trueWhite
                                        : DesignTokens.pureBlack,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: DesignTokens.spaceLG,
                                      vertical: DesignTokens.spaceMD,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          DesignTokens.radiusMD),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.arrow_back_rounded,
                                        size: DesignTokens.iconSizeSM,
                                      ),
                                      const SizedBox(
                                          width: DesignTokens.spaceXS),
                                      const Text('Back',
                                          style: TextStyle(
                                            fontSize: 16,
                                          )),
                                    ],
                                  ),
                                ),
                              )
                            else
                              const SizedBox(width: 100),

                            // Next/Continue button with gradient
                            Container(
                              decoration: BoxDecoration(
                                gradient: _canProceed(state)
                                    ? DesignTokens.coralGradient
                                    : LinearGradient(
                                        colors: [
                                          DesignTokens.softGray,
                                          DesignTokens.softGray,
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(
                                    DesignTokens.radiusMD),
                                boxShadow: _canProceed(state)
                                    ? [
                                        BoxShadow(
                                          color: DesignTokens.vibrantCoral
                                              .withValues(alpha: 0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: ElevatedButton(
                                onPressed: _canProceed(state)
                                    ? () {
                                        if (state.currentStep ==
                                            OnboardingStep.preferences) {
                                          context
                                              .read<OnboardingBloc>()
                                              .add(CompleteOnboarding());
                                        } else {
                                          // If moving from hotkeys to test step, register hotkeys
                                          if (state.currentStep ==
                                              OnboardingStep.hotkeys) {
                                            context
                                                .read<OnboardingBloc>()
                                                .add(RegisterHotkeys());
                                          }
                                          context
                                              .read<OnboardingBloc>()
                                              .add(NavigateToNextStep());
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: DesignTokens.trueWhite,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: DesignTokens.spaceXL,
                                    vertical: DesignTokens.spaceMD,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        DesignTokens.radiusMD),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      state.currentStep ==
                                              OnboardingStep.preferences
                                          ? 'Finish'
                                          : state.currentStep ==
                                                  OnboardingStep.hotkeys
                                              ? 'Test'
                                              : 'Next',
                                      style: const TextStyle(
                                        fontWeight:
                                            DesignTokens.fontWeightSemiBold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: DesignTokens.spaceXS),
                                    Icon(
                                      state.currentStep ==
                                              OnboardingStep.preferences
                                          ? Icons.check_rounded
                                          : Icons.arrow_forward_rounded,
                                      size: DesignTokens.iconSizeSM,
                                      color: DesignTokens.trueWhite,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getStepName(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.welcome:
        return 'Welcome';
      case OnboardingStep.permissions:
        return 'Permissions';
      case OnboardingStep.apiKey:
        return 'API Setup';
      case OnboardingStep.hotkeys:
        return 'Hotkeys';
      case OnboardingStep.testHotkeys:
        return 'Testing';
      case OnboardingStep.preferences:
        return 'Preferences';
      case OnboardingStep.completed:
        return 'Complete';
    }
  }

  bool _canProceed(OnboardingState state) {
    // Add your logic here to determine if the user can proceed
    // This is a simplified version - you may want to check specific conditions for each step
    return true;
  }
}
