import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  // Default to dark theme
  ThemeMode _themeMode = ThemeMode.dark;
  
  ThemeProvider() {
    _loadThemeFromStorage();
  }
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  ThemeData get currentTheme => _themeMode == ThemeMode.dark 
      ? minimalistDarkTheme 
      : minimalistLightTheme;
  
  void _loadThemeFromStorage() {
    final box = Hive.box('settings');
    final savedTheme = box.get(_themeKey);
    
    if (savedTheme != null) {
      _themeMode = savedTheme == 'light' ? ThemeMode.light : ThemeMode.dark;
    }
  }
  
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    
    // Save to storage
    final box = Hive.box('settings');
    await box.put(_themeKey, _themeMode == ThemeMode.dark ? 'dark' : 'light');
    
    notifyListeners();
  }
}
