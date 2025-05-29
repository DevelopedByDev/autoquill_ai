import 'package:autoquill_ai/features/transcription/presentation/bloc/transcription_bloc.dart';
import 'package:autoquill_ai/features/recording/domain/repositories/recording_repository.dart';
import 'package:autoquill_ai/features/navigation/presentation/pages/main_layout.dart';
import 'package:autoquill_ai/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

import 'core/theme/app_theme.dart';
import 'core/stats/stats_service.dart';
import 'core/settings/settings_service.dart';
import 'core/services/auto_update_service.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';

import 'core/di/injection_container.dart' as di;
import 'core/storage/app_storage.dart';
import 'features/recording/presentation/bloc/recording_bloc.dart';
import 'features/transcription/domain/repositories/transcription_repository.dart';
import 'widgets/hotkey_handler.dart';
import 'core/utils/sound_player.dart';
import 'features/hotkeys/utils/hotkey_registration.dart';
import 'features/transcription/data/repositories/transcription_repository_impl.dart';
import 'features/transcription/services/smart_transcription_service.dart';

// App lifecycle observer to cleanup when app is closed
class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // Cleanup resources
      TranscriptionRepositoryImpl.dispose();
      SmartTranscriptionService.dispose();
      SoundPlayer.dispose();
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager to hide title bar
  await windowManager.ensureInitialized();

  // Apply window options
  await windowManager.waitUntilReadyToShow();
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  await windowManager.setBackgroundColor(Colors.transparent);
  await windowManager.setTitle('AutoQuill');
  await windowManager.setSize(const Size(1000, 850));
  await windowManager.setMinimumSize(const Size(1000, 600));
  await windowManager.center();
  await windowManager.show();
  await windowManager.focus();

  // Initialize Hive in Documents directory
  final appDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDir.path);

  // Initialize AppStorage wrapper for Hive
  await AppStorage.init();

  // Ensure stats box is open
  if (!Hive.isBoxOpen('stats')) {
    await Hive.openBox('stats');
  }

  // Initialize stats service
  await StatsService().init();

  // Initialize sound player early for faster first playback
  await SoundPlayer.initialize();

  // Load and register hotkeys ASAP before UI renders
  await _loadStoredData();

  // Clean up removed features (text mode and agent mode)
  await _cleanupRemovedFeatures();

  // Initialize dependency injection
  await di.init();

  // Initialize auto-updater (temporarily enabled for debug builds for testing)
  if (kReleaseMode || kDebugMode) {
    await AutoUpdateService.initialize();
  }

  runApp(const MainApp());

  // Initialize hotkey manager first
  await hotKeyManager.unregisterAll();

  // Lazy load hotkeys after UI is rendered
  HotkeyHandler.lazyLoadHotkeys();

  // Register app lifecycle observer for cleaning up resources
  WidgetsBinding.instance.addObserver(AppLifecycleObserver());
}

Future<void> _loadStoredData() async {
  // Load stored API key (if needed by app logic)
  await AppStorage.getApiKey();

  // Only prepare hotkeys quickly, actual registration will happen after UI is rendered
  await HotkeyHandler.prepareHotkeys();
}

/// Clean up settings for removed features (text mode and agent mode)
Future<void> _cleanupRemovedFeatures() async {
  try {
    final settingsBox = Hive.box('settings');

    // Remove text mode and agent mode hotkeys
    if (settingsBox.containsKey('text_hotkey')) {
      await settingsBox.delete('text_hotkey');
    }

    if (settingsBox.containsKey('agent_hotkey')) {
      await settingsBox.delete('agent_hotkey');
    }

    // Remove agent model setting
    if (settingsBox.containsKey('agent-model')) {
      await settingsBox.delete('agent-model');
    }

    if (kDebugMode) {
      print('Cleaned up removed features settings');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error cleaning up removed features: $e');
    }
  }
}

class ExampleIntent extends Intent {}

class ExampleAction extends Action<ExampleIntent> {
  @override
  void invoke(covariant ExampleIntent intent) {
    if (kDebugMode) {
      print('ExampleAction invoked');
    }
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the settings service
    final settingsService = SettingsService();

    return Actions(
      actions: <Type, Action<Intent>>{
        ExampleIntent: ExampleAction(),
      },
      child: GlobalShortcuts(
        shortcuts: {
          const SingleActivator(LogicalKeyboardKey.keyA, alt: true):
              ExampleIntent(),
        },
        child: BlocProvider(
          create: (_) => SettingsBloc()..add(LoadSettings()),
          child: Builder(
            builder: (context) {
              return ValueListenableBuilder<Box<dynamic>>(
                valueListenable: settingsService.themeListenable,
                builder: (context, box, _) {
                  // Get theme mode from the settings service
                  final themeMode = settingsService.getThemeMode();

                  // Also update the SettingsBloc state if it's different
                  final settingsState = context.watch<SettingsBloc>().state;
                  if (settingsState.themeMode != themeMode) {
                    // This ensures the bloc state stays in sync with the settings
                    context.read<SettingsBloc>().add(LoadSettings());
                  }

                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'AutoQuill',
                    builder: BotToastInit(),
                    navigatorObservers: [BotToastNavigatorObserver()],
                    theme: minimalistLightTheme,
                    darkTheme: minimalistDarkTheme,
                    themeMode: themeMode,
                    initialRoute: '/',
                    routes: {
                      '/': (context) => _buildHomeWidget(),
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHomeWidget() {
    // Check if onboarding is completed
    final bool isOnboardingCompleted = AppStorage.isOnboardingCompleted();

    if (isOnboardingCompleted) {
      // If onboarding is completed, ensure hotkeys are properly loaded
      // This is important to do before showing the main app
      HotkeyRegistration.ensureHotkeysLoadedAfterOnboarding();

      // If onboarding is completed, show the main app with all required providers
      return Builder(
        builder: (context) {
          return MultiRepositoryProvider(
            providers: [
              RepositoryProvider<TranscriptionRepository>(
                create: (_) => di.sl<TranscriptionRepository>(),
              ),
              RepositoryProvider<RecordingRepository>(
                create: (_) => di.sl<RecordingRepository>(),
              ),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => RecordingBloc(
                    repository: di.sl(),
                  ),
                ),
                BlocProvider(
                  create: (context) => TranscriptionBloc(
                    repository: context.read<TranscriptionRepository>(),
                  )..add(InitializeTranscription()),
                ),
                // Ensure SettingsBloc is available in the main layout
                BlocProvider(
                  create: (_) => SettingsBloc()..add(LoadSettings()),
                ),
              ],
              child: const MainLayout(),
            ),
          );
        },
      );
    } else {
      // If onboarding is not completed, show the onboarding flow
      return const OnboardingPage();
    }
  }
}
