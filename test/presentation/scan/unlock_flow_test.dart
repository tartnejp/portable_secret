import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:portable_sec/presentation/scan/unlock_pattern_screen.dart';
import 'package:portable_sec/presentation/scan/unlock_pin_screen.dart';
import 'package:portable_sec/application/services/encryption_service.dart';
import 'package:portable_sec/application/providers/encryption_providers.dart';
import 'package:portable_sec/presentation/widgets/pattern_lock.dart';
import 'package:portable_sec/domain/value_objects/secret_data.dart';

import '../../application/providers/creation_notifier_test.mocks.dart';

// No MockGoRouter needed, we use real GoRouter with spy routes

void main() {
  group('Unlock Flow Tests', () {
    testWidgets(
      'UnlockPatternScreen navigates to UPI on Pattern+PIN completion',
      (WidgetTester tester) async {
        dynamic capturedExtra;

        final router = GoRouter(
          initialLocation: '/upa',
          routes: [
            GoRoute(
              path: '/upa',
              name: 'UPA',
              builder: (context, state) => const UnlockPatternScreen(
                encryptedText: "dummy",
                lockType: 3, // patternAndPin
              ),
            ),
            GoRoute(
              path: '/upi',
              name: 'UPI',
              builder: (context, state) {
                capturedExtra = state.extra;
                return const SizedBox(); // Target screen
              },
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(child: MaterialApp.router(routerConfig: router)),
        );

        // Simulate Pattern Input
        final patternLockFinder = find.byType(PatternLock);
        final patternLockWidget = tester.widget<PatternLock>(patternLockFinder);

        // Trigger callback directly
        patternLockWidget.onComplete!("012");
        await tester.pumpAndSettle(); // Allow navigation

        // Verify navigation happened and args passed
        expect(capturedExtra, isNotNull);
        expect(capturedExtra['encryptedText'], "dummy");
        expect(capturedExtra['pattern'], "012");
      },
    );

    testWidgets('UnlockPinScreen decrypts with combined key', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockEncryptionService = MockEncryptionService();

      // Setup successful decryption
      when(
        mockEncryptionService.decrypt(any, any),
      ).thenAnswer((_) async => SecretData(items: []));

      // We need SVS route to handle success navigation
      final router = GoRouter(
        initialLocation: '/upi',
        routes: [
          GoRoute(
            path: '/upi',
            name: 'UPI',
            builder: (context, state) => const UnlockPinScreen(
              encryptedText: "ZHVtbXk=", // base64("dummy")
              pattern: "012",
            ),
          ),
          GoRoute(
            path: '/svs',
            name: 'SVS',
            builder: (context, state) => const SizedBox(), // Success screen
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            encryptionServiceProvider.overrideWithValue(mockEncryptionService),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      // Input PIN "1234"
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.text('4'));
      await tester.pump();

      // Tap Unlock Button
      await tester.tap(find.text('解除'));
      await tester.pumpAndSettle(); // Async logic + Navigation

      // Verify decrypt was called with correct combined key
      verify(mockEncryptionService.decrypt(any, "012:1234")).called(1);
    });
  });
}
