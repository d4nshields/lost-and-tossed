import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/profile_setup_screen.dart';
import '../../features/items/presentation/home_screen.dart';
import '../../features/items/presentation/item_detail_screen.dart';
import '../../features/items/presentation/search_screen.dart';
import '../../features/capture/presentation/capture_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
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
  final authState = ref.watch(currentUserProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: '/',

    // Redirect logic based on authentication state
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isLoading = authState.isLoading;

      // Show loading screen while checking auth state
      if (isLoading) {
        return '/loading';
      }

      final isOnAuthPage = state.matchedLocation.startsWith('/auth');
      final isOnProfileSetup = state.matchedLocation == '/profile-setup';

      // If not authenticated and not on auth page, redirect to login
      if (!isAuthenticated && !isOnAuthPage) {
        return '/auth/login';
      }

      // If authenticated but on auth page, redirect to home
      if (isAuthenticated && isOnAuthPage && !isOnProfileSetup) {
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
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          // Home/Discovery tab
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'item/:id',
                builder: (context, state) {
                  final itemId = state.pathParameters['id']!;
                  return ItemDetailScreen(itemId: itemId);
                },
              ),
            ],
          ),

          // Search tab
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),

          // Capture tab
          GoRoute(
            path: '/capture',
            builder: (context, state) => const CaptureScreen(),
          ),

          // Profile tab
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => const EditProfileScreen(),
              ),
            ],
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
  static const String signup = '/auth/signup';
  static const String profileSetup = '/profile-setup';
  static const String home = '/';
  static const String search = '/search';
  static const String capture = '/capture';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';

  static String itemDetail(String itemId) => '/item/$itemId';
}

/// Extensions for easier navigation
extension GoRouterExtensions on GoRouter {
  /// Navigate to item detail screen
  void goToItemDetail(String itemId) {
    go(AppRoutes.itemDetail(itemId));
  }

  /// Navigate to capture screen with result callback
  Future<T?> pushCapture<T extends Object?>() {
    return push<T>(AppRoutes.capture);
  }

  /// Navigate to profile edit screen
  Future<T?> pushEditProfile<T extends Object?>() {
    return push<T>(AppRoutes.editProfile);
  }

  /// Navigate to login screen
  void goToLogin() {
    go(AppRoutes.login);
  }

  /// Navigate to signup screen
  void goToSignup() {
    go(AppRoutes.signup);
  }

  /// Navigate to home screen
  void goToHome() {
    go(AppRoutes.home);
  }
}

/// Route-aware mixin for widgets that need to know current route
mixin RouteAwareMixin<T extends StatefulWidget> on State<T> {
  String get currentRoute => GoRouterState.of(context).matchedLocation;
  String? get currentItemId => GoRouterState.of(context).pathParameters['id'];

  bool get isOnHomeTab => currentRoute == AppRoutes.home;
  bool get isOnSearchTab => currentRoute == AppRoutes.search;
  bool get isOnCaptureTab => currentRoute == AppRoutes.capture;
  bool get isOnProfileTab => currentRoute == AppRoutes.profile;
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
