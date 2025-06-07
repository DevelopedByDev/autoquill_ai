import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/design_tokens.dart';
import 'bloc/enhanced_stats_card_bloc_barrel.dart';

class EnhancedStatsCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EnhancedStatsCardBloc(
        animationController: AnimationController(
          vsync: Scaffold.of(context),
        ),
      )..add(InitializeAnimation(showAnimation: showAnimation)),
      child: _EnhancedStatsCardView(
        icon: icon,
        title: title,
        value: value,
        subtitle: subtitle,
        gradient: gradient,
        iconColor: iconColor,
        trend: trend,
      ),
    );
  }
}

class _EnhancedStatsCardView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final LinearGradient gradient;
  final Color iconColor;
  final String? trend;

  const _EnhancedStatsCardView({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.gradient,
    required this.iconColor,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bloc = context.read<EnhancedStatsCardBloc>();

    return BlocBuilder<EnhancedStatsCardBloc, EnhancedStatsCardState>(
      builder: (context, state) {
        return AnimatedBuilder(
          animation: bloc.animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: bloc.scaleAnimation.value,
              child: Opacity(
                opacity: bloc.fadeAnimation.value,
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
                        gradient: gradient,
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
                                    color: iconColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(
                                        DesignTokens.radiusSM),
                                  ),
                                  child: Icon(
                                    icon,
                                    color: iconColor,
                                    size: DesignTokens.iconSizeMD,
                                  ),
                                ),
                                const SizedBox(width: DesignTokens.spaceSM),
                                Expanded(
                                  child: Text(
                                    title,
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
                                if (trend != null)
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
                                      trend!,
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
                              value,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    color: iconColor,
                                    fontWeight: DesignTokens.fontWeightBold,
                                    height: 1.0,
                                  ),
                            ),

                            const SizedBox(height: DesignTokens.spaceXS),

                            // Subtitle
                            Text(
                              subtitle,
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
      },
    );
  }
}
