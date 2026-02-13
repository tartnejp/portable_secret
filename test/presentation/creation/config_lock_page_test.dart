import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portable_sec/presentation/creation/steps/config_lock_page.dart';
import 'package:portable_sec/application/providers/creation_providers.dart';
import 'package:portable_sec/domain/value_objects/lock_method.dart';
import 'package:portable_sec/presentation/widgets/pattern_lock.dart';

// Create a helper notifier to extend the real one or mock it.
// Since CreationNotifier is a generated class, extending it requires generated code available.
// Alternatively, we can assume the real notifier logic is verified in unit tests,
// and here we just want to verify UI response to state changes.
// So we can mock the provider simply by returning a controlled state?
// No, CreationNotifier is a Notifier, so we override it with a class that extends _$CreationNotifier.

// But explicitly extending `_$CreationNotifier` works only if we use `part` and `build_runner`.
// A simpler way for widget tests involving Riverpod is to simply modifiy the real notifier state
// if we can access it, OR mocking the whole provider is hard for generated providers.

// Let's stick to using the real notifier logic but ensuring correct setup.
// To fix the "No GoRouter" error if any, we wrap in a dummy Router?
// But ConfigLockPage doesn't call go_router methods during build, only on interactions.
// Interactions might trigger it.

class FakeCreationNotifier extends CreationNotifier {
  // Override build to set initial state
  @override
  CreationState build() {
    return const CreationState(
      step: CreationStep.lockConfig,
      selectedType: LockType.patternAndPin,
      maxCapacity: 100,
      items: [], // Doesn't matter for UI
      isLockSecondStage: false,
    );
  }
}

void main() {
  testWidgets(
    'ConfigLockPage switches from Pattern to PIN input for Pattern+PIN type',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            creationProvider.overrideWith(() => FakeCreationNotifier()),
          ],
          child: const MaterialApp(home: ConfigLockPage()),
        ),
      );

      // Should settle immediately as initial state is set
      await tester.pumpAndSettle();

      // Verify Initial State (Pattern)
      expect(find.textContaining('パターン'), findsOneWidget);
      expect(find.byType(PatternLock), findsOneWidget);

      // Simulate Pattern Input
      final patternLockFinder = find.byType(PatternLock);
      var patternLockWidget = tester.widget<PatternLock>(patternLockFinder);

      // We need to trigger state change. Since we are using FakeCreationNotifier which inherits generic logic,
      // we assume updateLockInput etc works.
      patternLockWidget.onChanged("012");
      // The real notifier updates state.lockInput

      // Tap Next
      await tester.tap(find.text('次へ'));
      await tester.pumpAndSettle();

      // Now in Confirm mode
      expect(find.textContaining('確認'), findsOneWidget);
      expect(find.byType(PatternLock), findsOneWidget);

      // Enter same pattern
      patternLockWidget = tester.widget<PatternLock>(find.byType(PatternLock));
      patternLockWidget.onChanged("012");

      // Tap Next -> Should transition to Second Stage (PIN)
      await tester.tap(find.text('次へ'));
      await tester.pumpAndSettle();

      // Verify PIN UI
      expect(find.textContaining('PIN'), findsOneWidget);
      expect(find.byType(PatternLock), findsNothing);
      expect(find.text('1'), findsOneWidget); // Keypad check
    },
  );
}
