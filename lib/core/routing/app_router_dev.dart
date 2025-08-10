import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/capture/presentation/screens/capture_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../scaffold/app_scaffold.dart';

// Development router without auth requirements
final appRouterDevProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/explore',
    routes: [
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/explore',
            name: 'explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/capture',
            name: 'capture',
            builder: (context, state) => const CaptureScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
