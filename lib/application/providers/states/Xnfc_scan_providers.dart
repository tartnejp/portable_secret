// import 'dart:async';

// import 'package:riverpod_annotation/riverpod_annotation.dart';

// import '../../services/nfc_service.dart';
// import '../di/services_provider.dart';

// part 'nfc_scan_providers.g.dart';

// @Riverpod(keepAlive: true)
// class NfcScanController extends _$NfcScanController {
//   StreamSubscription<NfcScanState>? _subscription;

//   @override
//   FutureOr<NfcScanState?> build() async {
//     // keepAlive: trueなので、一度しかbuildされない

//     ref.onDispose(() {
//       _subscription?.cancel();
//       ref.watch(nfcServiceProvider).stopScan();
//     });

//     return null; // 初期状態
//   }

//   void startScan() {
//     state = const AsyncValue.loading();

//     final stream = ref.watch(nfcServiceProvider).startScan();
//     _subscription = stream.listen(
//       (scanState) {
//         state = AsyncValue.data(scanState);
//       },
//       onError: (error, stackTrace) {
//         state = AsyncValue.error(error, stackTrace);
//       },
//     );
//   }

//   void stopScan() {
//     _subscription?.cancel();
//     ref.watch(nfcServiceProvider).stopScan();
//     state = const AsyncValue.data(null);
//   }
// }
