import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:autoquill_ai/core/theme/design_tokens.dart';
import 'package:autoquill_ai/features/mobile/presentation/pages/mobile_home_page.dart';
import 'package:autoquill_ai/features/mobile/presentation/pages/mobile_settings_page.dart';

class MobileMainPage extends StatefulWidget {
  const MobileMainPage({super.key});

  @override
  State<MobileMainPage> createState() => _MobileMainPageState();
}

class _MobileMainPageState extends State<MobileMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MobileHomePage(),
    const MobileSettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('🏠 MAIN_PAGE: initState called');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ MAIN_PAGE: build called with currentIndex: $_currentIndex');

    try {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      debugPrint('🎨 MAIN_PAGE: isDarkMode: $isDarkMode');

      return Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? DesignTokens.pureBlack.withValues(alpha: 0.3)
                    : DesignTokens.pureBlack.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              debugPrint(
                  '📱 MAIN_PAGE: Bottom nav tapped, switching to index: $index');
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: isDarkMode
                ? DesignTokens.darkSurface
                : DesignTokens.lightSurface,
            selectedItemColor: DesignTokens.vibrantCoral,
            unselectedItemColor: isDarkMode
                ? DesignTokens.trueWhite.withValues(alpha: 0.6)
                : DesignTokens.pureBlack.withValues(alpha: 0.6),
            selectedLabelStyle: TextStyle(
              fontWeight: DesignTokens.fontWeightSemiBold,
              fontSize: 12,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: DesignTokens.fontWeightRegular,
              fontSize: 12,
            ),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded),
                activeIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ MAIN_PAGE: Error in build: $e');
      debugPrint('📍 MAIN_PAGE: Stack trace: $stackTrace');

      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Main Page Build Error'),
              Text('$e'),
            ],
          ),
        ),
      );
    }
  }
}
