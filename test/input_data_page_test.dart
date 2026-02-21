import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc_toolkit/nfc_toolkit.dart';
import 'package:portable_sec/presentation/creation/steps/input_data_page.dart';

// Minimal Mock NFC Service
class MockNfcService implements NfcService {
  @override
  Stream<NfcData> get backgroundTagStream => const Stream.empty();
  @override
  Stream<NfcError> get errorStream => const Stream.empty();

  @override
  Future<void> init() async {}

  @override
  void resetSession({String? alertMessage, void Function(String)? onError}) {}

  @override
  void startSessionWithTimeout({
    String? alertMessage,
    Duration? timeout,
    VoidCallback? onTimeout,
    void Function(String)? onError,
  }) {}

  @override
  void startSessionForIOS({
    String? alertMessage,
    Duration? timeout,
    VoidCallback? onTimeout,
    void Function(String)? onError,
  }) {}

  @override
  Future<Stream<NfcWriteState>> startWrite(
    List<NfcWriteData> dataList, {
    bool allowOverwrite = false,
    void Function(String)? onError,
  }) async {
    return const Stream.empty();
  }

  @override
  Future<NfcData?> getInitialTag() async {
    return null;
  }
}

void main() {
  testWidgets('InputDataPage: Data Addition, Validation and UI Checks', (
    tester,
  ) async {
    final mockNfc = MockNfcService();

    // Setup GoRouter to handle navigation calls
    final router = GoRouter(
      initialLocation: '/input',
      routes: [
        GoRoute(
          path: '/input',
          name: 'CIN',
          builder: (context, state) => const InputDataPage(),
        ),
        GoRoute(
          path: '/cca',
          name: 'CCA',
          builder: (context, state) => const Scaffold(body: Text('CCA Page')),
        ),
        GoRoute(
          path: '/ccf',
          name: 'CCF',
          builder: (context, state) => const Scaffold(body: Text('CCF Page')),
        ),
      ],
    );

    // Pump Widget
    await tester.pumpWidget(
      ProviderScope(
        overrides: [nfcServiceProvider.overrideWithValue(mockNfc)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify "Add" button exists and click it
    final addIcon = find.byIcon(Icons.add_circle);
    expect(addIcon, findsOneWidget);
    await tester.tap(addIcon);
    await tester.pumpAndSettle();

    // 2. Verify Dialog UI Check
    // Check for "項目名" (Item Name) label - Key
    expect(find.widgetWithText(TextField, '項目名'), findsOneWidget);

    // Check for "値" (Value) and Red Asterisk
    // Since we used Text.rich, we can verify the text spans
    final richTextFinder = find.byWidgetPredicate((widget) {
      if (widget is RichText) {
        final text = widget.text.toPlainText();
        return text.contains('値') && text.contains('*');
      }
      return false;
    });
    expect(richTextFinder, findsOneWidget);
    // Note: TextField label might be wrapped deeply, but let's check if we can find the hint text at least
    expect(find.widgetWithText(TextField, '例: user1'), findsOneWidget);

    // 3. Test Validation: Empty Value
    // Attempt to click OK without entering anything
    final okButton = find.byTooltip('OK');
    await tester.tap(okButton);
    await tester.pump(); // Trigger frame (SnackBar animation start)
    await tester.pump(const Duration(milliseconds: 500)); // Wait for snackbar

    // Expect SnackBar with error message
    expect(find.text('値を入力してください'), findsOneWidget);

    // Dialog should still be open (Cancel button visible)
    expect(find.text('キャンセル'), findsOneWidget);

    // 4. Test Logic: Empty Key is Allowed
    // Enter only value
    await tester.enterText(
      find.widgetWithText(TextField, '例: user1'),
      'OnlyValue',
    );
    await tester.tap(okButton);
    await tester.pumpAndSettle();

    // Dialog should be closed
    expect(find.text('キャンセル'), findsNothing);

    // Verify item is added to the list
    // The list uses ListTile(title: Text(key), subtitle: Text(value))
    // Key is empty string, Value is "OnlyValue"
    expect(find.text('OnlyValue'), findsOneWidget);

    // 5. Test Logic: Normal Entry (Key + Value)
    // Open Dialog again
    await tester.tap(addIcon);
    await tester.pumpAndSettle();

    // Enter Key and Value
    await tester.enterText(find.widgetWithText(TextField, '例: ユーザー名'), 'MyKey');
    await tester.enterText(
      find.widgetWithText(TextField, '例: user1'),
      'MyValue',
    );
    await tester.tap(okButton);
    await tester.pumpAndSettle();

    // Verify item added
    expect(find.text('MyKey'), findsOneWidget);
    expect(find.text('MyValue'), findsOneWidget);
  });
}
