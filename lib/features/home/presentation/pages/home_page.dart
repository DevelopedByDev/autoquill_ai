import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../widgets/enhanced_stats_card.dart';
import '../bloc/home_bloc_barrel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(const LoadHomeStats()),
      child: const _HomePageView(),
    );
  }
}

class _HomePageView extends StatefulWidget {
  const _HomePageView();

  @override
  State<_HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<_HomePageView>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _cardsAnimationController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _headerAnimationController = AnimationController(
      duration: DesignTokens.durationLong,
      vsync: this,
    );

    _cardsAnimationController = AnimationController(
      duration: DesignTokens.durationExtraLong,
      vsync: this,
    );

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOut,
    ));

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: DesignTokens.emphasizedCurve,
    ));

    // Start animations
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardsAnimationController.forward();
    });

    // Add animation events to BLoC
    context.read<HomeBloc>().add(const StartHeaderAnimation());
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<HomeBloc>().add(const StartCardsAnimation());
      }
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardsAnimationController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${remainingSeconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 17) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: isDarkMode
                  ? DesignTokens.darkBackgroundGradient
                  : DesignTokens.backgroundGradient,
            ),
            child: CustomScrollView(
              slivers: [
                // App bar with gradient
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            DesignTokens.vibrantCoral.withValues(alpha: 0.1),
                            DesignTokens.deepBlue.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(DesignTokens.spaceLG),
                          child: AnimatedBuilder(
                            animation: _headerAnimationController,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _headerFadeAnimation,
                                child: SlideTransition(
                                  position: _headerSlideAnimation,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Welcome message with time-based greeting
                                      Text(
                                        _getGreeting(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              fontWeight:
                                                  DesignTokens.fontWeightBold,
                                              color: isDarkMode
                                                  ? DesignTokens.trueWhite
                                                  : DesignTokens.pureBlack,
                                            ),
                                      ),
                                      const SizedBox(
                                          height: DesignTokens.spaceXS),
                                      Text(
                                        'Ready to capture your thoughts with AutoQuill?',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: isDarkMode
                                                  ? DesignTokens.trueWhite
                                                      .withValues(alpha: 0.8)
                                                  : DesignTokens.pureBlack
                                                      .withValues(alpha: 0.7),
                                              fontWeight: DesignTokens
                                                  .fontWeightRegular,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Main content
                SliverPadding(
                  padding: const EdgeInsets.all(DesignTokens.spaceLG),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Statistics section header
                      Container(
                        margin:
                            const EdgeInsets.only(bottom: DesignTokens.spaceLG),
                        child: Row(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.all(DesignTokens.spaceXS),
                              decoration: BoxDecoration(
                                gradient: DesignTokens.coralGradient,
                                borderRadius: BorderRadius.circular(
                                    DesignTokens.radiusSM),
                              ),
                              child: Icon(
                                Icons.analytics_rounded,
                                color: DesignTokens.trueWhite,
                                size: DesignTokens.iconSizeSM,
                              ),
                            ),
                            const SizedBox(width: DesignTokens.spaceSM),
                            Text(
                              'Your Activity Overview',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: DesignTokens.fontWeightSemiBold,
                                    color: isDarkMode
                                        ? DesignTokens.trueWhite
                                        : DesignTokens.pureBlack,
                                  ),
                            ),
                          ],
                        ),
                      ),

                      // Enhanced stats grid
                      AnimatedBuilder(
                        animation: _cardsAnimationController,
                        builder: (context, child) {
                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: DesignTokens.spaceMD,
                            crossAxisSpacing: DesignTokens.spaceMD,
                            childAspectRatio: 1.7,
                            children: [
                              // Transcription Words Card
                              EnhancedStatsCard(
                                icon: Icons.mic_rounded,
                                title: 'Transcribed',
                                value: state.transcriptionWordsCount.toString(),
                                subtitle: 'words captured',
                                gradient: DesignTokens.coralGradient,
                                iconColor: DesignTokens.vibrantCoral,
                                showAnimation:
                                    _cardsAnimationController.value > 0.25,
                              ),

                              // Generation Words Card
                              EnhancedStatsCard(
                                icon: Icons.auto_awesome_rounded,
                                title: 'Generated',
                                value: state.generationWordsCount.toString(),
                                subtitle: 'words created',
                                gradient: DesignTokens.blueGradient,
                                iconColor: DesignTokens.deepBlue,
                                showAnimation:
                                    _cardsAnimationController.value > 0.5,
                              ),

                              // Recording Time Card
                              EnhancedStatsCard(
                                icon: Icons.timer_rounded,
                                title: 'Recording Time',
                                value:
                                    _formatTime(state.transcriptionTimeSeconds),
                                subtitle: 'total duration',
                                gradient: DesignTokens.greenGradient,
                                iconColor: DesignTokens.emeraldGreen,
                                showAnimation:
                                    _cardsAnimationController.value > 0.75,
                              ),

                              // Words Per Minute Card
                              EnhancedStatsCard(
                                icon: Icons.speed_rounded,
                                title: 'Efficiency',
                                value: state.wordsPerMinute.toStringAsFixed(1),
                                subtitle: 'words per minute',
                                gradient: DesignTokens.purpleGradient,
                                iconColor: DesignTokens.purpleViolet,
                                showAnimation:
                                    _cardsAnimationController.value > 1.0,
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: DesignTokens.spaceXXL),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
