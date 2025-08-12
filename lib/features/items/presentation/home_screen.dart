import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
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
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore,
              size: 64,
              color: AppTheme.primaryGreen,
            ),
            SizedBox(height: AppTheme.spaceLg),
            Text(
              'Welcome to Lost & Tossed!',
              style: AppTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.spaceMd),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
              child: Text(
                AppStrings.welcomeSubtitle,
                style: AppTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppTheme.spaceXl),
            Text(
              'Start by capturing your first discovery!',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
