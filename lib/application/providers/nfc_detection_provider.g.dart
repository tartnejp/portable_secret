// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nfc_detection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NfcDetectionStrategyNotifier)
final nfcDetectionStrategyProvider = NfcDetectionStrategyNotifierProvider._();

final class NfcDetectionStrategyNotifierProvider
    extends
        $NotifierProvider<NfcDetectionStrategyNotifier, NfcDetectionStrategy> {
  NfcDetectionStrategyNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nfcDetectionStrategyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nfcDetectionStrategyNotifierHash();

  @$internal
  @override
  NfcDetectionStrategyNotifier create() => NfcDetectionStrategyNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NfcDetectionStrategy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NfcDetectionStrategy>(value),
    );
  }
}

String _$nfcDetectionStrategyNotifierHash() =>
    r'd90944809bfbb22ed9e631a1e3be17c9bd824812';

abstract class _$NfcDetectionStrategyNotifier
    extends $Notifier<NfcDetectionStrategy> {
  NfcDetectionStrategy build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<NfcDetectionStrategy, NfcDetectionStrategy>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NfcDetectionStrategy, NfcDetectionStrategy>,
              NfcDetectionStrategy,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(NfcDetectionEventNotifier)
final nfcDetectionEventProvider = NfcDetectionEventNotifierProvider._();

final class NfcDetectionEventNotifierProvider
    extends
        $StreamNotifierProvider<NfcDetectionEventNotifier, NfcDetectionEvent> {
  NfcDetectionEventNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nfcDetectionEventProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nfcDetectionEventNotifierHash();

  @$internal
  @override
  NfcDetectionEventNotifier create() => NfcDetectionEventNotifier();
}

String _$nfcDetectionEventNotifierHash() =>
    r'c110f943ccc37a593c7ca8a7516cae7ccc7ec437';

abstract class _$NfcDetectionEventNotifier
    extends $StreamNotifier<NfcDetectionEvent> {
  Stream<NfcDetectionEvent> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<NfcDetectionEvent>, NfcDetectionEvent>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<NfcDetectionEvent>, NfcDetectionEvent>,
              AsyncValue<NfcDetectionEvent>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
