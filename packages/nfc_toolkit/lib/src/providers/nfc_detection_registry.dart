import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/nfc_detection.dart';

/// Registry to hold all available [NfcDetection] factories.
class NfcDetectionRegistry {
  NfcDetectionRegistry(this.detectionFactories);

  final List<NfcDetection Function()> detectionFactories;
}

/// Provider that exposes the [NfcDetectionRegistry].
///
/// This provider MUST be overridden in the app's `ProviderScope` to register
/// the specific [NfcDetection]s utilized by the app.
///
/// Example:
/// ```dart
/// ProviderScope(
///   overrides: [
///     NfcDetectionRegistryProvider.overrideWithValue(
///       NfcDetectionRegistry([
///         () => SecretDetection(),
///         () => UrlDetection(),
///       ]),
///     ),
///   ],
///   child: MyApp(),
/// )
/// ```
final nfcDetectionRegistryProvider = Provider<NfcDetectionRegistry>((ref) {
  throw UnimplementedError(
    'NfcDetectionRegistryProvider must be overridden in your app.\n'
    'See documentation for detection registration details.',
  );
});
