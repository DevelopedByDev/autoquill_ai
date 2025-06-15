import 'package:flutter/material.dart';

/// Design tokens for the minimalist design system
class DesignTokens {
  // Primary Colors
  static const vibrantCoral = Color(0xFFF55036);
  static const trueWhite = Color(0xFFFFFFFF);
  static const softGray = Color(0xFFF3F3F3);
  static const pureBlack = Color(0xFF000000);

  // Enhanced Color Palette
  static const deepBlue = Color(0xFF2563EB);
  static const emeraldGreen = Color(0xFF10B981);
  static const goldenYellow = Color(0xFFF59E0B);
  static const purpleViolet = Color(0xFF8B5CF6);
  static const warmOrange = Color(0xFFEA580C);

  // Subtle accent colors
  static const lightCoral = Color(0xFFFFE8E5);
  static const lightBlue = Color(0xFFEFF6FF);
  static const lightGreen = Color(0xFFECFDF5);
  static const lightYellow = Color(0xFFFEF3C7);
  static const lightPurple = Color(0xFFF3E8FF);

  // Dark mode surface colors
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkSurfaceVariant = Color(0xFF262626);
  static const darkSurfaceElevated = Color(0xFF2A2A2A);
  static const darkDivider = Color(0xFF333333);

  // Light mode surface colors
  static const lightSurface = softGray;
  static const lightSurfaceVariant = Color(0xFFF9FAFB);
  static const lightSurfaceElevated = trueWhite;
  static const lightDivider = Color(0xFFE0E0E0);

  // Gradients
  static const coralGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF55036), Color(0xFFFF6B4A)],
  );

  static const blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
  );

  static const greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
  );

  
  static const yellowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
  );

  static const orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEA580C), Color(0xFFFB923C)],
  );

  static const tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF14B8A6), Color(0xFF2DD4BF)],
  );

  static const indigoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
  );

  static const roseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE11D48), Color(0xFFF43F5E)],
  );

  static const purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
  );

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAFAFA), Color(0xFFF0F0F0)],
  );

  static const darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0A0A), Color(0xFF000000)],
  );

  // Opacity values
  static const opacityDisabled = 0.5;
  static const opacitySubtle = 0.7;
  static const opacityFaint = 0.3;
  static const opacityVeryFaint = 0.1;

  // Typography - Font Sizes
  static const headlineLarge = 32.0;
  static const headlineMedium = 28.0;
  static const headlineSmall = 24.0;
  static const titleLarge = 20.0;
  static const titleMedium = 18.0;
  static const bodyLarge = 16.0;
  static const bodyMedium = 14.0;
  static const captionSize = 12.0;
  static const overlineSize = 10.0;

  // Typography - Font Weights
  static const fontWeightBold = FontWeight.w700;
  static const fontWeightSemiBold = FontWeight.w600;
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
  static const spaceXXXL = 64.0;

  // Radii
  static const radiusXS = 4.0;
  static const radiusSM = 8.0;
  static const radiusMD = 16.0;
  static const radiusLG = 24.0;
  static const radiusXL = 32.0;

  // Animation Durations
  static const durationShort = Duration(milliseconds: 150);
  static const durationMedium = Duration(milliseconds: 300);
  static const durationLong = Duration(milliseconds: 500);
  static const durationExtraLong = Duration(milliseconds: 750);

  // Animation Curves
  static const defaultCurve = Curves.easeInOut;
  static const emphasizedCurve = Curves.fastOutSlowIn;
  static const springCurve = Curves.elasticOut;

  // Elevation
  static const elevationNone = 0.0;
  static const elevationLow = 1.0;
  static const elevationMedium = 2.0;
  static const elevationHigh = 4.0;
  static const elevationHighest = 8.0;

  // Shadow definitions
  static List<BoxShadow> getShadow(double elevation, {bool isDark = false}) {
    final baseColor = isDark ? Colors.black : Colors.black;
    return [
      BoxShadow(
        color: baseColor.withValues(alpha: isDark ? 0.3 : 0.1),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation / 2),
      ),
      BoxShadow(
        color: baseColor.withValues(alpha: isDark ? 0.15 : 0.05),
        blurRadius: elevation,
        offset: Offset(0, elevation),
      ),
    ];
  }

  // Card shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> cardShadowDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 8,
      offset: const Offset(0, 3),
    ),
  ];

  // Border width
  static const borderWidthThin = 1.0;
  static const borderWidthMedium = 2.0;
  static const borderWidthThick = 3.0;

  // Icon sizes
  static const iconSizeXS = 16.0;
  static const iconSizeSM = 20.0;
  static const iconSizeMD = 24.0;
  static const iconSizeLG = 32.0;
  static const iconSizeXL = 48.0;
}
