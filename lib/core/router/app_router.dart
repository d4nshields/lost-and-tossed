import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/capture/presentation/screens/capture_screen.dart';
import '../../features/notebook/presentation/screens/notebook_screen.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../shared/widgets/loading_screen.dart';

/// App router configuration using GoRouter
///
/// This centralizes all navigation logic and provides type-safe routing
/// with proper authentication guards and deep linking support.

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Router provider that handles authentication state
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authUserProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: false,  // Turn off verbose logging
    initialLocation: '/',

    // Redirect logic based on authentication state
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isLoading = authState.isLoading;

      // Show loading screen while checking auth state
      if (isLoading && state.matchedLocation != '/loading') {
        return '/loading';
      }

      final isOnAuthPage = state.matchedLocation.startsWith('/auth');
      final isOnLoadingPage = state.matchedLocation == '/loading';

      // If not authenticated and not on auth/loading page, redirect to login
      if (!isAuthenticated && !isOnAuthPage && !isOnLoadingPage) {
        return '/auth/login';
      }

      // If authenticated but on auth page, redirect to home
      if (isAuthenticated && isOnAuthPage) {
        return '/';
      }

      return null; // No redirect needed
    },

    routes: [
      // Loading screen
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingScreen(),
      ),

      // Authentication routes
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          // Explore tab (map + feed)
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const MaterialPage(
              child: ExploreScreen(),
            ),
          ),

          // Capture tab
          GoRoute(
            path: '/capture',
            pageBuilder: (context, state) => const MaterialPage(
              child: CaptureScreen(),
            ),
          ),

          // Notebook tab (user's finds)
          GoRoute(
            path: '/notebook',
            pageBuilder: (context, state) => const MaterialPage(
              child: NotebookScreen(),
            ),
          ),
        ],
      ),
    ],

    // Error handling
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.error?.toString() ?? 'Unknown error',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    },
  );
});

/// Route information constants
class AppRoutes {
  static const String loading = '/loading';
  static const String login = '/auth/login';
  static const String home = '/';
  static const String capture = '/capture';
  static const String notebook = '/notebook';
}

/// Session guard widget for protecting routes
class SessionGuard extends ConsumerWidget {
  final Widget child;

  const SessionGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authUserProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // Not authenticated, redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRoutes.login);
          });
          return const LoadingScreen();
        }
        return child;
      },
      loading: () => const LoadingScreen(),
      error: (error, stack) {
        // Auth error, redirect to login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(AppRoutes.login);
        });
        return const LoadingScreen();
      },
    );
  }
}

/// Extensions for easier navigation
extension GoRouterExtensions on GoRouter {
  /// Navigate to capture screen
  void goToCapture() {
    go(AppRoutes.capture);
  }

  /// Navigate to notebook screen
  void goToNotebook() {
    go(AppRoutes.notebook);
  }

  /// Navigate to login screen
  void goToLogin() {
    go(AppRoutes.login);
  }

  /// Navigate to home screen
  void goToHome() {
    go(AppRoutes.home);
  }
}

/// Route-aware mixin for widgets that need to know current route
mixin RouteAwareMixin<T extends StatefulWidget> on State<T> {
  String get currentRoute => GoRouterState.of(context).matchedLocation;

  bool get isOnExploreTab => currentRoute == AppRoutes.home;
  bool get isOnCaptureTab => currentRoute == AppRoutes.capture;
  bool get isOnNotebookTab => currentRoute == AppRoutes.notebook;
}

/// Helper for getting current route information
class RouteHelper {
  static String getCurrentRoute(BuildContext context) {
    return GoRouterState.of(context).matchedLocation;
  }

  static Map<String, String> getPathParameters(BuildContext context) {
    return GoRouterState.of(context).pathParameters;
  }

  static Map<String, String> getQueryParameters(BuildContext context) {
    return GoRouterState.of(context).uri.queryParameters;
  }

  static bool isCurrentRoute(BuildContext context, String route) {
    return getCurrentRoute(context) == route;
  }

  static bool isOnTab(BuildContext context, String tabRoute) {
    final currentRoute = getCurrentRoute(context);
    return currentRoute.startsWith(tabRoute);
  }
}
