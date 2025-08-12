import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/lost_item.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  LostItemCategory _selectedCategory = LostItemCategory.lost;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Show capture tips/help
            },
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Camera/photo section
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tap to capture or select photo',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Open camera
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Pick from gallery
                        },
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Category selection
            Text(
              'What did you find?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Category cards
            _CategorySelectionCard(
              category: LostItemCategory.lost,
              isSelected: _selectedCategory == LostItemCategory.lost,
              onTap: () => setState(() {
                _selectedCategory = LostItemCategory.lost;
              }),
            ),
            const SizedBox(height: 12),

            _CategorySelectionCard(
              category: LostItemCategory.tossed,
              isSelected: _selectedCategory == LostItemCategory.tossed,
              onTap: () => setState(() {
                _selectedCategory = LostItemCategory.tossed;
              }),
            ),
            const SizedBox(height: 12),

            _CategorySelectionCard(
              category: LostItemCategory.posted,
              isSelected: _selectedCategory == LostItemCategory.posted,
              onTap: () => setState(() {
                _selectedCategory = LostItemCategory.posted;
              }),
            ),
            const SizedBox(height: 12),

            _CategorySelectionCard(
              category: LostItemCategory.marked,
              isSelected: _selectedCategory == LostItemCategory.marked,
              onTap: () => setState(() {
                _selectedCategory = LostItemCategory.marked;
              }),
            ),
            const SizedBox(height: 12),

            _CategorySelectionCard(
              category: LostItemCategory.curious,
              isSelected: _selectedCategory == LostItemCategory.curious,
              onTap: () => setState(() {
                _selectedCategory = LostItemCategory.curious;
              }),
            ),
            const SizedBox(height: 32),

            // Continue button
            FilledButton(
              onPressed: () {
                // TODO: Navigate to capture details
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Selected: ${_selectedCategory.name} - ${_selectedCategory.playfulDescription}',
                    ),
                  ),
                );
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySelectionCard extends StatelessWidget {
  const _CategorySelectionCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final LostItemCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppTheme.getCategoryColor(category.name);

    return Card(
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border:
                isSelected ? Border.all(color: categoryColor, width: 2) : null,
          ),
          child: Row(
            children: [
              // Category icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Category info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.playfulDescription,
                      style: TextStyle(
                        color: categoryColor,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: categoryColor,
                )
              else
                Icon(
                  Icons.radio_button_unchecked,
                  color: Colors.grey[300],
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(LostItemCategory category) {
    switch (category) {
      case LostItemCategory.lost:
        return Icons.help_outline;
      case LostItemCategory.tossed:
        return Icons.delete_outline;
      case LostItemCategory.posted:
        return Icons.campaign_outlined;
      case LostItemCategory.marked:
        return Icons.brush_outlined;
      case LostItemCategory.curious:
        return Icons.psychology_outlined;
    }
  }
}
