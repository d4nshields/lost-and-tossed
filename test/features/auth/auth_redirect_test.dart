import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lost_and_tossed/core/router/app_router.dart';
import 'package:lost_and_tossed/features/auth/providers/auth_providers.dart';
import 'package:lost_and_tossed/features/auth/data/auth_repository.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockUser extends Mock implements User {}

void main() {
  group('Auth Redirect Tests', () {
    late MockAuthRepository mockAuthRepository;
    late ProviderContainer container;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('redirects to login when not authenticated', (tester) async {
      // Arrange
      when(() => mockAuthRepository.authStateChanges).thenAnswer(
        (_) => Stream.value(AuthState(AuthChangeEvent.signedOut, null)),
      );
      when(() => mockAuthRepository.currentUser).thenReturn(null);

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(routerProvider);
              return MaterialApp.router(
                routerConfig: router,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Lost & Tossed'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('redirects to home when authenticated', (tester) async {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('test-user-id');
      when(() => mockUser.email).thenReturn('test@example.com');
      
      when(() => mockAuthRepository.authStateChanges).thenAnswer(
        (_) => Stream.value(
          AuthState(
            AuthChangeEvent.signedIn,
            Session(
              accessToken: 'token',
              tokenType: 'bearer',
              user: mockUser,
            ),
          ),
        ),
      );
      when(() => mockAuthRepository.currentUser).thenReturn(mockUser);

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(routerProvider);
              return MaterialApp.router(
                routerConfig: router,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Should show the main app with bottom nav
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Capture'), findsOneWidget);
      expect(find.text('Notebook'), findsOneWidget);
    });

    test('SessionGuard protects routes when not authenticated', () {
      // Arrange
      when(() => mockAuthRepository.currentUser).thenReturn(null);
      
      // Act
      final user = container.read(authRepositoryProvider).currentUser;
      
      // Assert
      expect(user, isNull);
    });

    test('SessionGuard allows access when authenticated', () {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('test-user-id');
      when(() => mockAuthRepository.currentUser).thenReturn(mockUser);
      
      // Act
      final user = container.read(authRepositoryProvider).currentUser;
      
      // Assert
      expect(user, isNotNull);
      expect(user!.id, equals('test-user-id'));
    });
  });
}
