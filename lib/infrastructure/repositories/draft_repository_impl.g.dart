// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(wizardDraftRepository)
final wizardDraftRepositoryProvider = WizardDraftRepositoryProvider._();

final class WizardDraftRepositoryProvider
    extends
        $FunctionalProvider<
          WizardDraftRepository,
          WizardDraftRepository,
          WizardDraftRepository
        >
    with $Provider<WizardDraftRepository> {
  WizardDraftRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wizardDraftRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wizardDraftRepositoryHash();

  @$internal
  @override
  $ProviderElement<WizardDraftRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WizardDraftRepository create(Ref ref) {
    return wizardDraftRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WizardDraftRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WizardDraftRepository>(value),
    );
  }
}

String _$wizardDraftRepositoryHash() =>
    r'19af58d3d98608891df8aae078b02f32aa46b1cf';
