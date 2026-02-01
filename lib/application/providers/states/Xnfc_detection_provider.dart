// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:nfc_manager/ndef_record.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// import '../di/services_provider.dart';

// part 'nfc_detection_provider.g.dart';

// enum NfcDetectionType { generic  }

// @immutable
// class NfcDetectionEvent {
//   final NfcDetectionType type;
//   final String? message; // For location name or generic message
//   final String uuid;

//   NfcDetectionEvent._({required this.type, this.message})
//     : uuid = DateTime.now().toIso8601String();

//   factory NfcDetectionEvent.generic() {
//     return NfcDetectionEvent._(
//       type: NfcDetectionType.generic,
//       message: 'Detected NFC Tag',
//     );
//   }
// }

// //* Provider
// @Riverpod(keepAlive: true)
// Stream<NfcDetectionEvent> nfcDetectionEvent(Ref ref) async* {
//   final nfcService = ref.watch(nfcServiceProvider);

//   // Yield events from the background stream
//   await for (final data in nfcService.backgroundTagStream) {
//     // 1. Check for NDEF (prefer cached message from cold start)
//     NdefMessage? message = data.cachedMessage;

//     // Fallback to reading if no cached message and we have a live tag
//     if (message == null && data.ndef != null) {
//       try {
//         message = await data.ndef!.read();
//       } catch (_) {
//         // read failed
//       }
//     }

//     if (message == null || message.records.isEmpty) {
//       yield NfcDetectionEvent.generic();
//       continue;
//     }

//     try {
//       final record = message.records.first;
//       String payloadString;
//       try {
//         payloadString = utf8.decode(record.payload);
//       } catch (_) {
//         yield NfcDetectionEvent.generic();
//         continue;
//       }
//     } catch (e) {
//       debugPrint('Error parsing background tag: $e');
//       yield NfcDetectionEvent.generic();
//     }
//   }
// }
