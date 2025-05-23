import 'package:flutter/material.dart';

/// Design tokens for the minimalist design system
class DesignTokens {
  // Colors
  static const vibrantCoral = Color(0xFFF55036);
  static const trueWhite = Color(0xFFFFFFFF);
  static const softGray = Color(0xFFF3F3F3);
  static const pureBlack = Color(0xFF000000);
  
  // Dark mode surface colors
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkDivider = Color(0xFF333333);
  
  // Light mode surface colors
  static const lightSurface = softGray;
  static const lightDivider = Color(0xFFE0E0E0);
  
  // Opacity values
  static const opacityDisabled = 0.5;
  static const opacitySubtle = 0.7;
  static const opacityFaint = 0.3;
  
  // Typography - Font Sizes
  static const headlineLarge = 32.0;
  static const headlineMedium = 28.0;
  static const headlineSmall = 24.0;
  static const bodyLarge = 16.0;
  static const bodyMedium = 14.0;
  static const captionSize = 12.0;
  
  // Typography - Font Weights
  static const fontWeightBold = FontWeight.w700;
  static const fontWeightMedium = FontWeight.w500;
  static const fontWeightRegular = FontWeight.w400;
  static const fontWeightLight = FontWeight.w300;
  
  // Typography - Line Heights
  static const headlineHeight = 1.2;
  static const bodyHeight = 1.5;
  static const captionHeight = 1.4;
  
  // Spacing (8pt grid system)
  static const spaceXXS = 4.0;
  static const spaceXS = 8.0;
  static const spaceSM = 16.0;
  static const spaceMD = 24.0;
  static const spaceLG = 32.0;
  static const spaceXL = 40.0;
  static const spaceXXL = 48.0;
  
  // Radii
  static const radiusSM = 8.0;
  static const radiusMD = 16.0;
  static const radiusLG = 24.0;
  
  // Animation Durations
  static const durationShort = Duration(milliseconds: 150);
  static const durationMedium = Duration(milliseconds: 300);
  static const durationLong = Duration(milliseconds: 500);
  
  // Animation Curves
  static const defaultCurve = Curves.easeInOut;
  static const emphasizedCurve = Curves.fastOutSlowIn;
  
  // Elevation
  static const elevationNone = 0.0;
  static const elevationLow = 1.0;
  static const elevationMedium = 2.0;
  
  // Border width
  static const borderWidthThin = 1.0;
  static const borderWidthMedium = 2.0;
}
