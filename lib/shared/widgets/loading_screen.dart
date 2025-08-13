import 'package:flutter/material.dart';

import '../../presentation/theme/cozy_theme.dart';
import '../../core/constants/app_strings.dart';

/// Loading screen shown during app initialization
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(LostTossedCozyTheme.radius2xl),
              ),
              child: Icon(
                Icons.explore,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: LostTossedCozyTheme.spaceXl),

            // App name
            Text(
              'Lost & Tossed',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: LostTossedCozyTheme.spaceSm),

            // Tagline
            Text(
              AppStrings.appTagline,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: LostTossedCozyTheme.spaceXl),

            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: LostTossedCozyTheme.spaceLg),

            // Loading text with cozy micro-copy
            LostTossedCozyTheme.createMicroCopy(
              'Gathering stories from the streets...',
            ),
          ],
        ),
      ),
    );
  }
}
