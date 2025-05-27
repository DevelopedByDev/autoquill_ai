import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';

enum ButtonVariant {
  primary,
  secondary,
  outlined,
  text,
  danger,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class EnhancedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final LinearGradient? customGradient;
  final Color? customColor;

  const EnhancedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.customGradient,
    this.customColor,
  });

  @override
  State<EnhancedButton> createState() => _EnhancedButtonState();
}

class _EnhancedButtonState extends State<EnhancedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.durationShort,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceSM,
          vertical: DesignTokens.spaceXS,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceLG,
          vertical: DesignTokens.spaceSM,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceXL,
          vertical: DesignTokens.spaceMD,
        );
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return DesignTokens.captionSize;
      case ButtonSize.medium:
        return DesignTokens.bodyMedium;
      case ButtonSize.large:
        return DesignTokens.bodyLarge;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return DesignTokens.iconSizeXS;
      case ButtonSize.medium:
        return DesignTokens.iconSizeSM;
      case ButtonSize.large:
        return DesignTokens.iconSizeMD;
    }
  }

  LinearGradient _getGradient(bool isDarkMode) {
    if (widget.customGradient != null) {
      return widget.customGradient!;
    }

    switch (widget.variant) {
      case ButtonVariant.primary:
        return DesignTokens.coralGradient;
      case ButtonVariant.secondary:
        return DesignTokens.blueGradient;
      case ButtonVariant.danger:
        return LinearGradient(
          colors: [
            DesignTokens.vibrantCoral,
            DesignTokens.warmOrange,
          ],
        );
      default:
        return DesignTokens.coralGradient;
    }
  }

  Color _getTextColor(bool isDarkMode) {
    switch (widget.variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
      case ButtonVariant.danger:
        return DesignTokens.trueWhite;
      case ButtonVariant.outlined:
        return widget.customColor ??
            (isDarkMode ? DesignTokens.trueWhite : DesignTokens.pureBlack);
      case ButtonVariant.text:
        return widget.customColor ?? DesignTokens.vibrantCoral;
    }
  }

  Color _getBackgroundColor(bool isDarkMode) {
    switch (widget.variant) {
      case ButtonVariant.outlined:
        return Colors.transparent;
      case ButtonVariant.text:
        return Colors.transparent;
      default:
        return Colors.transparent; // Gradient will handle this
    }
  }

  Border? _getBorder(bool isDarkMode) {
    switch (widget.variant) {
      case ButtonVariant.outlined:
        return Border.all(
          color: widget.customColor ??
              (isDarkMode
                  ? DesignTokens.darkDivider
                  : DesignTokens.lightDivider),
          width: DesignTokens.borderWidthMedium,
        );
      default:
        return null;
    }
  }

  List<BoxShadow>? _getBoxShadow() {
    if (widget.onPressed == null || widget.isLoading) return null;

    switch (widget.variant) {
      case ButtonVariant.primary:
        return [
          BoxShadow(
            color: DesignTokens.vibrantCoral.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
      case ButtonVariant.secondary:
        return [
          BoxShadow(
            color: DesignTokens.deepBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
      case ButtonVariant.danger:
        return [
          BoxShadow(
            color: DesignTokens.vibrantCoral.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: isEnabled
                ? (_) {
                    setState(() => _isPressed = true);
                    _animationController.forward();
                  }
                : null,
            onTapUp: isEnabled
                ? (_) {
                    setState(() => _isPressed = false);
                    _animationController.reverse();
                  }
                : null,
            onTapCancel: isEnabled
                ? () {
                    setState(() => _isPressed = false);
                    _animationController.reverse();
                  }
                : null,
            child: Container(
              width: widget.fullWidth ? double.infinity : null,
              decoration: BoxDecoration(
                gradient: (widget.variant == ButtonVariant.primary ||
                            widget.variant == ButtonVariant.secondary ||
                            widget.variant == ButtonVariant.danger) &&
                        isEnabled
                    ? _getGradient(isDarkMode)
                    : null,
                color: _getBackgroundColor(isDarkMode),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
                border: _getBorder(isDarkMode),
                boxShadow: _getBoxShadow(),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled ? widget.onPressed : null,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
                  child: Container(
                    padding: _getPadding(),
                    child: Row(
                      mainAxisSize: widget.fullWidth
                          ? MainAxisSize.max
                          : MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isLoading)
                          SizedBox(
                            width: _getIconSize(),
                            height: _getIconSize(),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getTextColor(isDarkMode),
                              ),
                            ),
                          )
                        else if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: _getIconSize(),
                            color: isEnabled
                                ? _getTextColor(isDarkMode)
                                : _getTextColor(isDarkMode)
                                    .withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: DesignTokens.spaceXS),
                        ],
                        Text(
                          widget.text,
                          style: TextStyle(
                            fontSize: _getFontSize(),
                            fontWeight: DesignTokens.fontWeightSemiBold,
                            color: isEnabled
                                ? _getTextColor(isDarkMode)
                                : _getTextColor(isDarkMode)
                                    .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
