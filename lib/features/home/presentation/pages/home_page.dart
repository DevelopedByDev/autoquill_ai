import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/stats/stats_service.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../widgets/minimalist_card.dart';
import '../../../../widgets/minimalist_divider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StatsService _statsService = StatsService();
  
  // Value notifiers for stats
  final ValueNotifier<int> _transcriptionWordsCount = ValueNotifier<int>(0);
  final ValueNotifier<int> _generationWordsCount = ValueNotifier<int>(0);
  final ValueNotifier<int> _transcriptionTimeSeconds = ValueNotifier<int>(0);
  final ValueNotifier<double> _wordsPerMinute = ValueNotifier<double>(0.0);
  
  @override
  void initState() {
    super.initState();
    // Initialize the stats service
    _statsService.init();
    
    // Load initial counts
    _loadWordCounts();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload counts when dependencies change
    _loadWordCounts();
  }
  
  // Load stats from Hive
  Future<void> _loadWordCounts() async {
    try {
      // Initialize stats service first
      await _statsService.init();
      
      // Ensure the stats box is open
      if (!Hive.isBoxOpen('stats')) {
        await Hive.openBox('stats');
      }
      
      // Also ensure the settings box is open for API keys
      if (!Hive.isBoxOpen('settings')) {
        await Hive.openBox('settings');
      }
      
      final box = Hive.box('stats');
      _transcriptionWordsCount.value = box.get('transcription_words_count', defaultValue: 0);
      _generationWordsCount.value = box.get('generation_words_count', defaultValue: 0);
      _transcriptionTimeSeconds.value = box.get('transcription_time_seconds', defaultValue: 0);
      
      // Calculate WPM
      _updateWPM();
      
      // Set up a listener for changes to the stats box using the StatsService
      _statsService.getStatsBoxListenable(keys: [
        'transcription_words_count', 
        'generation_words_count',
        'transcription_time_seconds'
      ]).addListener(() {
        _transcriptionWordsCount.value = box.get('transcription_words_count', defaultValue: 0);
        _generationWordsCount.value = box.get('generation_words_count', defaultValue: 0);
        _transcriptionTimeSeconds.value = box.get('transcription_time_seconds', defaultValue: 0);
        _updateWPM();
      });
    } catch (e) {
      // Handle errors gracefully
      if (kDebugMode) {
        print('Error loading word counts: $e');
      }
    }
  }
  
  // Update the WPM value notifier
  void _updateWPM() {
    final totalWords = _transcriptionWordsCount.value + _generationWordsCount.value;
    final timeSeconds = _transcriptionTimeSeconds.value;
    
    if (timeSeconds > 0) {
      final timeMinutes = timeSeconds / 60.0;
      _wordsPerMinute.value = totalWords / timeMinutes;
    } else {
      _wordsPerMinute.value = 0.0;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoQuill AI'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceMD),
        child: Column(  
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to AutoQuill AI',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: DesignTokens.spaceXS),
            Text(
              'Your minimalist transcription and AI assistant',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: DesignTokens.spaceLG),
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: DesignTokens.vibrantCoral,
                  size: 20,
                ),
                const SizedBox(width: DesignTokens.spaceXS),
                Text(
                  'Usage Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: DesignTokens.fontWeightMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spaceSM),
            const MinimalistDivider(height: DesignTokens.spaceSM),
            const SizedBox(height: DesignTokens.spaceSM),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                // Custom Transcription Stats Card with ValueListenableBuilder
                ValueListenableBuilder<int>(
                  valueListenable: _transcriptionWordsCount,
                  builder: (context, count, _) {
                    return MinimalistCard(
                      child: Padding(
                        padding: const EdgeInsets.all(DesignTokens.spaceMD),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.mic,
                                  color: DesignTokens.vibrantCoral,
                                  size: 24,
                                ),
                                const SizedBox(width: DesignTokens.spaceXS),
                                Text(
                                  'Transcribed',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: DesignTokens.fontWeightMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: DesignTokens.spaceMD),
                            Text(
                              '$count',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: DesignTokens.vibrantCoral,
                                fontWeight: DesignTokens.fontWeightBold,
                              ),
                            ),
                            const SizedBox(height: DesignTokens.spaceXXS),
                            Text(
                              'words transcribed',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                // Custom Generation Stats Card with ValueListenableBuilder
                ValueListenableBuilder<int>(
                  valueListenable: _generationWordsCount,
                  builder: (context, count, _) {
                    return MinimalistCard(
                      child: Padding(
                        padding: const EdgeInsets.all(DesignTokens.spaceMD),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: DesignTokens.vibrantCoral,
                                  size: 24,
                                ),
                                const SizedBox(width: DesignTokens.spaceXS),
                                Text(
                                  'Generated',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: DesignTokens.fontWeightMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: DesignTokens.spaceMD),
                            Text(
                              '$count',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: DesignTokens.vibrantCoral,
                                fontWeight: DesignTokens.fontWeightBold,
                              ),
                            ),
                            const SizedBox(height: DesignTokens.spaceXXS),
                            Text(
                              'words generated',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                // Transcription Time Card
                ValueListenableBuilder<int>(
                  valueListenable: _transcriptionTimeSeconds,
                  builder: (context, seconds, _) {
                    final formattedTime = _statsService.formatTime(seconds);
                    return MinimalistCard(
                      child: Padding(
                        padding: const EdgeInsets.all(DesignTokens.spaceMD),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  color: DesignTokens.vibrantCoral,
                                  size: 24,
                                ),
                                const SizedBox(width: DesignTokens.spaceXS),
                                Text(
                                  'Recording Time',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: DesignTokens.fontWeightMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: DesignTokens.spaceMD),
                            Text(
                              formattedTime,
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: DesignTokens.vibrantCoral,
                                fontWeight: DesignTokens.fontWeightBold,
                              ),
                            ),
                            const SizedBox(height: DesignTokens.spaceXXS),
                            Text(
                              'total recording time',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                // Words Per Minute Card
                ValueListenableBuilder<double>(
                  valueListenable: _wordsPerMinute,
                  builder: (context, wpm, _) {
                    final formattedWPM = wpm.toStringAsFixed(1);
                    return MinimalistCard(
                      child: Padding(
                        padding: const EdgeInsets.all(DesignTokens.spaceMD),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.speed,
                                  color: DesignTokens.vibrantCoral,
                                  size: 24,
                                ),
                                const SizedBox(width: DesignTokens.spaceXS),
                                Text(
                                  'Words Per Minute',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: DesignTokens.fontWeightMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: DesignTokens.spaceMD),
                            Text(
                              formattedWPM,
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: DesignTokens.vibrantCoral,
                                fontWeight: DesignTokens.fontWeightBold,
                              ),
                            ),
                            const SizedBox(height: DesignTokens.spaceXXS),
                            Text(
                              'average WPM',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}
