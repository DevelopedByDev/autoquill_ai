import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';

/// A minimalist toggle switch that follows the design system guidelines
class MinimalistToggle extends StatelessWidget {
  /// Whether the toggle is on
  final bool value;
  
  /// Callback when the toggle is changed
  final ValueChanged<bool>? onChanged;
  
  /// Whether the toggle is disabled
  final bool isDisabled;
  
  /// Optional custom active color
  final Color? activeColor;
  
  /// Optional custom track color
  final Color? trackColor;
  
  /// Optional custom thumb color
  final Color? thumbColor;
  
  /// Optional custom size (default is standard)
  final MinimalistToggleSize size;

  /// Optional label for the toggle
  final String? label;
  
  /// Optional description for the toggle
  final String? description;
  
  /// Whether the label should be placed on the left (default) or right
  final bool labelOnRight;

  const MinimalistToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.isDisabled = false,
    this.activeColor,
    this.trackColor,
    this.thumbColor,
    this.size = MinimalistToggleSize.standard,
    this.label,
    this.description,
    this.labelOnRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Determine colors based on state
    final effectiveActiveColor = activeColor ?? DesignTokens.vibrantCoral;
    final effectiveTrackColor = trackColor ?? (isDarkMode 
        ? DesignTokens.darkSurface 
        : DesignTokens.lightSurface);
    final effectiveThumbColor = thumbColor ?? DesignTokens.trueWhite;
    
    // Determine sizes based on toggle size
    final double width;
    final double height;
    final double thumbSize;
    
    switch (size) {
      case MinimalistToggleSize.small:
        width = 36.0;
        height = 20.0;
        thumbSize = 16.0;
        break;
      case MinimalistToggleSize.standard:
        width = 48.0;
        height = 24.0;
        thumbSize = 20.0;
        break;
      case MinimalistToggleSize.large:
        width = 60.0;
        height = 30.0;
        thumbSize = 26.0;
        break;
    }
    
    // Build the toggle switch
    final toggleSwitch = GestureDetector(
      onTap: isDisabled ? null : () => onChanged?.call(!value),
      child: AnimatedOpacity(
        duration: DesignTokens.durationShort,
        opacity: isDisabled ? DesignTokens.opacityDisabled : 1.0,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            color: value ? effectiveActiveColor : effectiveTrackColor,
            border: Border.all(
              color: value 
                  ? effectiveActiveColor 
                  : isDarkMode 
                      ? DesignTokens.darkDivider 
                      : DesignTokens.lightDivider,
              width: DesignTokens.borderWidthThin,
            ),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: DesignTokens.durationShort,
                curve: DesignTokens.defaultCurve,
                left: value ? width - thumbSize - 2 : 2,
                top: (height - thumbSize) / 2,
                child: Container(
                  width: thumbSize,
                  height: thumbSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: effectiveThumbColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    // If no label or description, just return the toggle
    if (label == null && description == null) {
      return toggleSwitch;
    }
    
    // Build the label and description
    final labelWidget = label != null 
        ? Text(
            label!,
            style: TextStyle(
              fontSize: DesignTokens.bodyMedium,
              fontWeight: DesignTokens.fontWeightMedium,
              color: isDisabled 
                  ? Theme.of(context).colorScheme.onSurface.withOpacity(DesignTokens.opacityDisabled)
                  : Theme.of(context).colorScheme.onSurface,
            ),
          )
        : null;
    
    final descriptionWidget = description != null 
        ? Text(
            description!,
            style: TextStyle(
              fontSize: DesignTokens.captionSize,
              color: isDisabled 
                  ? Theme.of(context).colorScheme.onSurface.withOpacity(DesignTokens.opacityDisabled)
                  : Theme.of(context).colorScheme.onSurface.withOpacity(DesignTokens.opacitySubtle),
            ),
          )
        : null;
    
    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelWidget != null) labelWidget,
        if (labelWidget != null && descriptionWidget != null) 
          const SizedBox(height: DesignTokens.spaceXXS),
        if (descriptionWidget != null) descriptionWidget,
      ],
    );
    
    // Build the final layout with label/description and toggle
    return GestureDetector(
      onTap: isDisabled ? null : () => onChanged?.call(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: labelOnRight
            ? [
                toggleSwitch,
                const SizedBox(width: DesignTokens.spaceSM),
                Flexible(child: textColumn),
              ]
            : [
                Flexible(child: textColumn),
                const SizedBox(width: DesignTokens.spaceSM),
                toggleSwitch,
              ],
      ),
    );
  }
}

/// Size options for the minimalist toggle
enum MinimalistToggleSize {
  /// Small toggle (36x20)
  small,
  
  /// Standard toggle (48x24)
  standard,
  
  /// Large toggle (60x30)
  large,
}
