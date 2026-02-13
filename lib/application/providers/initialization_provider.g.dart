// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initialization_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(initialization)
final initializationProvider = InitializationProvider._();

final class InitializationProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  InitializationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initializationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initializationHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return initialization(ref);
  }
}

String _$initializationHash() => r'7597cffbbc3c31ffcbf7497231a1b23f64667faf';
