import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';
import 'minimalist_button.dart';

/// A minimalist dialog that follows the design system guidelines
class MinimalistDialog extends StatelessWidget {
  /// The title of the dialog
  final String title;
  
  /// The content of the dialog
  final Widget content;
  
  /// The primary action button text
  final String? primaryActionText;
  
  /// The secondary action button text
  final String? secondaryActionText;
  
  /// The callback for the primary action
  final VoidCallback? onPrimaryAction;
  
  /// The callback for the secondary action
  final VoidCallback? onSecondaryAction;
  
  /// Whether the primary action is in a loading state
  final bool isPrimaryActionLoading;
  
  /// Whether the primary action is destructive
  final bool isPrimaryActionDestructive;
  
  /// Optional width constraint for the dialog
  final double? width;
  
  /// Optional max width constraint for the dialog
  final double maxWidth;
  
  /// Optional custom padding for the dialog content
  final EdgeInsetsGeometry contentPadding;
  
  /// Optional icon to display in the header
  final IconData? icon;
  
  /// Optional color for the icon
  final Color? iconColor;

  const MinimalistDialog({
    super.key,
    required this.title,
    required this.content,
    this.primaryActionText,
    this.secondaryActionText,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.isPrimaryActionLoading = false,
    this.isPrimaryActionDestructive = false,
    this.width,
    this.maxWidth = 400,
    this.contentPadding = const EdgeInsets.all(DesignTokens.spaceMD),
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: width,
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? DesignTokens.pureBlack : DesignTokens.trueWhite,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _buildHeader(context),
            
            // Content
            Padding(
              padding: contentPadding,
              child: content,
            ),
            
            // Actions
            if (primaryActionText != null || secondaryActionText != null)
              _buildActions(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceMD),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DesignTokens.radiusMD),
          topRight: Radius.circular(DesignTokens.radiusMD),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor ?? DesignTokens.vibrantCoral,
              size: 24,
            ),
            const SizedBox(width: DesignTokens.spaceSM),
          ],
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: DesignTokens.fontWeightMedium,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
  
  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceMD),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (secondaryActionText != null)
            MinimalistButton(
              variant: MinimalistButtonVariant.secondary,
              label: secondaryActionText!,
              onPressed: onSecondaryAction ?? () => Navigator.of(context).pop(),
            ),
          if (secondaryActionText != null && primaryActionText != null)
            const SizedBox(width: DesignTokens.spaceSM),
          if (primaryActionText != null)
            MinimalistButton(
              variant: MinimalistButtonVariant.primary,
              label: primaryActionText!,
              isLoading: isPrimaryActionLoading,
              backgroundColor: isPrimaryActionDestructive 
                  ? Colors.red 
                  : null,
              onPressed: onPrimaryAction,
            ),
        ],
      ),
    );
  }
}

/// Shows a minimalist dialog with the given parameters
Future<T?> showMinimalistDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  String? primaryActionText,
  String? secondaryActionText,
  VoidCallback? onPrimaryAction,
  VoidCallback? onSecondaryAction,
  bool isPrimaryActionLoading = false,
  bool isPrimaryActionDestructive = false,
  double? width,
  double maxWidth = 400,
  EdgeInsetsGeometry contentPadding = const EdgeInsets.all(DesignTokens.spaceMD),
  IconData? icon,
  Color? iconColor,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => MinimalistDialog(
      title: title,
      content: content,
      primaryActionText: primaryActionText,
      secondaryActionText: secondaryActionText,
      onPrimaryAction: onPrimaryAction,
      onSecondaryAction: onSecondaryAction,
      isPrimaryActionLoading: isPrimaryActionLoading,
      isPrimaryActionDestructive: isPrimaryActionDestructive,
      width: width,
      maxWidth: maxWidth,
      contentPadding: contentPadding,
      icon: icon,
      iconColor: iconColor,
    ),
  );
}
