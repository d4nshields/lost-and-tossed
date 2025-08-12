import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement search
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement filter
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Category filters
          SliverToBoxAdapter(
            child: Container(
              height: 120,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _CategoryChip(
                    label: 'Lost',
                    color: AppTheme.lostColor,
                    icon: Icons.help_outline,
                    isSelected: true,
                  ),
                  _CategoryChip(
                    label: 'Tossed',
                    color: AppTheme.tossedColor,
                    icon: Icons.delete_outline,
                  ),
                  _CategoryChip(
                    label: 'Posted',
                    color: AppTheme.postedColor,
                    icon: Icons.campaign_outlined,
                  ),
                  _CategoryChip(
                    label: 'Marked',
                    color: AppTheme.markedColor,
                    icon: Icons.brush_outlined,
                  ),
                  _CategoryChip(
                    label: 'Curious',
                    color: AppTheme.curiousColor,
                    icon: Icons.psychology_outlined,
                  ),
                  _CategoryChip(
                    label: 'Traces',
                    color: AppTheme.tracesColor,
                    icon: Icons.directions_walk,
                  ),
                ],
              ),
            ),
          ),

          // Items grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ItemCard(
                  title: _sampleTitles[index % _sampleTitles.length],
                  description:
                      _sampleDescriptions[index % _sampleDescriptions.length],
                  category: _sampleCategories[index % _sampleCategories.length],
                ),
                childCount: 20, // Placeholder count
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.color,
    required this.icon,
    this.isSelected = false,
  });

  final String label;
  final Color color;
  final IconData icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: FilterChip(
        selected: isSelected,
        onSelected: (selected) {
          // TODO: Implement category filtering
        },
        avatar: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.white : color,
        ),
        label: Text(label),
        backgroundColor: color.withOpacity(0.1),
        selectedColor: color,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.title,
    required this.description,
    required this.category,
  });

  final String title;
  final String description;
  final String category;

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppTheme.getCategoryColor(category);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: Colors.grey[200],
              child: const Icon(
                Icons.image,
                size: 48,
                color: Colors.grey,
              ),
            ),
          ),

          // Content
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: categoryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Flexible(
                    child: Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Sample data for demonstration
const _sampleTitles = [
  'Solo Glove Adventure',
  'Event Poster Survivor',
  'Snack Wrapper Clue',
  'Mysterious Object',
  'Lost Key Chain',
  'Street Art Discovery',
  'Abandoned Coffee Cup',
  'Phone Number Flyer',
];

const _sampleDescriptions = [
  'A glove begins its solo adventure.',
  'Poster\'s still here, but the event is long gone.',
  'The snack that left only a clue.',
  'What story does this tell?',
  'Someone\'s keys found a new home.',
  'Creative expression on the sidewalk.',
  'Morning coffee\'s final destination.',
  'Contact info for a mystery service.',
];

const _sampleCategories = [
  'Lost',
  'Posted',
  'Tossed',
  'Curious',
  'Lost',
  'Marked',
  'Tossed',
  'Posted',
];
