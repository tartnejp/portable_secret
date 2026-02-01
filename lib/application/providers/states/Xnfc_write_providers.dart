// import 'dart:async';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// import '../../services/nfc_service.dart';
// import '../di/services_provider.dart';
// part 'nfc_write_providers.g.dart';

// @Riverpod(keepAlive: false)
// class NfcWriteController extends _$NfcWriteController {
//   StreamSubscription<NfcWriteState>? _subscription;

//   @override
//   FutureOr<NfcWriteState?> build() {
//     ref.onDispose(() {
//       _subscription?.cancel();
//       // stopScan removes write mode too in current impl?
//       // check implementation: stopScan sets mode to idle.
//       // We might want precise control, but stopScan is fine for cleanup.
//       ref.watch(nfcServiceProvider).stopScan();
//     });
//     return null;
//   }

//   Future<void> startWrite(List<NfcWriteData> dataList) async {
//     state = const AsyncValue.loading();
//     try {
//       final stream = await ref.read(nfcServiceProvider).startWrite(dataList);
//       _subscription = stream.listen((writeState) {
//         state = AsyncValue.data(writeState);
//       });
//     } catch (e, st) {
//       state = AsyncValue.error(e, st);
//     }
//   }

//   void confirmOverwrite() {
//     ref.read(nfcServiceProvider).confirmOverwrite();
//   }

//   void reset() {
//     _subscription?.cancel();
//     ref.watch(nfcServiceProvider).stopScan();
//     state = const AsyncValue.data(null);
//   }
// }
