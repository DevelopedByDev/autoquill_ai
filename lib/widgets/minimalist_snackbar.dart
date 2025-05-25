import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';

/// The type of snackbar to display
enum MinimalistSnackbarType {
  /// Success snackbar (green)
  success,
  
  /// Info snackbar (blue)
  info,
  
  /// Warning snackbar (orange)
  warning,
  
  /// Error snackbar (red)
  error,
}

/// A minimalist snackbar that follows the design system guidelines
class MinimalistSnackbar extends SnackBar {
  MinimalistSnackbar._({
    required String message,
    MinimalistSnackbarType type = MinimalistSnackbarType.info,
    IconData? icon,
    super.duration,
    super.action,
  }) : super(
    content: _SnackbarContent(
      message: message,
      type: type,
      icon: icon,
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    padding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
    ),
  );
  
  /// Shows a success snackbar
  static void showSuccess(
    BuildContext context, {
    required String message,
    IconData icon = Icons.check_circle,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      MinimalistSnackbar._(
        message: message,
        type: MinimalistSnackbarType.success,
        icon: icon,
        duration: duration,
        action: action,
      ),
    );
  }
  
  /// Shows an info snackbar
  static void showInfo(
    BuildContext context, {
    required String message,
    IconData icon = Icons.info,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      MinimalistSnackbar._(
        message: message,
        type: MinimalistSnackbarType.info,
        icon: icon,
        duration: duration,
        action: action,
      ),
    );
  }
  
  /// Shows a warning snackbar
  static void showWarning(
    BuildContext context, {
    required String message,
    IconData icon = Icons.warning,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      MinimalistSnackbar._(
        message: message,
        type: MinimalistSnackbarType.warning,
        icon: icon,
        duration: duration,
        action: action,
      ),
    );
  }
  
  /// Shows an error snackbar
  static void showError(
    BuildContext context, {
    required String message,
    IconData icon = Icons.error,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      MinimalistSnackbar._(
        message: message,
        type: MinimalistSnackbarType.error,
        icon: icon,
        duration: duration,
        action: action,
      ),
    );
  }
}

class _SnackbarContent extends StatelessWidget {
  final String message;
  final MinimalistSnackbarType type;
  final IconData? icon;

  const _SnackbarContent({
    required this.message,
    required this.type,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Determine colors based on type
    final Color backgroundColor;
    final Color textColor;
    final Color iconColor;
    
    switch (type) {
      case MinimalistSnackbarType.success:
        backgroundColor = isDarkMode 
            ? const Color(0xFF0D5F3F) // Dark green
            : const Color(0xFFE6F7EF); // Light green
        textColor = isDarkMode 
            ? Colors.white 
            : const Color(0xFF0D5F3F);
        iconColor = const Color(0xFF10B981); // Emerald
        break;
      case MinimalistSnackbarType.info:
        backgroundColor = isDarkMode 
            ? const Color(0xFF1E3A8A) // Dark blue
            : const Color(0xFFE6F0FF); // Light blue
        textColor = isDarkMode 
            ? Colors.white 
            : const Color(0xFF1E3A8A);
        iconColor = DesignTokens.vibrantCoral;
        break;
      case MinimalistSnackbarType.warning:
        backgroundColor = isDarkMode 
            ? const Color(0xFF7C2D12) // Dark orange
            : const Color(0xFFFEF3C7); // Light yellow
        textColor = isDarkMode 
            ? Colors.white 
            : const Color(0xFF7C2D12);
        iconColor = const Color(0xFFF97316); // Orange
        break;
      case MinimalistSnackbarType.error:
        backgroundColor = isDarkMode 
            ? const Color(0xFF7F1D1D) // Dark red
            : const Color(0xFFFEE2E2); // Light red
        textColor = isDarkMode 
            ? Colors.white 
            : const Color(0xFF7F1D1D);
        iconColor = const Color(0xFFEF4444); // Red
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceMD,
        vertical: DesignTokens.spaceSM,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            const SizedBox(width: DesignTokens.spaceSM),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: DesignTokens.bodyMedium,
                fontWeight: DesignTokens.fontWeightMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
