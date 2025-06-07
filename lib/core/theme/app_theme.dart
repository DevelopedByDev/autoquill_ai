import 'package:flutter/material.dart';
import 'design_tokens.dart';

// Minimalist dark theme
final ThemeData minimalistDarkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  fontFamily: 'Inter',
  scaffoldBackgroundColor: DesignTokens.pureBlack,
  colorScheme: const ColorScheme.dark(
    primary: DesignTokens.vibrantCoral,
    onPrimary: DesignTokens.trueWhite,
    secondary: DesignTokens.vibrantCoral,
    onSecondary: DesignTokens.trueWhite,
    background: DesignTokens.pureBlack,
    onBackground: DesignTokens.trueWhite,
    surface: DesignTokens.darkSurface,
    onSurface: DesignTokens.trueWhite,
    error: DesignTokens.vibrantCoral,
    onError: DesignTokens.trueWhite,
  ),
  cardColor: DesignTokens.darkSurface,
  dividerColor: DesignTokens.darkDivider,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: DesignTokens.darkSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
      borderSide: BorderSide(color: DesignTokens.vibrantCoral, width: DesignTokens.borderWidthMedium),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: DesignTokens.spaceSM,
      vertical: DesignTokens.spaceSM,
    ),
    labelStyle: TextStyle(
      color: Color.fromRGBO(255, 255, 255, DesignTokens.opacitySubtle),
      fontSize: DesignTokens.bodyMedium,
      fontWeight: DesignTokens.fontWeightRegular,
    ),
    hintStyle: TextStyle(
      color: Color.fromRGBO(255, 255, 255, DesignTokens.opacityDisabled),
      fontSize: DesignTokens.bodyMedium,
      fontWeight: DesignTokens.fontWeightRegular,
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: DesignTokens.headlineLarge,
      fontWeight: DesignTokens.fontWeightBold,
      color: DesignTokens.trueWhite,
      height: DesignTokens.headlineHeight,
    ),
    displayMedium: TextStyle(
      fontSize: DesignTokens.headlineMedium,
      fontWeight: DesignTokens.fontWeightBold,
      color: DesignTokens.trueWhite,
      height: DesignTokens.headlineHeight,
    ),
    displaySmall: TextStyle(
      fontSize: DesignTokens.headlineSmall,
      fontWeight: DesignTokens.fontWeightBold,
      color: DesignTokens.trueWhite,
      height: DesignTokens.headlineHeight,
    ),
    bodyLarge: TextStyle(
      fontSize: DesignTokens.bodyLarge,
      fontWeight: DesignTokens.fontWeightRegular,
      color: DesignTokens.trueWhite,
      height: DesignTokens.bodyHeight,
    ),
    bodyMedium: TextStyle(
      fontSize: DesignTokens.bodyMedium,
      fontWeight: DesignTokens.fontWeightRegular,
      color: DesignTokens.trueWhite,
      height: DesignTokens.bodyHeight,
    ),
    labelLarge: TextStyle(
      fontSize: DesignTokens.bodyMedium,
      fontWeight: DesignTokens.fontWeightMedium,
      color: DesignTokens.trueWhite,
      height: DesignTokens.captionHeight,
    ),
    labelMedium: TextStyle(
      fontSize: DesignTokens.captionSize,
      fontWeight: DesignTokens.fontWeightLight,
      color: DesignTokens.softGray,
      height: DesignTokens.captionHeight,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: DesignTokens.vibrantCoral,
      foregroundColor: DesignTokens.trueWhite,
      elevation: DesignTokens.elevationNone,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceMD,
        vertical: DesignTokens.spaceSM,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
      ),
      textStyle: const TextStyle(
        fontSize: DesignTokens.bodyMedium,
        fontWeight: DesignTokens.fontWeightMedium,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: DesignTokens.vibrantCoral,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceSM,
        vertical: DesignTokens.spaceXS,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
      ),
      textStyle: const TextStyle(
        fontSize: DesignTokens.bodyMedium,
        fontWeight: DesignTokens.fontWeightMedium,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: DesignTokens.trueWhite,
      side: const BorderSide(color: DesignTokens.darkDivider, width: DesignTokens.borderWidthThin),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceMD,
        vertical: DesignTokens.spaceSM,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
      ),
      textStyle: const TextStyle(
        fontSize: DesignTokens.bodyMedium,
        fontWeight: DesignTokens.fontWeightMedium,
      ),
    ),
  ),
  cardTheme: CardThemeData(
    color: DesignTokens.darkSurface,
    elevation: DesignTokens.elevationNone,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
    ),
    margin: EdgeInsets.zero,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: DesignTokens.darkSurface,
    elevation: DesignTokens.elevationNone,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
    ),
    titleTextStyle: const TextStyle(
      fontSize: DesignTokens.headlineSmall,
      fontWeight: DesignTokens.fontWeightBold,
      color: DesignTokens.trueWhite,
    ),
    contentTextStyle: const TextStyle(
      fontSize: DesignTokens.bodyMedium,
      fontWeight: DesignTokens.fontWeightRegular,
      color: DesignTokens.trueWhite,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: DesignTokens.pureBlack,
    foregroundColor: DesignTokens.trueWhite,
    elevation: DesignTokens.elevationNone,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: DesignTokens.headlineSmall,
      fontWeight: DesignTokens.fontWeightBold,
      color: DesignTokens.trueWhite,
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return DesignTokens.vibrantCoral;
      }
      return DesignTokens.darkDivider;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Color.fromRGBO(245, 80, 54, DesignTokens.opacityFaint);
      }
      return DesignTokens.darkSurface;
    }),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return DesignTokens.vibrantCoral;
      }
      return DesignTokens.darkSurface;
    }),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusSM / 2),
    ),
  ),
  iconTheme: const IconThemeData(
    color: DesignTokens.trueWhite,
    size: 24,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: DesignTokens.darkSurface,
    contentTextStyle: const TextStyle(color: DesignTokens.trueWhite),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
    ),
  ),
);

// Minimalist light theme
final ThemeData minimalistLightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  fontFamily: 'Inter',
  scaffoldBackgroundColor: DesignTokens.trueWhite,
  colorScheme: const ColorScheme.light(
    primary: DesignTokens.vibrantCoral,
    onPrimary: DesignTokens.trueWhite,
    secondary: DesignTokens.vibrantCoral,
    onSecondary: DesignTokens.trueWhite,
    background: DesignTokens.trueWhite,
    onBackground: DesignTokens.pureBlack,
    surface: DesignTokens.softGray,
    onSurface: DesignTokens.pureBlack,
    error: DesignTokens.vibrantCoral,
    onError: DesignTokens.trueWhite,
  ),
  cardColor: DesignTokens.softGray,
  dividerColor: DesignTokens.softGray,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: DesignTokens.softGray,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
      borderSide: const BorderSide(color: DesignTokens.vibrantCoral, width: DesignTokens.borderWidthMedium),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: DesignTokens.spaceSM,
      vertical: DesignTokens.spaceSM,
    ),
    labelStyle: TextStyle(
      color: Color.fromRGBO(0, 0, 0, DesignTokens.opacitySubtle),
      fontSize: DesignTokens.bodyMedium,
      fontWeight: DesignTokens.fontWeightRegular,
    ),
    hintStyle: TextStyle(
      color: Color.fromRGBO(0, 0, 0, DesignTokens.opacityDisabled),
      fontSize: DesignTokens.bodyMedium,
      fontWeight: DesignTokens.fontWeightRegular,
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: DesignTokens.headlineLarge,
      fontWeight: DesignTokens.fontWeightBold,
      color: DesignTokens.pureBlack,
      height: DesignTokens.headlineHeight,
    ),
    displayMedium: TextStyle(
      fontSize: DesignTokens.headlineMedium,
      fontWeight: DesignTokens.fontWeightBold,
      color: DesignTokens.pureBlack,
      height: DesignTokens.headlineHeight,
    ),
    displaySmall: TextStyle(
      fontSize: DesignTokens.headlineSmall,
      fontWeight: DesignTokens.fontWeightBold,
      color: DesignTokens.pureBlack,
      height: DesignTokens.headlineHeight,
    ),
    bodyLarge: TextStyle(
      fontSize: DesignTokens.bodyLarge,
      fontWeight: DesignTokens.fontWeightRegular,
      color: DesignTokens.pureBlack,
      height: DesignTokens.bodyHeight,
    ),
    bodyMedium: TextStyle(
      fontSize: DesignTokens.bodyMedium,
      fontWeight: DesignTokens.fontWeightRegular,
      color: DesignTokens.pureBlack,
      height: DesignTokens.bodyHeight,
    ),
    labelLarge: TextStyle(
      fontSize: DesignTokens.bodyMedium,
      fontWeight: DesignTokens.fontWeightMedium,
      color: DesignTokens.pureBlack,
      height: DesignTokens.captionHeight,
    ),
    labelMedium: TextStyle(
      fontSize: DesignTokens.captionSize,
      fontWeight: DesignTokens.fontWeightLight,
      color: Color.fromRGBO(0, 0, 0, DesignTokens.opacitySubtle),
      height: DesignTokens.captionHeight,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: DesignTokens.vibrantCoral,
      foregroundColor: DesignTokens.trueWhite,
      elevation: DesignTokens.elevationNone,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceMD,
        vertical: DesignTokens.spaceSM,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
      ),
      textStyle: const TextStyle(
        fontSize: DesignTokens.bodyMedium,
        fontWeight: DesignTokens.fontWeightMedium,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: DesignTokens.vibrantCoral,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceSM,
        vertical: DesignTokens.spaceXS,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
      ),
      textStyle: const TextStyle(
        fontSize: DesignTokens.bodyMedium,
        fontWeight: DesignTokens.fontWeightMedium,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: DesignTokens.pureBlack,
      side: const BorderSide(color: DesignTokens.softGray, width: DesignTokens.borderWidthThin),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceMD,
        vertical: DesignTokens.spaceSM,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
      ),
      textStyle: const TextStyle(
        fontSize: DesignTokens.bodyMedium,
        fontWeight: DesignTokens.fontWeightMedium,
      ),
    ),
  ),
  cardTheme: CardThemeData(
    color: DesignTokens.softGray,
    elevation: DesignTokens.elevationNone,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
    ),
    margin: EdgeInsets.zero,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: DesignTokens.trueWhite,
    elevation: DesignTokens.elevationNone,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
    ),
    titleTextStyle: const TextStyle(
      fontSize: DesignTokens.headlineSmall,
      fontWeight: DesignTokens.fontWeightBold,
      color: DesignTokens.pureBlack,
    ),
    contentTextStyle: const TextStyle(
      fontSize: DesignTokens.bodyMedium,
      fontWeight: DesignTokens.fontWeightRegular,
      color: DesignTokens.pureBlack,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: DesignTokens.trueWhite,
    foregroundColor: DesignTokens.pureBlack,
    elevation: DesignTokens.elevationNone,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: DesignTokens.headlineSmall,
      fontWeight: DesignTokens.fontWeightBold,
      color: DesignTokens.pureBlack,
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return DesignTokens.vibrantCoral;
      }
      return DesignTokens.vibrantCoral; // Using vibrant coral for better visibility in light mode
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Color.fromRGBO(245, 80, 54, DesignTokens.opacityFaint);
      }
      return DesignTokens.softGray;
    }),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return DesignTokens.vibrantCoral;
      }
      return DesignTokens.softGray;
    }),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusSM / 2),
    ),
  ),
  iconTheme: const IconThemeData(
    color: DesignTokens.pureBlack,
    size: 24,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: DesignTokens.pureBlack,
    contentTextStyle: const TextStyle(color: DesignTokens.trueWhite),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
    ),
  ),
);
