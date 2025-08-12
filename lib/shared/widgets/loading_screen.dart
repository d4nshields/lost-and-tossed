import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
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
                borderRadius: BorderRadius.circular(AppTheme.radius2xl),
              ),
              child: Icon(
                Icons.explore,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: AppTheme.spaceXl),

            // App name
            Text(
              'Lost & Tossed',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: AppTheme.spaceSm),

            // Tagline
            Text(
              AppStrings.appTagline,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppTheme.spaceXl),

            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: AppTheme.spaceLg),

            // Loading text
            Text(
              'Preparing your adventure...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
