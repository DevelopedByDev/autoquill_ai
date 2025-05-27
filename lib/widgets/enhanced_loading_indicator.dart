import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';

enum LoadingSize {
  small,
  medium,
  large,
}

enum LoadingType {
  circular,
  dots,
  pulsing,
  gradient,
}

class EnhancedLoadingIndicator extends StatefulWidget {
  final LoadingSize size;
  final LoadingType type;
  final Color? color;
  final LinearGradient? gradient;
  final String? message;

  const EnhancedLoadingIndicator({
    super.key,
    this.size = LoadingSize.medium,
    this.type = LoadingType.circular,
    this.color,
    this.gradient,
    this.message,
  });

  @override
  State<EnhancedLoadingIndicator> createState() =>
      _EnhancedLoadingIndicatorState();
}

class _EnhancedLoadingIndicatorState extends State<EnhancedLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _dotsController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _dotsAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: DesignTokens.durationLong,
      vsync: this,
    );

    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _dotsAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _dotsController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
  }

  void _startAnimations() {
    switch (widget.type) {
      case LoadingType.circular:
      case LoadingType.gradient:
        _rotationController.repeat();
        break;
      case LoadingType.pulsing:
        _pulseController.repeat(reverse: true);
        break;
      case LoadingType.dots:
        _dotsController.repeat();
        break;
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  double _getSize() {
    switch (widget.size) {
      case LoadingSize.small:
        return 20.0;
      case LoadingSize.medium:
        return 32.0;
      case LoadingSize.large:
        return 48.0;
    }
  }

  Color _getColor(bool isDarkMode) {
    if (widget.color != null) return widget.color!;
    return isDarkMode ? DesignTokens.trueWhite : DesignTokens.vibrantCoral;
  }

  Widget _buildCircularIndicator(bool isDarkMode) {
    return SizedBox(
      width: _getSize(),
      height: _getSize(),
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(_getColor(isDarkMode)),
      ),
    );
  }

  Widget _buildGradientIndicator() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 2 * 3.14159,
          child: Container(
            width: _getSize(),
            height: _getSize(),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: widget.gradient ?? DesignTokens.coralGradient,
            ),
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.gradient ?? DesignTokens.coralGradient,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulsingIndicator(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: _getSize(),
            height: _getSize(),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getColor(isDarkMode).withValues(alpha: 0.7),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDotsIndicator(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _dotsAnimation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: _dotsController,
              curve: Interval(delay, delay + 0.4, curve: Curves.easeInOut),
            ));

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Transform.translate(
                    offset: Offset(0, -10 * animation.value),
                    child: Container(
                      width: _getSize() / 4,
                      height: _getSize() / 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getColor(isDarkMode),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Widget indicator;

    switch (widget.type) {
      case LoadingType.circular:
        indicator = _buildCircularIndicator(isDarkMode);
        break;
      case LoadingType.gradient:
        indicator = _buildGradientIndicator();
        break;
      case LoadingType.pulsing:
        indicator = _buildPulsingIndicator(isDarkMode);
        break;
      case LoadingType.dots:
        indicator = _buildDotsIndicator(isDarkMode);
        break;
    }

    if (widget.message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(height: DesignTokens.spaceSM),
          Text(
            widget.message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? DesignTokens.trueWhite.withValues(alpha: 0.7)
                      : DesignTokens.pureBlack.withValues(alpha: 0.6),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return indicator;
  }
}
