import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/features/home/presentation/pages/home_page.dart';
import 'package:autoquill_ai/features/transcription/presentation/pages/transcription_page.dart';
import 'package:autoquill_ai/features/settings/presentation/pages/settings.dart';
import 'package:autoquill_ai/features/recording/presentation/bloc/recording_bloc.dart';
import 'package:autoquill_ai/features/transcription/presentation/bloc/transcription_bloc.dart';
import 'package:autoquill_ai/features/recording/domain/repositories/recording_repository.dart';
import 'package:autoquill_ai/features/transcription/domain/repositories/transcription_repository.dart';
import 'package:autoquill_ai/widgets/hotkey_handler.dart';
import 'package:window_manager/window_manager.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const TranscriptionPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the blocs and repositories in the HotkeyHandler after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Make sure we can access all the required providers
      if (!mounted) return;
      
      try {
        final recordingBloc = context.read<RecordingBloc>();
        final transcriptionBloc = context.read<TranscriptionBloc>();
        final recordingRepository = context.read<RecordingRepository>();
        final transcriptionRepository = context.read<TranscriptionRepository>();

        HotkeyHandler.setBlocs(recordingBloc, transcriptionBloc,
            recordingRepository, transcriptionRepository);

        // Force reload hotkeys to ensure they're properly registered
        HotkeyHandler.reloadHotkeys().then((_) {
          if (kDebugMode) {
            print('Hotkeys reloaded after blocs initialization');
          }
        });

        if (kDebugMode) {
          print('HotkeyHandler initialized with blocs and repositories');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error initializing HotkeyHandler: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Custom draggable area for the entire navigation rail
          MouseRegion(
            cursor: SystemMouseCursors.basic,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (_) async {
                await windowManager.startDragging();
              },
              child: NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                labelType: NavigationRailLabelType.selected,
                leading: Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 6.0),
                  child: Column(
                    children: [
                      // Spacer for top padding
                      SizedBox(height: 8),
                      // App logo
                      Image.asset(
                        'assets/icons/with_bg/autoquill_centered_1024_rounded.png',
                        width: 48,
                        height: 48,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.mic_outlined),
                    selectedIcon: Icon(Icons.mic),
                    label: Text('Transcription'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: Text('Settings'),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // This is the main content.
          Expanded(
            child: Column(
              children: [
                // Draggable area for the top of the content
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanStart: (_) async {
                    await windowManager.startDragging();
                  },
                  child: Container(
                    height: 32,
                    width: double.infinity,
                    color: Colors.transparent,
                  ),
                ),
                // Main content
                Expanded(
                  child: _pages[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
