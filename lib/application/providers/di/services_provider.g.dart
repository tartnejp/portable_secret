// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'services_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(nfcService)
final nfcServiceProvider = NfcServiceProvider._();

final class NfcServiceProvider
    extends $FunctionalProvider<NfcService, NfcService, NfcService>
    with $Provider<NfcService> {
  NfcServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nfcServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nfcServiceHash();

  @$internal
  @override
  $ProviderElement<NfcService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NfcService create(Ref ref) {
    return nfcService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NfcService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NfcService>(value),
    );
  }
}

String _$nfcServiceHash() => r'7b5383253fc47dd912912ad69cfecc6984ee7f2b';
