// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:nfc_toolkit/nfc_toolkit.dart';

// part 'services_provider.g.dart';

// @riverpod
// NfcService nfcService(Ref ref) {
//   return NfcServiceImpl.instance;
// }

/// Simple boolean stream to track NFC availability
// @riverpod
// Stream<bool> nfcAvailability(Ref ref) async* {
//   final service = ref.watch(nfcServiceProvider);
//   // Initial check
//   yield await service.isAvailable();
//   // We could poll or listen to platform channels if available,
//   // but for now creating a simple periodic check if needed, or just one-off.
//   // Standard nfc_manager doesn't provide a stream for availability changes easily.
// }
