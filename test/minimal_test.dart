import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_toolkit/nfc_toolkit.dart';
import 'package:portable_sec/presentation/home/home_screen.dart';
import 'package:portable_sec/router_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:portable_sec/application/providers/initialization_provider.dart';
import 'creation_wizard_test.dart'; // import MockNfcService

void main() {
  testWidgets('Minimal HomeScreen Test', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    final mockNfcService = MockNfcService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nfcServiceProvider.overrideWithValue(mockNfcService),
          initializationProvider.overrideWith((ref) async => ()),
          nfcDetectionRegistryProvider.overrideWithValue(
            NfcDetectionRegistry([]),
          ),
        ],
        child: const MaterialApp(
          home: const HomeScreen(), // Pump directly without router first
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Dump widget tree if not found
    if (find.byType(HomeScreen).evaluate().isEmpty) {
      debugPrint('WIDGET TREE (DIRECT):');
      debugDumpApp();
    }

    expect(find.byType(HomeScreen), findsOneWidget);
    debugPrint("HomeScreen found directly.");

    // Now try with Router
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nfcServiceProvider.overrideWithValue(mockNfcService),
          initializationProvider.overrideWith((ref) async => ()),
          nfcDetectionRegistryProvider.overrideWithValue(
            NfcDetectionRegistry([]),
          ),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final router = ref.watch(routerProvider);
            return MaterialApp.router(routerConfig: router);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Dump widget tree if not found
    if (find.byType(HomeScreen).evaluate().isEmpty) {
      debugPrint('WIDGET TREE (ROUTER):');
      debugDumpApp();
    }

    expect(find.byType(HomeScreen), findsOneWidget);
    debugPrint("HomeScreen found via Router.");
  });
}
