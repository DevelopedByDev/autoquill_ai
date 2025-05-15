import 'package:autoquill_ai/features/transcription/presentation/bloc/transcription_bloc.dart';
import 'package:autoquill_ai/features/recording/domain/repositories/recording_repository.dart';
import 'package:autoquill_ai/features/navigation/presentation/pages/main_layout.dart';
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
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';

import 'core/di/injection_container.dart' as di;
import 'core/storage/app_storage.dart';
import 'features/recording/presentation/bloc/recording_bloc.dart';
import 'features/transcription/domain/repositories/transcription_repository.dart';
import 'widgets/hotkey_handler.dart';
import 'core/utils/sound_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager to hide title bar
  await windowManager.ensureInitialized();
  
  // Apply window options
  await windowManager.waitUntilReadyToShow();
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  await windowManager.setBackgroundColor(Colors.transparent);
  await windowManager.setTitle('AutoQuill AI');
  await windowManager.setSize(const Size(900, 650));
  await windowManager.setMinimumSize(const Size(800, 600));
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
  
  // Load and register hotkeys ASAP before UI renders
  await _loadStoredData();

  // Initialize dependency injection
  await di.init();

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

/// Observer for app lifecycle events to clean up resources
class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached || state == AppLifecycleState.hidden) {
      // Clean up resources when app is closed or hidden
      SoundPlayer.dispose();
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
              // Access the SettingsBloc from the current context
              final settingsState = context.watch<SettingsBloc>().state;
              
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'AutoQuill AI',
                builder: BotToastInit(),
                navigatorObservers: [BotToastNavigatorObserver()],
                theme: shadcnLightTheme,
                darkTheme: shadcnDarkTheme,
                themeMode: settingsState.themeMode,
                home: MultiRepositoryProvider(
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
                    repository: context.read(),
                  )..add(InitializeTranscription()),
                ),
              ],
              child: const MainLayout(),
            ),
          ),
              );
            },
          ),
        ),
      ),
    );
  }
}
