import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages which [NfcDetection] types are currently being listened to by UI screens.
///
/// The registry tracks each registration as a mapping of:
///   `Type → { screenId → priority }`
///
/// This allows the dispatch logic to:
/// 1. Determine if any screen is interested in a specific detection type.
/// 2. Select the best type to dispatch based on priority.
/// 3. Properly handle reference counting when screens are pushed/popped.
class NfcInterestRegistry extends Notifier<Map<Type, Map<int, int>>> {
  @override
  Map<Type, Map<int, int>> build() => {};

  /// Registers interest in [type] for a screen identified by [screenId].
  ///
  /// [priority] determines dispatch preference when multiple types match.
  /// Higher values are preferred. Default is `1`, `GenericNfcDetected` uses `0`.
  void register(Type type, int screenId, int priority) {
    final current = Map<Type, Map<int, int>>.from(state);
    final entries = Map<int, int>.from(current[type] ?? {});
    entries[screenId] = priority;
    current[type] = entries;
    state = current;
  }

  /// Removes [screenId]'s interest in [type].
  ///
  /// If no screens remain interested in [type], the type is removed entirely.
  void unregister(Type type, int screenId) {
    final current = Map<Type, Map<int, int>>.from(state);
    final entries = current[type];
    if (entries == null) return;

    final updated = Map<int, int>.from(entries)..remove(screenId);
    if (updated.isEmpty) {
      current.remove(type);
    } else {
      current[type] = updated;
    }
    state = current;
  }

  /// Returns `true` if at least one screen is interested in [type].
  bool hasInterest(Type type) {
    final entries = state[type];
    return entries != null && entries.isNotEmpty;
  }

  /// Returns the maximum priority registered for [type], or `0` if none.
  int getMaxPriority(Type type) {
    final entries = state[type];
    if (entries == null || entries.isEmpty) return 0;
    return entries.values.reduce(max);
  }

  /// Given a list of matched detection types, selects the best one to dispatch.
  ///
  /// Selection criteria:
  /// 1. Only types with at least one interested screen are considered.
  /// 2. Among those, the type with the highest registered priority wins.
  /// 3. If priorities are equal, the first in [matchedTypes] order wins
  ///    (which corresponds to [NfcDetectionRegistry] registration order).
  ///
  /// Returns `null` if no interested type is found (→ Generic handling).
  Type? selectBestType(List<Type> matchedTypes) {
    Type? bestType;
    int bestPriority = -1;

    for (final type in matchedTypes) {
      if (!hasInterest(type)) continue;
      final priority = getMaxPriority(type);
      if (priority > bestPriority) {
        bestPriority = priority;
        bestType = type;
      }
    }

    return bestType;
  }
}

/// Provider for the [NfcInterestRegistry].
final nfcInterestRegistryProvider =
    NotifierProvider<NfcInterestRegistry, Map<Type, Map<int, int>>>(() {
      return NfcInterestRegistry();
    });
