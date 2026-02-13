// import 'dart:async';
// import 'dart:convert';
// import 'package:nfc_toolkit/nfc_toolkit.dart';
// import 'package:nfc_manager/nfc_manager.dart';
// import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';

// /// Detection logic for "URL" NFC tags.
// class UrlDetection extends NfcDetection with OverlayDisplay {
//   const UrlDetection({this.url});

//   final String? url;

//   @override
//   FutureOr<NfcDetection?> detect(NfcData data) async {
//     // Fail-fast
//     final message = await data.getOrReadMessage();
//     if (message == null || message.records.isEmpty) return null;

//     for (final record in message.records) {
//       // Check for URI record (WellKnown + 'U')
//       if (record.typeNameFormat == TypeNameFormat.wellKnown &&
//           record.type.length == 1 &&
//           record.type[0] == 0x55) {
//         // 'U'

//         final payload = record.payload;
//         if (payload.isEmpty) continue;

//         final prefixCode = payload[0];
//         final uriContent = utf8.decode(payload.sublist(1));

//         String prefix = '';
//         switch (prefixCode) {
//           case 0x01:
//             prefix = 'http://www.';
//             break;
//           case 0x02:
//             prefix = 'https://www.';
//             break;
//           case 0x03:
//             prefix = 'http://';
//             break;
//           case 0x04:
//             prefix = 'https://';
//             break;
//           // Add other prefixes if needed
//           default:
//             prefix = '';
//         }

//         final fullUrl = '$prefix$uriContent';
//         return UrlDetection(url: fullUrl);
//       }
//     }

//     return null;
//   }

//   @override
//   String get overlayMessage =>
//       url != null ? 'URL Detected: $url' : 'URL Detected';
// }
