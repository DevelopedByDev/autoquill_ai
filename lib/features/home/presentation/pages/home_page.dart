import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/stats/stats_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StatsService _statsService = StatsService();
  
  // Value notifiers for word counts
  final ValueNotifier<int> _transcriptionWordsCount = ValueNotifier<int>(0);
  final ValueNotifier<int> _generationWordsCount = ValueNotifier<int>(0);
  
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
  
  // Load word counts from Hive
  Future<void> _loadWordCounts() async {
    final box = Hive.box('settings');
    _transcriptionWordsCount.value = box.get('transcription_words_count', defaultValue: 0);
    _generationWordsCount.value = box.get('generation_words_count', defaultValue: 0);
    
    // Set up a listener for changes to the Hive box
    box.listenable(keys: ['transcription_words_count', 'generation_words_count']).addListener(() {
      _transcriptionWordsCount.value = box.get('transcription_words_count', defaultValue: 0);
      _generationWordsCount.value = box.get('generation_words_count', defaultValue: 0);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(  
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AutoQuill AI',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Your transcription and AI assistant',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          Text(
            'Usage Statistics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
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
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.mic,
                                  color: Color(0xFF3B82F6), // blue-500
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Transcribed',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '$count',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: const Color(0xFF3B82F6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
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
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  color: Color(0xFFF97316), // orange-500
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Generated',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '$count',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: const Color(0xFFF97316),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
