import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/features/home/presentation/pages/home_page.dart';
import 'package:autoquill_ai/features/settings/presentation/pages/settings.dart';
import 'package:autoquill_ai/features/recording/presentation/bloc/recording_bloc.dart';
import 'package:autoquill_ai/features/transcription/presentation/bloc/transcription_bloc.dart';
import 'package:autoquill_ai/features/recording/domain/repositories/recording_repository.dart';
import 'package:autoquill_ai/features/transcription/domain/repositories/transcription_repository.dart';
import 'package:autoquill_ai/widgets/hotkey_handler.dart';
import 'package:autoquill_ai/core/theme/design_tokens.dart';
import 'package:window_manager/window_manager.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  final List<Widget> _pages = [
    const HomePage(),
    const SettingsPage(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
      color: DesignTokens.vibrantCoral,
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
      color: DesignTokens.deepBlue,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: DesignTokens.durationMedium,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.emphasizedCurve,
    ));

    _animationController.forward();

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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? DesignTokens.darkBackgroundGradient
              : DesignTokens.backgroundGradient,
        ),
        child: Row(
          children: [
            // Enhanced custom navigation rail
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_slideAnimation.value * 120, 0),
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? DesignTokens.darkSurfaceElevated
                              .withValues(alpha: 0.8)
                          : DesignTokens.trueWhite.withValues(alpha: 0.9),
                      boxShadow: isDarkMode
                          ? DesignTokens.cardShadowDark
                          : DesignTokens.cardShadow,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(DesignTokens.radiusLG),
                        bottomRight: Radius.circular(DesignTokens.radiusLG),
                      ),
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.basic,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanStart: (_) async {
                          await windowManager.startDragging();
                        },
                        child: Column(
                          children: [
                            // Top padding for draggable area
                            const SizedBox(height: DesignTokens.spaceXXL),

                            // App logo with modern styling
                            Container(
                              padding:
                                  const EdgeInsets.all(DesignTokens.spaceXS),
                              decoration: BoxDecoration(
                                gradient: DesignTokens.coralGradient,
                                borderRadius: BorderRadius.circular(
                                    DesignTokens.radiusMD),
                                boxShadow: [
                                  BoxShadow(
                                    color: DesignTokens.vibrantCoral
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    DesignTokens.radiusSM),
                                child: Image.asset(
                                  'assets/icons/with_bg/autoquill_centered_1024_rounded.png',
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ),

                            const SizedBox(height: DesignTokens.spaceMD),

                            // Navigation items
                            Expanded(
                              child: ListView.builder(
                                itemCount: _navigationItems.length,
                                itemBuilder: (context, index) {
                                  final item = _navigationItems[index];
                                  final isSelected = _selectedIndex == index;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: DesignTokens.spaceXS,
                                      vertical: DesignTokens.spaceXXS,
                                    ),
                                    child: AnimatedContainer(
                                      duration: DesignTokens.durationMedium,
                                      curve: DesignTokens.emphasizedCurve,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? item.color.withValues(alpha: 0.1)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                            DesignTokens.radiusMD),
                                        border: isSelected
                                            ? Border.all(
                                                color: item.color
                                                    .withValues(alpha: 0.3),
                                                width: 1,
                                              )
                                            : null,
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _selectedIndex = index;
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(
                                              DesignTokens.radiusMD),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: DesignTokens.spaceMD,
                                              horizontal: DesignTokens.spaceXS,
                                            ),
                                            child: Column(
                                              children: [
                                                AnimatedContainer(
                                                  duration: DesignTokens
                                                      .durationMedium,
                                                  padding: const EdgeInsets.all(
                                                      DesignTokens.spaceXS),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? item.color.withValues(
                                                            alpha: 0.15)
                                                        : Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            DesignTokens
                                                                .radiusSM),
                                                  ),
                                                  child: Icon(
                                                    isSelected
                                                        ? item.selectedIcon
                                                        : item.icon,
                                                    color: isSelected
                                                        ? item.color
                                                        : (isDarkMode
                                                            ? DesignTokens
                                                                .trueWhite
                                                                .withValues(
                                                                    alpha: 0.6)
                                                            : DesignTokens
                                                                .pureBlack
                                                                .withValues(
                                                                    alpha:
                                                                        0.6)),
                                                    size:
                                                        DesignTokens.iconSizeMD,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height:
                                                        DesignTokens.spaceXXS),
                                                Text(
                                                  item.label,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(
                                                        color: isSelected
                                                            ? item.color
                                                            : (isDarkMode
                                                                ? DesignTokens
                                                                    .trueWhite
                                                                    .withValues(
                                                                        alpha:
                                                                            0.6)
                                                                : DesignTokens
                                                                    .pureBlack
                                                                    .withValues(
                                                                        alpha:
                                                                            0.6)),
                                                        fontWeight: isSelected
                                                            ? DesignTokens
                                                                .fontWeightSemiBold
                                                            : DesignTokens
                                                                .fontWeightRegular,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
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

            // This is the main content
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
                  // Main content with fade transition
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: DesignTokens.durationMedium,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.1, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        key: ValueKey(_selectedIndex),
                        child: _pages[_selectedIndex],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Color color;

  const NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.color,
  });
}
