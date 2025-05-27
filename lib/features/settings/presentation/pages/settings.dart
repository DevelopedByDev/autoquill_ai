import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:autoquill_ai/features/settings/presentation/bloc/settings_state.dart';
import 'package:autoquill_ai/features/settings/presentation/pages/general_settings_page.dart';
import 'package:autoquill_ai/features/settings/presentation/pages/transcription_settings_page.dart';
import 'package:autoquill_ai/features/settings/presentation/pages/assistant_settings_page.dart';
import 'package:autoquill_ai/features/settings/presentation/pages/output_settings_page.dart';
import 'package:autoquill_ai/core/theme/design_tokens.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static final List<Map<String, dynamic>> _settingsSections = [
    {
      'title': 'General',
      'icon': Icons.settings_rounded,
      'page': const GeneralSettingsPage(),
      'color': DesignTokens.vibrantCoral,
    },
    {
      'title': 'Transcription',
      'icon': Icons.mic_rounded,
      'page': const TranscriptionSettingsPage(),
      'color': DesignTokens.deepBlue,
    },
    {
      'title': 'Assistant',
      'icon': Icons.smart_toy_rounded,
      'page': const AssistantSettingsPage(),
      'color': DesignTokens.emeraldGreen,
    },
    {
      'title': 'Output',
      'icon': Icons.output_rounded,
      'page': OutputSettingsPage(),
      'color': DesignTokens.purpleViolet,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.durationMedium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: DesignTokens.vibrantCoral,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: isDarkMode
                  ? DesignTokens.darkBackgroundGradient
                  : DesignTokens.backgroundGradient,
            ),
            child: Row(
              children: [
                // Enhanced Navigation Rail
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: DesignTokens.spaceLG,
                  ),
                  child: Container(
                    width: 280,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? DesignTokens.darkSurfaceElevated
                              .withValues(alpha: 0.9)
                          : DesignTokens.trueWhite.withValues(alpha: 0.95),
                      boxShadow: isDarkMode
                          ? DesignTokens.cardShadowDark
                          : DesignTokens.cardShadow,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(DesignTokens.radiusLG),
                        bottomRight: Radius.circular(DesignTokens.radiusLG),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(DesignTokens.spaceLG),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                DesignTokens.vibrantCoral
                                    .withValues(alpha: 0.1),
                                DesignTokens.deepBlue.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(DesignTokens.radiusLG),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(
                                        DesignTokens.spaceXS),
                                    decoration: BoxDecoration(
                                      gradient: DesignTokens.coralGradient,
                                      borderRadius: BorderRadius.circular(
                                          DesignTokens.radiusSM),
                                    ),
                                    child: Icon(
                                      Icons.tune_rounded,
                                      color: DesignTokens.trueWhite,
                                      size: DesignTokens.iconSizeMD,
                                    ),
                                  ),
                                  const SizedBox(width: DesignTokens.spaceSM),
                                  Text(
                                    'Settings',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight:
                                              DesignTokens.fontWeightBold,
                                          color: isDarkMode
                                              ? DesignTokens.trueWhite
                                              : DesignTokens.pureBlack,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: DesignTokens.spaceXS),
                              Text(
                                'Customize your AutoQuill experience',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: isDarkMode
                                          ? DesignTokens.trueWhite
                                              .withValues(alpha: 0.7)
                                          : DesignTokens.pureBlack
                                              .withValues(alpha: 0.6),
                                    ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: DesignTokens.spaceLG),

                        // Navigation List
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: DesignTokens.spaceMD),
                            itemCount: _settingsSections.length,
                            itemBuilder: (context, index) {
                              final section = _settingsSections[index];
                              final isSelected = _selectedIndex == index;
                              final sectionColor = section['color'] as Color;

                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: DesignTokens.spaceXS),
                                child: AnimatedContainer(
                                  duration: DesignTokens.durationMedium,
                                  curve: DesignTokens.emphasizedCurve,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? sectionColor.withValues(alpha: 0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                        DesignTokens.radiusMD),
                                    border: isSelected
                                        ? Border.all(
                                            color: sectionColor.withValues(
                                                alpha: 0.3),
                                            width: 1,
                                          )
                                        : null,
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedIndex = index;
                                        });
                                        _animationController.reset();
                                        _animationController.forward();
                                      },
                                      borderRadius: BorderRadius.circular(
                                          DesignTokens.radiusMD),
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                            DesignTokens.spaceMD),
                                        child: Row(
                                          children: [
                                            AnimatedContainer(
                                              duration:
                                                  DesignTokens.durationMedium,
                                              padding: const EdgeInsets.all(
                                                  DesignTokens.spaceXS),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? sectionColor.withValues(
                                                        alpha: 0.15)
                                                    : (isDarkMode
                                                        ? DesignTokens
                                                            .darkSurfaceVariant
                                                        : DesignTokens
                                                            .lightSurfaceVariant),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        DesignTokens.radiusSM),
                                              ),
                                              child: Icon(
                                                section['icon'] as IconData,
                                                color: isSelected
                                                    ? sectionColor
                                                    : (isDarkMode
                                                        ? DesignTokens.trueWhite
                                                            .withValues(
                                                                alpha: 0.6)
                                                        : DesignTokens.pureBlack
                                                            .withValues(
                                                                alpha: 0.6)),
                                                size: DesignTokens.iconSizeMD,
                                              ),
                                            ),
                                            const SizedBox(
                                                width: DesignTokens.spaceSM),
                                            Expanded(
                                              child: Text(
                                                section['title'] as String,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color: isSelected
                                                          ? sectionColor
                                                          : (isDarkMode
                                                              ? DesignTokens
                                                                  .trueWhite
                                                              : DesignTokens
                                                                  .pureBlack),
                                                      fontWeight: isSelected
                                                          ? DesignTokens
                                                              .fontWeightSemiBold
                                                          : DesignTokens
                                                              .fontWeightRegular,
                                                    ),
                                              ),
                                            ),
                                            if (isSelected)
                                              Icon(
                                                Icons.chevron_right_rounded,
                                                color: sectionColor,
                                                size: DesignTokens.iconSizeSM,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Content with fade transition
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(DesignTokens.spaceLG),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? DesignTokens.darkSurfaceElevated
                              .withValues(alpha: 0.9)
                          : DesignTokens.trueWhite.withValues(alpha: 0.95),
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusLG),
                      boxShadow: isDarkMode
                          ? DesignTokens.cardShadowDark
                          : DesignTokens.cardShadow,
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusLG),
                      child: AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: AnimatedSwitcher(
                              duration: DesignTokens.durationMedium,
                              transitionBuilder: (child, animation) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.1, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Container(
                                key: ValueKey(_selectedIndex),
                                child: _settingsSections[_selectedIndex]['page']
                                    as Widget,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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
