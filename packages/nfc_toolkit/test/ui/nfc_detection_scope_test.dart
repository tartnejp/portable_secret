import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_toolkit/nfc_toolkit.dart';

// === Mocks & Stubs ===

class TestDetection extends NfcDetection {
  const TestDetection();
  @override
  FutureOr<NfcDetection?> detect(NfcData data) => null;
}

void main() {
  testWidgets('Specific Detection is propagated to child listeners', (
    tester,
  ) async {
    final streamController = StreamController<NfcDetection>.broadcast();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nfcDetectionStreamProvider.overrideWith(
            (ref) => streamController.stream,
          ),
        ],
        child: MaterialApp(
          home: NfcDetectionScope(
            child: Consumer(
              builder: (context, ref, child) {
                ref.listen<
                  AsyncValue<NfcDetection>
                >(nfcDetectionStreamProvider, (prev, next) {
                  next.whenData((detection) {
                    if (detection is TestDetection) {
                      // Mark as received (e.g. show a snackbar or change state)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Received TestDetection')),
                      );
                    }
                  });
                });
                return const Scaffold(body: Text('Child Widget'));
              },
            ),
          ),
        ),
      ),
    );

    // Initial state
    expect(find.text('Child Widget'), findsOneWidget);
    expect(find.text('Received TestDetection'), findsNothing);

    // Emit TestDetection
    streamController.add(const TestDetection());
    await tester.pump(); // Process stream
    await tester.pump(); // Process animation/snackbar

    // Verify propagation
    expect(find.text('Received TestDetection'), findsOneWidget);

    streamController.close();
  });

  testWidgets('Generic Overlay is suppressed on disabled routes', (
    tester,
  ) async {
    final streamController = StreamController<NfcDetection>.broadcast();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nfcDetectionStreamProvider.overrideWith(
            (ref) => streamController.stream,
          ),
        ],
        child: MaterialApp(
          home: NfcDetectionScope(
            // Suppress on '/home'
            disableGenericDetectionRoutes: const {'/home'},
            // Simulate being on '/home'
            routeNameGetter: (_) => '/home',
            child: const Scaffold(body: Text('Home Screen')),
          ),
        ),
      ),
    );

    // Initial state
    expect(find.text('Home Screen'), findsOneWidget);
    expect(find.text('NFCタグを検知しました'), findsNothing);

    // Emit Generic Detection
    streamController.add(GenericNfcDetected());
    await tester.pump(); // Process stream
    await tester.pump(); // Animation start

    // Verify Is Suppressed (Should NOT find text)
    expect(find.text('NFCタグを検知しました'), findsNothing);

    streamController.close();
  });

  testWidgets('Generic Overlay is SHOWN on allowed routes', (tester) async {
    final streamController = StreamController<NfcDetection>.broadcast();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nfcDetectionStreamProvider.overrideWith(
            (ref) => streamController.stream,
          ),
        ],
        child: MaterialApp(
          home: NfcDetectionScope(
            // Suppress on '/home', but we are on '/other'
            disableGenericDetectionRoutes: const {'/home'},
            routeNameGetter: (_) => '/other',
            child: const Scaffold(body: Text('Other Screen')),
          ),
        ),
      ),
    );

    // Initial state
    expect(find.text('Other Screen'), findsOneWidget);

    // Emit Generic Detection
    streamController.add(GenericNfcDetected());
    await tester.pump(); // Process stream
    await tester.pump(); // Animation start

    // Verify Is SHOWN
    expect(find.text('NFCタグを検知しました'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));

    streamController.close();
  });
}
