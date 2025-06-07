import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/design_tokens.dart';
import 'bloc/enhanced_loading_indicator_bloc_barrel.dart';

enum LoadingSize {
  small,
  medium,
  large,
}

class EnhancedLoadingIndicator extends StatelessWidget {
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

  double _getSize() {
    switch (size) {
      case LoadingSize.small:
        return 20.0;
      case LoadingSize.medium:
        return 32.0;
      case LoadingSize.large:
        return 48.0;
    }
  }

  Color _getColor(bool isDarkMode) {
    if (color != null) return color!;
    return isDarkMode ? DesignTokens.trueWhite : DesignTokens.vibrantCoral;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EnhancedLoadingIndicatorBloc(
        rotationController: AnimationController(vsync: Scaffold.of(context)),
        pulseController: AnimationController(vsync: Scaffold.of(context)),
        dotsController: AnimationController(vsync: Scaffold.of(context)),
        initialType: type,
      ),
      child: _EnhancedLoadingIndicatorView(
        size: size,
        type: type,
        color: color,
        gradient: gradient,
        message: message,
        getSize: _getSize,
        getColor: _getColor,
      ),
    );
  }
}

class _EnhancedLoadingIndicatorView extends StatelessWidget {
  final LoadingSize size;
  final LoadingType type;
  final Color? color;
  final LinearGradient? gradient;
  final String? message;
  final double Function() getSize;
  final Color Function(bool) getColor;

  const _EnhancedLoadingIndicatorView({
    required this.size,
    required this.type,
    required this.color,
    required this.gradient,
    required this.message,
    required this.getSize,
    required this.getColor,
  });

  Widget _buildCircularIndicator(bool isDarkMode) {
    return SizedBox(
      width: getSize(),
      height: getSize(),
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(getColor(isDarkMode)),
      ),
    );
  }

  Widget _buildGradientIndicator(BuildContext context, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: animation.value * 2 * 3.14159,
          child: Container(
            width: getSize(),
            height: getSize(),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: gradient ?? DesignTokens.coralGradient,
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
                  gradient: gradient ?? DesignTokens.coralGradient,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulsingIndicator(bool isDarkMode, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Container(
            width: getSize(),
            height: getSize(),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: getColor(isDarkMode).withValues(alpha: 0.7),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDotsIndicator(bool isDarkMode, Animation<double> animation, AnimationController controller) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final dotAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Interval(delay, delay + 0.4, curve: Curves.easeInOut),
            ));

            return AnimatedBuilder(
              animation: dotAnimation,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Transform.translate(
                    offset: Offset(0, -10 * dotAnimation.value),
                    child: Container(
                      width: getSize() / 4,
                      height: getSize() / 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: getColor(isDarkMode),
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
    final bloc = context.read<EnhancedLoadingIndicatorBloc>();

    return BlocBuilder<EnhancedLoadingIndicatorBloc, EnhancedLoadingIndicatorState>(
      builder: (context, state) {
        Widget indicator;

        switch (type) {
          case LoadingType.circular:
            indicator = _buildCircularIndicator(isDarkMode);
            break;
          case LoadingType.gradient:
            indicator = _buildGradientIndicator(context, bloc.rotationAnimation);
            break;
          case LoadingType.pulsing:
            indicator = _buildPulsingIndicator(isDarkMode, bloc.pulseAnimation);
            break;
          case LoadingType.dots:
            indicator = _buildDotsIndicator(isDarkMode, bloc.dotsAnimation, bloc.dotsController);
            break;
        }

        if (message != null) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              indicator,
              const SizedBox(height: DesignTokens.spaceSM),
              Text(
                message!,
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
      },
    );
  }
}
