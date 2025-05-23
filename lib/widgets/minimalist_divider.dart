import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';

/// A minimalist divider that follows the design system guidelines
class MinimalistDivider extends StatelessWidget {
  /// The thickness of the divider
  final double thickness;
  
  /// The color of the divider (defaults to theme-based divider color)
  final Color? color;
  
  /// The height of the divider including padding
  final double height;
  
  /// The indent on the left side
  final double indent;
  
  /// The indent on the right side
  final double endIndent;
  
  /// Whether the divider is vertical
  final bool vertical;

  const MinimalistDivider({
    super.key,
    this.thickness = 1.0,
    this.color,
    this.height = 16.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
    this.vertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = color ?? (isDarkMode 
        ? DesignTokens.darkDivider 
        : DesignTokens.lightDivider);
    
    if (vertical) {
      return Container(
        width: thickness,
        margin: EdgeInsets.only(
          left: indent,
          right: endIndent,
        ),
        height: height,
        color: dividerColor,
      );
    }
    
    return Container(
      height: thickness,
      margin: EdgeInsets.only(
        top: (height - thickness) / 2,
        bottom: (height - thickness) / 2,
        left: indent,
        right: endIndent,
      ),
      color: dividerColor,
    );
  }
}
