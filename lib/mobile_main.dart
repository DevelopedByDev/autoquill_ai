import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'core/theme/app_theme.dart';
import 'core/stats/stats_service.dart';
import 'core/settings/settings_service.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/mobile/presentation/pages/mobile_onboarding_page.dart';
import 'features/mobile/presentation/pages/mobile_main_page.dart';
import 'core/storage/app_storage.dart';
import 'core/storage/mobile_app_storage.dart';

void main() async {
  debugPrint('🚀 MOBILE: Starting mobile app initialization...');

  try {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('✅ MOBILE: Flutter binding initialized');

    // Initialize Hive in application support directory
    debugPrint('📦 MOBILE: Initializing Hive...');
    final appDir = await getApplicationSupportDirectory();
    debugPrint('📁 MOBILE: App directory: ${appDir.path}');

    // Only initialize Hive if not already initialized
    if (!Hive.isAdapterRegistered(0)) {
      await Hive.initFlutter(appDir.path);
      debugPrint('✅ MOBILE: Hive initialized');
    } else {
      debugPrint('✅ MOBILE: Hive already initialized');
    }

    // Initialize AppStorage wrapper for Hive (needed by SettingsService)
    debugPrint('💾 MOBILE: Initializing AppStorage...');
    try {
      await AppStorage.init();
      debugPrint('✅ MOBILE: AppStorage initialized');
    } catch (e) {
      debugPrint('⚠️ MOBILE: AppStorage already initialized or error: $e');
    }

    // Initialize MobileAppStorage wrapper for Hive (mobile-specific)
    debugPrint('📱 MOBILE: Initializing MobileAppStorage...');
    try {
      await MobileAppStorage.init();
      debugPrint('✅ MOBILE: MobileAppStorage initialized');
    } catch (e) {
      debugPrint(
          '⚠️ MOBILE: MobileAppStorage already initialized or error: $e');
    }

    // Ensure stats box is open
    debugPrint('📊 MOBILE: Opening stats box...');
    try {
      if (!Hive.isBoxOpen('stats')) {
        await Hive.openBox('stats');
        debugPrint('✅ MOBILE: Stats box opened');
      } else {
        debugPrint('✅ MOBILE: Stats box already open');
      }
    } catch (e) {
      debugPrint('⚠️ MOBILE: Stats box error: $e');
    }

    // Initialize stats service
    debugPrint('⚙️ MOBILE: Initializing stats service...');
    try {
      await StatsService().init();
      debugPrint('✅ MOBILE: Stats service initialized');
    } catch (e) {
      debugPrint('⚠️ MOBILE: Stats service error: $e');
    }

    debugPrint('🎉 MOBILE: All initialization complete, starting app...');
    runApp(const MobileApp());
  } catch (e, stackTrace) {
    debugPrint('💥 MOBILE: Error during initialization: $e');
    debugPrint('📚 MOBILE: Stack trace: $stackTrace');

    // Still try to run the app even if some initialization fails
    runApp(const MobileApp());
  }
}

class MobileApp extends StatelessWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ MOBILE: Building MobileApp widget...');

    try {
      final settingsService = SettingsService();
      debugPrint('✅ MOBILE: SettingsService created');

      return BlocProvider(
        create: (_) {
          debugPrint('🔧 MOBILE: Creating SettingsBloc...');
          final bloc = SettingsBloc()..add(LoadSettings());
          debugPrint(
              '✅ MOBILE: SettingsBloc created and LoadSettings event added');
          return bloc;
        },
        child: Builder(
          builder: (context) {
            debugPrint('🏗️ MOBILE: Building app with BlocProvider...');

            return ValueListenableBuilder<Box<dynamic>>(
              valueListenable: settingsService.themeListenable,
              builder: (context, box, _) {
                debugPrint('🎨 MOBILE: Building with theme...');

                try {
                  final themeMode = settingsService.getThemeMode();
                  debugPrint('✅ MOBILE: Theme mode: $themeMode');

                  final settingsState = context.watch<SettingsBloc>().state;
                  if (settingsState.themeMode != themeMode) {
                    debugPrint(
                        '🔄 MOBILE: Theme mode mismatch, reloading settings...');
                    context.read<SettingsBloc>().add(LoadSettings());
                  }

                  debugPrint('🎯 MOBILE: Creating MaterialApp...');
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'AutoQuill Mobile',
                    builder: BotToastInit(),
                    navigatorObservers: [BotToastNavigatorObserver()],
                    theme: minimalistLightTheme,
                    darkTheme: minimalistDarkTheme,
                    themeMode: themeMode,
                    home: const MobileAppWrapper(),
                  );
                } catch (e, stackTrace) {
                  debugPrint('❌ MOBILE: Error in theme builder: $e');
                  debugPrint('📍 MOBILE: Stack trace: $stackTrace');

                  // Return a simple material app as fallback
                  return MaterialApp(
                    home: Scaffold(
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error,
                                size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            const Text('Theme Error'),
                            Text('$e'),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            );
          },
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ MOBILE: Error in MobileApp build: $e');
      debugPrint('📍 MOBILE: Stack trace: $stackTrace');

      // Return minimal error widget
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('App Build Error'),
                Text('$e'),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class MobileAppWrapper extends StatefulWidget {
  const MobileAppWrapper({super.key});

  @override
  State<MobileAppWrapper> createState() => _MobileAppWrapperState();
}

class _MobileAppWrapperState extends State<MobileAppWrapper>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  bool _hasApiKey = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    debugPrint('🔄 MOBILE: MobileAppWrapper initState called');

    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    _checkApiKey();
  }

  @override
  void dispose() {
    debugPrint('🧹 MOBILE: MobileAppWrapper dispose called');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    debugPrint('🔄 MOBILE: App lifecycle state changed to: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('🏠 MOBILE: App resumed from background');
        // Refresh API key status when app comes back to foreground
        if (!_isLoading) {
          _checkApiKey();
        }
        break;
      case AppLifecycleState.paused:
        debugPrint('⏸️ MOBILE: App paused/going to background');
        break;
      case AppLifecycleState.detached:
        debugPrint('🔚 MOBILE: App detached');
        break;
      case AppLifecycleState.inactive:
        debugPrint('💤 MOBILE: App inactive');
        break;
      case AppLifecycleState.hidden:
        debugPrint('👻 MOBILE: App hidden');
        break;
    }
  }

  Future<void> _checkApiKey() async {
    try {
      debugPrint('🔍 MOBILE: Checking API key...');
      debugPrint('📞 MOBILE: Calling MobileAppStorage.getApiKey()...');

      final apiKey = await MobileAppStorage.getApiKey();
      final hasKey = apiKey != null && apiKey.isNotEmpty;

      debugPrint(
          '✅ MOBILE: API key retrieved: ${hasKey ? 'Present' : 'Missing'}');

      setState(() {
        _hasApiKey = hasKey;
        _isLoading = false;
      });

      debugPrint(
          '✅ MOBILE: State updated - hasApiKey: $_hasApiKey, isLoading: $_isLoading');
    } catch (e) {
      debugPrint('❌ MOBILE: Error checking API key: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '🏗️ MOBILE: Building MobileAppWrapper - isLoading: $_isLoading, hasApiKey: $_hasApiKey, error: $_error');

    if (_isLoading) {
      debugPrint('⏳ MOBILE: Showing loading screen');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      debugPrint('❌ MOBILE: Showing error screen');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isLoading = true;
                  });
                  _checkApiKey();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasApiKey) {
      debugPrint('🏠 MOBILE: API key found, showing main page');
      return const MobileMainPage();
    } else {
      debugPrint('🚀 MOBILE: No API key, showing onboarding');
      return MobileOnboardingPage(
        onApiKeySet: () {
          debugPrint('🎉 MOBILE: API key set, refreshing state');
          _checkApiKey();
        },
      );
    }
  }
}
