import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../presentation/theme/cozy_theme.dart';
import '../../../core/constants/app_strings.dart';

/// Home screen showing discovered items
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Tossed'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.explore,
              size: 64,
              color: LostTossedCozyTheme.goldenAmber,
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceLg),
            const Text(
              'Welcome to Lost & Tossed!',
              style: LostTossedCozyTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceMd),
            const Padding(
              padding: const EdgeInsets.symmetric(horizontal: LostTossedCozyTheme.spaceLg),
              child: Text(
                AppStrings.welcomeSubtitle,
                style: LostTossedCozyTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceXl),
            LostTossedCozyTheme.createMicroCopy(
              "Every object has a story waiting to be told.",
            ),
            const SizedBox(height: LostTossedCozyTheme.spaceLg),
            
            // Category preview chips
            Wrap(
              spacing: LostTossedCozyTheme.spaceSm,
              runSpacing: LostTossedCozyTheme.spaceSm,
              alignment: WrapAlignment.center,
              children: [
                LostTossedCozyTheme.createCategoryChip(category: 'lost'),
                LostTossedCozyTheme.createCategoryChip(category: 'tossed'),
                LostTossedCozyTheme.createCategoryChip(category: 'posted'),
                LostTossedCozyTheme.createCategoryChip(category: 'marked'),
                LostTossedCozyTheme.createCategoryChip(category: 'curious'),
                LostTossedCozyTheme.createCategoryChip(category: 'traces'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
