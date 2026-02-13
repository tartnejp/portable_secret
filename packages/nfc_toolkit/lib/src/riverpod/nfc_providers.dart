import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../nfc_service.dart';
/*
import '../strategies/nfc_detection_strategy.dart';
import '../strategies/mere_detection_strategy.dart';
*/

part 'nfc_providers.g.dart';

// --- Service Provider ---

@Riverpod(keepAlive: true)
NfcService nfcService(Ref ref) {
  // Return the singleton instance of the implementation.
  // Users can override this provider to provide a mock or configured instance.
  return NfcServiceImpl.instance;
}

/*
// --- Strategy Provider ---

@Riverpod(keepAlive: true)
class NfcDetectionStrategyNotifier extends _$NfcDetectionStrategyNotifier {
  List<NfcDetectionStrategy<dynamic>> _registeredStrategies = [];
  String _currentRoute = '/';

  @override
  NfcDetectionStrategy<dynamic> build() {
    // Default to Generic if nothing registered yet
    return const MereDetectionStrategy();
  }

  /// Register available strategies.
  /// This should be called once (e.g. at app startup).
  void registerStrategies(List<NfcDetectionStrategy<dynamic>> strategies) {
    _registeredStrategies = strategies;
    // Re-evaluate with current route
    updateRoute(_currentRoute);
  }

  /// Update the current route name and resolve the active strategy.
  void updateRoute(String routeName) {
    _currentRoute = routeName;
    final strategy = _resolveStrategy(routeName);
    if (strategy != null && strategy != state) {
      state = strategy;
    }
  }

  NfcDetectionStrategy<dynamic>? _resolveStrategy(String routeName) {
    if (_registeredStrategies.isEmpty) return null;

    // 1. Priority: Check Active List (Allowlist)
    try {
      final activeStrategy = _registeredStrategies.firstWhere((s) {
        final isActive = s.activeRouteNames?.contains(routeName) == true;
        // Optimization: Don't log every check, or use a conditional standard log

        return isActive;
      });
      return activeStrategy;
    } catch (_) {
      // Not found in active lists
    }

    // 2. Fallback: Check Disabled List (Blocklist)
    // We want a strategy that does NOT disable this route.
    // If multiple exist, we pick the first one (often the Generic/Default).
    try {
      return _registeredStrategies.firstWhere((s) {
        // Must NOT be actively disabled
        bool isDisabled = s.disabledRouteNames.contains(routeName);

        // And activeRouteNames should be null (meaning it's a general strategy, not a specialized one)
        bool isGeneral = s.activeRouteNames == null;

        return !isDisabled && isGeneral;
      });
    } catch (_) {
      return null;
    }
  }

  // Deprecated: Direct setting is discouraged in favor of route-based resolution,
  // but kept for compatibility or manual overrides.
  void setStrategy(NfcDetectionStrategy<dynamic> strategy) {
    state = strategy;
  }
}

// --- Event Provider ---

// We use 'Object' or 'dynamic' because the strategy is generic.
// Consumers can cast the event or use a strictly typed provider in their own app code.
@Riverpod(keepAlive: true)
Stream<dynamic> nfcDetectionEvent(Ref ref) {
  final strategy = ref.watch(nfcDetectionStrategyProvider);
  final service = ref.watch(nfcServiceProvider);

  return service.backgroundTagStream.asyncMap((data) async {
    return strategy.detect(data);
  }).asBroadcastStream();
}
*/
