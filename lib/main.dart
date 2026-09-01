import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/providers.dart';
import 'core/router/app_router.dart';
import 'presentation/theme/cozy_theme.dart';
import 'core/constants/app_constants.dart';
import 'shared/widgets/loading_screen.dart';
import 'features/capture/providers/capture_providers.dart';
import 'services/app_update_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences before app starts
  final sharedPreferences = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        // Override the SharedPreferences provider with the actual instance
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const LostAndTossedApp(),
    ),
  );
}

/// Main application widget
class LostAndTossedApp extends ConsumerStatefulWidget {
  const LostAndTossedApp({super.key});

  @override
  ConsumerState<LostAndTossedApp> createState() => _LostAndTossedAppState();
}

class _LostAndTossedAppState extends ConsumerState<LostAndTossedApp> {
  bool _hasCheckedForUpdates = false;

  @override
  void initState() {
    super.initState();
    // Check for updates after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  /// Check for Google Play In-App Updates (only once per app launch)
  Future<void> _checkForUpdates() async {
    if (_hasCheckedForUpdates) {
      debugPrint('📱 [AppUpdate] Skipping check - already checked on this launch');
      return;
    }

    _hasCheckedForUpdates = true;

    try {
      await AppUpdateService.instance.checkForUpdate();
    } catch (e) {
      // Silent failure - don't disrupt user experience
      debugPrint('Update check failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch app initialization
    final appInitAsyncValue = ref.watch(appInitProvider);

    return appInitAsyncValue.when(
      loading: () => MaterialApp(
        title: AppConstants.appName,
        theme: LostTossedCozyTheme.lightTheme,
        darkTheme: LostTossedCozyTheme.lightTheme, // Using light theme for both modes initially
        home: const LoadingScreen(),
        debugShowCheckedModeBanner: false,
      ),
      error: (error, stackTrace) => MaterialApp(
        title: AppConstants.appName,
        theme: LostTossedCozyTheme.lightTheme,
        darkTheme: LostTossedCozyTheme.lightTheme, // Using light theme for both modes initially
        home: _ErrorScreen(
          error: error,
          onRetry: () => ref.invalidate(appInitProvider),
        ),
        debugShowCheckedModeBanner: false,
      ),
      data: (_) {
        final router = ref.watch(routerProvider);

        return MaterialApp.router(
          title: AppConstants.appName,
          theme: LostTossedCozyTheme.lightTheme,
          darkTheme: LostTossedCozyTheme.lightTheme, // Using light theme for both modes initially
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('es', 'ES'),
            Locale('fr', 'FR'),
          ],
          
          builder: (context, child) {
            // Limit text scale factor for consistent UI
            final mediaQueryData = MediaQuery.of(context);
            final constrainedTextScaleFactor = mediaQueryData.textScaleFactor.clamp(0.8, 1.3);
            
            return MediaQuery(
              data: mediaQueryData.copyWith(
                textScaler: TextScaler.linear(constrainedTextScaleFactor),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}

/// Error screen widget
class _ErrorScreen extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorScreen({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                kDebugMode ? error.toString() : 'Failed to initialize the app. Please try again.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
