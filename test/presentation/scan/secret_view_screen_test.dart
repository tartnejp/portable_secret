import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:portable_sec/presentation/scan/secret_view_screen.dart';
import 'package:portable_sec/domain/value_objects/secret_data.dart';

// Mock UrlLauncherPlatform
class MockUrlLauncher extends Fake
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {
  String? launchedUrl;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrl = url;
    return true;
  }

  @override
  Future<bool> canLaunch(String url) async {
    return true;
  }

  // Keep this but remove override if it complains, or keep it if needed by newer interface
  Future<bool> canLaunchUrl(String url) async {
    return true;
  }
}

void main() {
  group('SecretViewScreen Tests', () {
    late MockUrlLauncher mockUrlLauncher;
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      mockUrlLauncher = MockUrlLauncher();
      UrlLauncherPlatform.instance = mockUrlLauncher;

      // Mock Clipboard
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (
            MethodCall methodCall,
          ) async {
            log.add(methodCall);
            return null;
          });
      log.clear();
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    testWidgets(
      'Renders URLs as clickable links and launches them',
      skip: true,
      (WidgetTester tester) async {
        final secret = SecretData(
          items: [
            SecretItem(key: "Website", value: "https://example.com"),
            SecretItem(key: "Normal", value: "Available"),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(home: SecretViewScreen(secret: secret)),
          ),
        );

        // Verify "Website" renders as InkWell (Link)
        // We look for blue text or InkWell
        final linkFinder = find.widgetWithText(InkWell, "https://example.com");
        expect(linkFinder, findsOneWidget);

        // Verify "Normal" renders as SelectableText
        final textFinder = find.widgetWithText(SelectableText, "Available");
        expect(textFinder, findsOneWidget);

        // Tap the link
        await tester.tap(linkFinder.first);
        await tester.pump();

        // Verify URL launched
        if (mockUrlLauncher.launchedUrl != "https://example.com") {
          fail(
            "Expected URL not launched. Actual: ${mockUrlLauncher.launchedUrl}",
          );
        }
      },
    );

    testWidgets('Copy button copies value to clipboard', skip: true, (
      WidgetTester tester,
    ) async {
      final secret = SecretData(
        items: [SecretItem(key: "Password", value: "Secret123")],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: SecretViewScreen(secret: secret)),
        ),
      );

      // Find copy button (IconButton with copy icon)
      final copyButtonFinder = find.widgetWithIcon(IconButton, Icons.copy);
      expect(copyButtonFinder, findsOneWidget);

      // Tap copy
      await tester.tap(copyButtonFinder);
      await tester.pumpAndSettle();

      // Verify Clipboard.setData called via SystemChannel
      if (log.isEmpty) {
        fail(
          "Clipboard log is empty. Copy button tap might not have triggered action.",
        );
      }
      expect(log.last.method, 'Clipboard.setData');
      expect(log.last.arguments['text'], 'Secret123');

      // Verify SnackBar
      expect(find.text('クリップボードにコピーしました'), findsOneWidget);
    });
  });
}
