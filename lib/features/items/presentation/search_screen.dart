import 'package:flutter/material.dart';

import '../../../presentation/theme/cozy_theme.dart';

/// Search screen for finding items
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(LostTossedCozyTheme.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'What are you looking for?',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () {
                    // TODO: Show filters
                  },
                ),
              ),
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceLg),
            
            // Category filters
            const Text(
              'Search by Category',
              style: LostTossedCozyTheme.headingSmall,
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceMd),
            
            Wrap(
              spacing: LostTossedCozyTheme.spaceSm,
              runSpacing: LostTossedCozyTheme.spaceSm,
              children: [
                LostTossedCozyTheme.createCategoryChip(
                  category: 'lost',
                  onTap: () {
                    // TODO: Filter by lost items
                  },
                ),
                LostTossedCozyTheme.createCategoryChip(
                  category: 'tossed',
                  onTap: () {
                    // TODO: Filter by tossed items
                  },
                ),
                LostTossedCozyTheme.createCategoryChip(
                  category: 'posted',
                  onTap: () {
                    // TODO: Filter by posted items
                  },
                ),
                LostTossedCozyTheme.createCategoryChip(
                  category: 'marked',
                  onTap: () {
                    // TODO: Filter by marked items
                  },
                ),
                LostTossedCozyTheme.createCategoryChip(
                  category: 'curious',
                  onTap: () {
                    // TODO: Filter by curious items
                  },
                ),
                LostTossedCozyTheme.createCategoryChip(
                  category: 'traces',
                  onTap: () {
                    // TODO: Filter by traces
                  },
                ),
              ],
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceXl),
            
            // Empty state
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.search_off,
                      size: 64,
                      color: LostTossedCozyTheme.pewter,
                    ),
                    const SizedBox(height: LostTossedCozyTheme.spaceLg),
                    LostTossedCozyTheme.createMicroCopy(
                      "Start your search to discover what others have found.",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
