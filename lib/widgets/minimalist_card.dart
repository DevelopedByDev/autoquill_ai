import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';

/// A minimalist card widget that follows the design system guidelines
class MinimalistCard extends StatelessWidget {
  /// The child widget to display inside the card
  final Widget child;
  
  /// Whether the card is interactive (has hover/press states)
  final bool interactive;
  
  /// Whether the card is selected/active
  final bool selected;
  
  /// Optional padding override (defaults to spaceSM)
  final EdgeInsetsGeometry? padding;
  
  /// Optional border radius override (defaults to radiusMD)
  final double? borderRadius;
  
  /// Optional background color override
  final Color? backgroundColor;
  
  /// Optional border color override
  final Color? borderColor;
  
  /// Optional elevation override (defaults to elevationNone)
  final double? elevation;
  
  /// Optional callback when the card is tapped (makes the card interactive)
  final VoidCallback? onTap;

  const MinimalistCard({
    super.key,
    required this.child,
    this.interactive = false,
    this.selected = false,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final defaultBackground = isDarkMode ? DesignTokens.darkSurface : DesignTokens.lightSurface;
    
    return AnimatedContainer(
      duration: DesignTokens.durationMedium,
      curve: DesignTokens.defaultCurve,
      padding: padding ?? const EdgeInsets.all(DesignTokens.spaceSM),
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBackground,
        borderRadius: BorderRadius.circular(borderRadius ?? DesignTokens.radiusMD),
        border: Border.all(
          color: borderColor ?? (selected 
              ? DesignTokens.vibrantCoral 
              : Colors.transparent),
          width: selected ? DesignTokens.borderWidthMedium : 0,
        ),
        boxShadow: elevation != null && elevation! > 0 
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: elevation! * 4,
                  offset: Offset(0, elevation!),
                ),
              ] 
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? DesignTokens.radiusMD),
          splashColor: interactive 
              ? DesignTokens.vibrantCoral.withOpacity(0.1) 
              : Colors.transparent,
          highlightColor: interactive 
              ? DesignTokens.vibrantCoral.withOpacity(0.05) 
              : Colors.transparent,
          hoverColor: interactive 
              ? DesignTokens.vibrantCoral.withOpacity(0.05) 
              : Colors.transparent,
          child: child,
        ),
      ),
    );
  }
}
