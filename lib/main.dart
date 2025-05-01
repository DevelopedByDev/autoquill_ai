import 'package:autoquill_ai/features/transcription/presentation/pages/transcription_page.dart';
import 'package:autoquill_ai/features/transcription/presentation/bloc/transcription_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'core/di/injection_container.dart' as di;
import 'core/storage/app_storage.dart';
import 'features/recording/presentation/bloc/recording_bloc.dart';
import 'features/transcription/domain/repositories/transcription_repository.dart';
import 'hotkey_converter.dart'; //Import hotkey_converter

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final appDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDir.path);
  await AppStorage.init();

  // Load API key and hotkeys
  await _loadStoredData();

  // Initialize dependency injection
  await di.init();

  runApp(const MainApp());
}

Future<void> _loadStoredData() async {
  // Load API Key
  await AppStorage.getApiKey();

  // Load Hotkeys
  final transcriptionHotkey = Hive.box('settings').get('transcription_hotkey');
  final assistantHotkey = Hive.box('settings').get('assistant_hotkey');

  if (transcriptionHotkey != null) {
    try {
      final hotkey = hotKeyConverter(transcriptionHotkey);
      await hotKeyManager.register(
        hotkey,
        keyDownHandler: (hotKey) {
          String log = 'keyDown ${hotKey.debugName} (${hotKey.scope})';
          BotToast.showText(text: log);
          print("keyDown ${hotKey.debugName} (${hotKey.scope})");
        },
        keyUpHandler: (hotKey) {
          String log = 'keyUp   ${hotKey.debugName} (${hotKey.scope})';
          BotToast.showText(text: log);
          print("keyUp ${hotKey.debugName} (${hotKey.scope})");
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error loading transcription hotkey: $e');
      }
    }
  }

  if (assistantHotkey != null) {
    try {
      final hotkey = hotKeyConverter(assistantHotkey);
      await hotKeyManager.register(
        hotkey,
        keyDownHandler: (hotKey) {
          String log = 'keyDown ${hotKey.debugName} (${hotKey.scope})';
          BotToast.showText(text: log);
          print("keyDown ${hotKey.debugName} (${hotKey.scope})");
        },
        keyUpHandler: (hotKey) {
          String log = 'keyUp   ${hotKey.debugName} (${hotKey.scope})';
          BotToast.showText(text: log);
          print("keyUp ${hotKey.debugName} (${hotKey.scope})");
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error loading assistant hotkey: $e');
      }
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
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AutoQuill AI',
          builder: BotToastInit(),
          navigatorObservers: [BotToastNavigatorObserver()],
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          home: MultiRepositoryProvider(
            providers: [
              RepositoryProvider<TranscriptionRepository>(
                create: (_) => di.sl<TranscriptionRepository>(),
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
              child: const TranscriptionPage(),
            ),
          ),
        ),
      ),
    );
  }
}
