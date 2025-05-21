// Core imports
import 'package:autoquill_ai/core/storage/app_storage.dart';
import 'package:autoquill_ai/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:autoquill_ai/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:autoquill_ai/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:autoquill_ai/features/onboarding/presentation/widgets/api_key_step.dart';
// Choose Tools step removed
import 'package:autoquill_ai/features/onboarding/presentation/widgets/completed_step.dart';
import 'package:autoquill_ai/features/onboarding/presentation/widgets/hotkeys_step.dart';
import 'package:autoquill_ai/features/onboarding/presentation/widgets/preferences_step.dart';
import 'package:autoquill_ai/features/onboarding/presentation/widgets/welcome_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            });
          } else {
            // Animate to the current step
            _pageController.animateToPage(
              state.currentStep.index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            
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
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Add sufficient padding at the top to avoid window control buttons
                    const SizedBox(height: 40),
                    
                    // Progress indicator
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: LinearProgressIndicator(
                        value: (state.currentStep.index) / (OnboardingStep.completed.index - 1),
                        backgroundColor: Colors.grey.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    
                    // Page content
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: const [
                          WelcomeStep(),
                          // ChooseToolsStep removed
                          ApiKeyStep(),
                          HotkeysStep(),
                          PreferencesStep(),
                          CompletedStep(),
                        ],
                      ),
                    ),
                    
                    // Navigation buttons
                    if (state.currentStep != OnboardingStep.completed)
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back button
                            if (state.currentStep != OnboardingStep.welcome)
                              TextButton(
                                onPressed: () {
                                  context.read<OnboardingBloc>().add(NavigateToPreviousStep());
                                },
                                child: const Text('Back'),
                              )
                            else
                              const SizedBox(width: 80),
                            
                            // Next/Continue button
                            ElevatedButton(
                              onPressed: _canProceed(state)
                                ? () {
                                    if (state.currentStep == OnboardingStep.preferences) {
                                      context.read<OnboardingBloc>().add(CompleteOnboarding());
                                    } else {
                                      context.read<OnboardingBloc>().add(NavigateToNextStep());
                                    }
                                  }
                                : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                  vertical: 12.0,
                                ),
                              ),
                              child: Text(
                                state.currentStep == OnboardingStep.preferences
                                    ? 'Finish'
                                    : 'Next',
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

  bool _canProceed(OnboardingState state) {
    switch (state.currentStep) {
      case OnboardingStep.welcome:
        return true;
      // Choose Tools step removed
      case OnboardingStep.apiKey:
        return state.canProceedFromApiKey;
      case OnboardingStep.hotkeys:
        return state.canProceedFromHotkeys;
      case OnboardingStep.preferences:
        return true;
      case OnboardingStep.completed:
        return true;
    }
  }
}
