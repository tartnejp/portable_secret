// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreationNotifier)
final creationProvider = CreationNotifierProvider._();

final class CreationNotifierProvider
    extends $NotifierProvider<CreationNotifier, CreationState> {
  CreationNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creationNotifierHash();

  @$internal
  @override
  CreationNotifier create() => CreationNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreationState>(value),
    );
  }
}

String _$creationNotifierHash() => r'349ec46673f663acf1cc89fa2996e310710aec79';

abstract class _$CreationNotifier extends $Notifier<CreationState> {
  CreationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CreationState, CreationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CreationState, CreationState>,
              CreationState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
