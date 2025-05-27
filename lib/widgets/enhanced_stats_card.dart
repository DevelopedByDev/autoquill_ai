import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';

class EnhancedStatsCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final LinearGradient gradient;
  final Color iconColor;
  final String? trend;
  final bool showAnimation;

  const EnhancedStatsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.gradient,
    required this.iconColor,
    this.trend,
    this.showAnimation = true,
  });

  @override
  State<EnhancedStatsCard> createState() => _EnhancedStatsCardState();
}

class _EnhancedStatsCardState extends State<EnhancedStatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.durationLong,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.emphasizedCurve,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    if (widget.showAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
                boxShadow: isDarkMode
                    ? DesignTokens.cardShadowDark
                    : DesignTokens.cardShadow,
              ),
              child: Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: widget.gradient,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (isDarkMode
                              ? DesignTokens.darkSurface
                              : DesignTokens.trueWhite)
                          .withValues(alpha: 0.9),
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusLG),
                    ),
                    padding: const EdgeInsets.all(DesignTokens.spaceMD),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with icon and title
                        Row(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.all(DesignTokens.spaceXS),
                              decoration: BoxDecoration(
                                color: widget.iconColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    DesignTokens.radiusSM),
                              ),
                              child: Icon(
                                widget.icon,
                                color: widget.iconColor,
                                size: DesignTokens.iconSizeMD,
                              ),
                            ),
                            const SizedBox(width: DesignTokens.spaceSM),
                            Expanded(
                              child: Text(
                                widget.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight:
                                          DesignTokens.fontWeightSemiBold,
                                      color: isDarkMode
                                          ? DesignTokens.trueWhite
                                          : DesignTokens.pureBlack,
                                    ),
                              ),
                            ),
                            if (widget.trend != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DesignTokens.spaceXS,
                                  vertical: DesignTokens.spaceXXS,
                                ),
                                decoration: BoxDecoration(
                                  color: DesignTokens.emeraldGreen
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                      DesignTokens.radiusXS),
                                ),
                                child: Text(
                                  widget.trend!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: DesignTokens.emeraldGreen,
                                        fontWeight:
                                            DesignTokens.fontWeightMedium,
                                      ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: DesignTokens.spaceLG),

                        // Main value
                        Text(
                          widget.value,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                color: widget.iconColor,
                                fontWeight: DesignTokens.fontWeightBold,
                                height: 1.0,
                              ),
                        ),

                        const SizedBox(height: DesignTokens.spaceXS),

                        // Subtitle
                        Text(
                          widget.subtitle,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDarkMode
                                        ? DesignTokens.trueWhite
                                            .withValues(alpha: 0.7)
                                        : DesignTokens.pureBlack
                                            .withValues(alpha: 0.6),
                                    fontWeight: DesignTokens.fontWeightRegular,
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
