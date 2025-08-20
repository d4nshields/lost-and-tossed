import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_providers.dart';
import '../../../presentation/theme/cozy_theme.dart';

/// Login screen with Google Sign-In
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);

    // Listen to auth changes
    ref.listen<AsyncValue<User?>>(authUserProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          // User signed in, navigate to home
          context.go('/');
        }
      });
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LostTossedCozyTheme.spaceLg),
          child: Column(
            children: [
              const Spacer(),
              
              // App logo/illustration
              Icon(
                Icons.explore_outlined,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              
              const SizedBox(height: LostTossedCozyTheme.spaceXl),
              
              // App name
              Text(
                'Lost & Tossed',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              
              const SizedBox(height: LostTossedCozyTheme.spaceMd),
              
              // Tagline
              Text(
                'A playful community field guide',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: LostTossedCozyTheme.spaceXs),
              
              Text(
                'Document found, discarded, and posted objects',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // Micro-copy
              Container(
                padding: const EdgeInsets.all(LostTossedCozyTheme.spaceMd),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(LostTossedCozyTheme.radiusMd),
                ),
                child: Column(
                  children: [
                    _buildMicroCopy(
                      context,
                      '🧤',
                      'A glove begins its solo adventure',
                    ),
                    const SizedBox(height: LostTossedCozyTheme.spaceSm),
                    _buildMicroCopy(
                      context,
                      '📋',
                      'Someone\'s grocery list, now part of history',
                    ),
                    const SizedBox(height: LostTossedCozyTheme.spaceSm),
                    _buildMicroCopy(
                      context,
                      '🎭',
                      'Poster\'s still here, but the event is long gone',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: LostTossedCozyTheme.spaceXl),
              
              // Sign in button
              SizedBox(
                width: double.infinity,
                child: authState.when(
                  data: (_) => ElevatedButton.icon(
                    onPressed: () {
                      ref.read(authNotifierProvider.notifier).signInWithGoogle();
                    },
                    icon: Image.asset(
                      'assets/images/google_logo.png',
                      height: 24,
                      width: 24,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback if image doesn't exist
                        return const Icon(Icons.account_circle);
                      },
                    ),
                    label: const Text('Continue with Google'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: LostTossedCozyTheme.spaceLg,
                        vertical: LostTossedCozyTheme.spaceMd,
                      ),
                    ),
                  ),
                  loading: () => ElevatedButton.icon(
                    onPressed: null,
                    icon: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    label: const Text('Signing in...'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: LostTossedCozyTheme.spaceLg,
                        vertical: LostTossedCozyTheme.spaceMd,
                      ),
                    ),
                  ),
                  error: (error, _) => Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(authNotifierProvider.notifier).signInWithGoogle();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: LostTossedCozyTheme.spaceLg,
                            vertical: LostTossedCozyTheme.spaceMd,
                          ),
                        ),
                      ),
                      const SizedBox(height: LostTossedCozyTheme.spaceSm),
                      Text(
                        'Sign in failed. Please try again.',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: LostTossedCozyTheme.spaceMd),
              
              // Privacy note
              Text(
                'By continuing, you agree to contribute your finds\nunder CC BY-NC license',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: LostTossedCozyTheme.spaceLg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMicroCopy(BuildContext context, String emoji, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: LostTossedCozyTheme.spaceSm),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}
