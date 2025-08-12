import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App logo/icon placeholder
              const Icon(
                Icons.explore,
                size: 80,
                color: Color(0xFF6B73FF),
              ),
              const SizedBox(height: 24),

              // App title and tagline
              const Text(
                'Lost & Tossed',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'A playful community field guide for documenting the world around us',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Sign in button
              FilledButton.icon(
                onPressed: () {
                  // TODO: Implement auth
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Authentication coming soon!'),
                    ),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
              ),
              const SizedBox(height: 16),

              // Anonymous exploration
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement anonymous mode
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Anonymous mode coming soon!'),
                    ),
                  );
                },
                icon: const Icon(Icons.explore),
                label: const Text('Explore Anonymously'),
              ),
              const SizedBox(height: 32),

              // Privacy note
              Text(
                'We respect your privacy. Location data is coarse and optional. See our privacy policy for details.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
