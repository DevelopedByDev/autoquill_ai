import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';

/// Button variants for the minimalist design system
enum MinimalistButtonVariant {
  /// Primary button with solid background
  primary,
  
  /// Secondary button with outlined style
  secondary,
  
  /// Tertiary button with minimal styling
  tertiary,
  
  /// Icon-only button
  icon,
}

/// A minimalist button that follows the design system guidelines
class MinimalistButton extends StatelessWidget {
  /// The text to display on the button
  final String? label;
  
  /// The icon to display on the button (optional)
  final IconData? icon;
  
  /// The button variant
  final MinimalistButtonVariant variant;
  
  /// Whether the button is in a loading state
  final bool isLoading;
  
  /// Whether the button is disabled
  final bool isDisabled;
  
  /// The callback when the button is pressed
  final VoidCallback? onPressed;
  
  /// Optional custom background color
  final Color? backgroundColor;
  
  /// Optional custom text color
  final Color? textColor;
  
  /// Optional custom border color
  final Color? borderColor;
  
  /// Optional custom padding
  final EdgeInsetsGeometry? padding;
  
  /// Optional custom border radius
  final double? borderRadius;

  const MinimalistButton({
    super.key,
    this.label,
    this.icon,
    this.variant = MinimalistButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.padding,
    this.borderRadius,
  }) : assert(label != null || icon != null, 'Either label or icon must be provided');

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Determine colors based on variant and state
    Color bgColor;
    Color fgColor;
    Color? bdColor;
    
    switch (variant) {
      case MinimalistButtonVariant.primary:
        bgColor = backgroundColor ?? DesignTokens.vibrantCoral;
        fgColor = textColor ?? DesignTokens.trueWhite;
        bdColor = borderColor;
        break;
      case MinimalistButtonVariant.secondary:
        bgColor = Colors.transparent;
        fgColor = textColor ?? DesignTokens.vibrantCoral;
        bdColor = borderColor ?? DesignTokens.vibrantCoral;
        break;
      case MinimalistButtonVariant.tertiary:
        bgColor = Colors.transparent;
        fgColor = textColor ?? DesignTokens.vibrantCoral;
        bdColor = Colors.transparent;
        break;
      case MinimalistButtonVariant.icon:
        bgColor = Colors.transparent;
        fgColor = textColor ?? (isDarkMode ? DesignTokens.trueWhite : DesignTokens.pureBlack);
        bdColor = Colors.transparent;
        break;
    }
    
    // Apply disabled state
    if (isDisabled) {
      bgColor = bgColor.withValues(alpha: DesignTokens.opacityDisabled);
      fgColor = fgColor.withValues(alpha: DesignTokens.opacityDisabled);
      if (bdColor != null) {
        bdColor = bdColor.withValues(alpha: DesignTokens.opacityDisabled);
      }
    }
    
    // Determine padding based on variant
    final buttonPadding = padding ?? _getDefaultPadding();
    
    // Build the button content
    Widget buttonContent;
    
    if (isLoading) {
      buttonContent = SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(fgColor),
        ),
      );
    } else if (variant == MinimalistButtonVariant.icon) {
      buttonContent = Icon(icon, color: fgColor);
    } else if (icon != null && label != null) {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: fgColor),
          const SizedBox(width: DesignTokens.spaceXS),
          Text(
            label!,
            style: TextStyle(
              color: fgColor,
              fontSize: DesignTokens.bodyMedium,
              fontWeight: DesignTokens.fontWeightMedium,
            ),
          ),
        ],
      );
    } else if (icon != null) {
      buttonContent = Icon(icon, color: fgColor);
    } else {
      buttonContent = Text(
        label!,
        style: TextStyle(
          color: fgColor,
          fontSize: DesignTokens.bodyMedium,
          fontWeight: DesignTokens.fontWeightMedium,
        ),
      );
    }
    
    return AnimatedContainer(
      duration: DesignTokens.durationShort,
      curve: DesignTokens.defaultCurve,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius ?? DesignTokens.radiusMD),
        border: bdColor != null ? Border.all(color: bdColor, width: 1) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled || isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius ?? DesignTokens.radiusMD),
          splashColor: variant != MinimalistButtonVariant.tertiary && variant != MinimalistButtonVariant.icon
              ? fgColor.withValues(alpha: 0.1)
              : DesignTokens.vibrantCoral.withValues(alpha: 0.1),
          highlightColor: variant != MinimalistButtonVariant.tertiary && variant != MinimalistButtonVariant.icon
              ? fgColor.withValues(alpha: 0.05)
              : DesignTokens.vibrantCoral.withValues(alpha: 0.05),
          child: Padding(
            padding: buttonPadding,
            child: Center(child: buttonContent),
          ),
        ),
      ),
    );
  }
  
  EdgeInsetsGeometry _getDefaultPadding() {
    switch (variant) {
      case MinimalistButtonVariant.primary:
      case MinimalistButtonVariant.secondary:
        return const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceMD,
          vertical: DesignTokens.spaceSM,
        );
      case MinimalistButtonVariant.tertiary:
        return const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceSM,
          vertical: DesignTokens.spaceXS,
        );
      case MinimalistButtonVariant.icon:
        return const EdgeInsets.all(DesignTokens.spaceSM);
    }
  }
}
