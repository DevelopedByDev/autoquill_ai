import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// A card widget to display statistics with a title, count, and icon
class StatsCard extends StatelessWidget {
  final String title;
  final String settingsKey;
  final IconData icon;
  final Color color;
  final String suffix;

  const StatsCard({
    super.key,
    required this.title,
    required this.settingsKey,
    required this.icon,
    required this.color,
    this.suffix = 'words',
  });

  @override
  Widget build(BuildContext context) {
    // Create a new listenable for the specific key
    final valueListenable = Hive.box('settings').listenable(keys: [settingsKey]);
    
    return ValueListenableBuilder(
      valueListenable: valueListenable,
      builder: (context, box, _) {
        // Get the current count from the box
        final count = box.get(settingsKey, defaultValue: 0);
        
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
                    Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  suffix,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
