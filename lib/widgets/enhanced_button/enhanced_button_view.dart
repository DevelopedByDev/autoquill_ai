import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/design_tokens.dart';
import 'bloc/enhanced_button_bloc_barrel.dart';

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

class EnhancedButton extends StatelessWidget {
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

  EdgeInsets _getPadding() {
    switch (size) {
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
    switch (size) {
      case ButtonSize.small:
        return DesignTokens.captionSize;
      case ButtonSize.medium:
        return DesignTokens.bodyMedium;
      case ButtonSize.large:
        return DesignTokens.bodyLarge;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return DesignTokens.iconSizeXS;
      case ButtonSize.medium:
        return DesignTokens.iconSizeSM;
      case ButtonSize.large:
        return DesignTokens.iconSizeMD;
    }
  }

  LinearGradient _getGradient(bool isDarkMode) {
    if (customGradient != null) {
      return customGradient!;
    }

    switch (variant) {
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
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
      case ButtonVariant.danger:
        return DesignTokens.trueWhite;
      case ButtonVariant.outlined:
        return customColor ??
            (isDarkMode ? DesignTokens.trueWhite : DesignTokens.pureBlack);
      case ButtonVariant.text:
        return customColor ?? DesignTokens.vibrantCoral;
    }
  }

  Color _getBackgroundColor(bool isDarkMode) {
    switch (variant) {
      case ButtonVariant.outlined:
        return Colors.transparent;
      case ButtonVariant.text:
        return Colors.transparent;
      default:
        return Colors.transparent; // Gradient will handle this
    }
  }

  Border? _getBorder(bool isDarkMode) {
    switch (variant) {
      case ButtonVariant.outlined:
        return Border.all(
          color: customColor ??
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
    if (onPressed == null || isLoading) return null;

    switch (variant) {
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
    return BlocProvider(
      create: (context) => EnhancedButtonBloc(
        animationController: AnimationController(
          vsync: Scaffold.of(context),
          duration: DesignTokens.durationShort,
        ),
      ),
      child: _EnhancedButtonView(
        text: text,
        onPressed: onPressed,
        variant: variant,
        size: size,
        icon: icon,
        isLoading: isLoading,
        fullWidth: fullWidth,
        customGradient: customGradient,
        customColor: customColor,
        getPadding: _getPadding,
        getFontSize: _getFontSize,
        getIconSize: _getIconSize,
        getGradient: _getGradient,
        getTextColor: _getTextColor,
        getBackgroundColor: _getBackgroundColor,
        getBorder: _getBorder,
        getBoxShadow: _getBoxShadow,
      ),
    );
  }
}

class _EnhancedButtonView extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final LinearGradient? customGradient;
  final Color? customColor;
  final EdgeInsets Function() getPadding;
  final double Function() getFontSize;
  final double Function() getIconSize;
  final LinearGradient Function(bool) getGradient;
  final Color Function(bool) getTextColor;
  final Color Function(bool) getBackgroundColor;
  final Border? Function(bool) getBorder;
  final List<BoxShadow>? Function() getBoxShadow;

  const _EnhancedButtonView({
    required this.text,
    required this.onPressed,
    required this.variant,
    required this.size,
    required this.icon,
    required this.isLoading,
    required this.fullWidth,
    required this.customGradient,
    required this.customColor,
    required this.getPadding,
    required this.getFontSize,
    required this.getIconSize,
    required this.getGradient,
    required this.getTextColor,
    required this.getBackgroundColor,
    required this.getBorder,
    required this.getBoxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = onPressed != null && !isLoading;
    final bloc = context.read<EnhancedButtonBloc>();

    return BlocBuilder<EnhancedButtonBloc, EnhancedButtonState>(
      builder: (context, state) {
        return AnimatedBuilder(
          animation: bloc.animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: state.scale,
              child: GestureDetector(
                onTapDown: isEnabled
                    ? (_) => bloc.add(const EnhancedButtonPressed())
                    : null,
                onTapUp: isEnabled
                    ? (_) => bloc.add(const EnhancedButtonReleased())
                    : null,
                onTapCancel: isEnabled
                    ? () => bloc.add(const EnhancedButtonCancelled())
                    : null,
                child: Container(
                  width: fullWidth ? double.infinity : null,
                  decoration: BoxDecoration(
                    gradient: (variant == ButtonVariant.primary ||
                                variant == ButtonVariant.secondary ||
                                variant == ButtonVariant.danger) &&
                            isEnabled
                        ? getGradient(isDarkMode)
                        : null,
                    color: getBackgroundColor(isDarkMode),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
                    border: getBorder(isDarkMode),
                    boxShadow: getBoxShadow(),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isEnabled ? onPressed : null,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
                      child: Container(
                        padding: getPadding(),
                        child: Row(
                          mainAxisSize: fullWidth
                              ? MainAxisSize.max
                              : MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isLoading)
                              SizedBox(
                                width: getIconSize(),
                                height: getIconSize(),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    getTextColor(isDarkMode),
                                  ),
                                ),
                              )
                            else if (icon != null) ...[
                              Icon(
                                icon,
                                size: getIconSize(),
                                color: isEnabled
                                    ? getTextColor(isDarkMode)
                                    : getTextColor(isDarkMode)
                                        .withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: DesignTokens.spaceXS),
                            ],
                            Text(
                              text,
                              style: TextStyle(
                                fontSize: getFontSize(),
                                fontWeight: DesignTokens.fontWeightSemiBold,
                                color: isEnabled
                                    ? getTextColor(isDarkMode)
                                    : getTextColor(isDarkMode)
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
      },
    );
  }
}
