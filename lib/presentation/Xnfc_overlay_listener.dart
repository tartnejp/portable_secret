// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../application/providers/nfc_detection_provider.dart';

// class ListeningNfcApp extends ConsumerWidget {
//   final Widget child;

//   const ListeningNfcApp({super.key, required this.child});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     ref.listen(nfcDetectionEventProvider, (previous, next) {
//       next.when(
//         data: (event) {
//           _showOverlay(context, event);
//         },
//         error: (err, stack) {
//           // Ignore errors in background detection
//         },
//         loading: () {},
//       );
//     });

//     return child;
//   }

//   void _showOverlay(BuildContext context, NfcDetectionEvent event) {
//     // Dismiss existing snackbars
//     ScaffoldMessenger.of(context).hideCurrentSnackBar();

//     final message = event.message ?? 'Detected NFC Tag';

//     // Custom SnackBar to match the look of the previous overlay
//     final snackBar = SnackBar(
//       content: Text(
//         message,
//         textAlign: TextAlign.center,
//         style: const TextStyle(color: Colors.white, fontSize: 16),
//       ),
//       backgroundColor: Colors.black87,
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
//       margin: const EdgeInsets.only(bottom: 50, left: 24, right: 24),
//       duration: const Duration(seconds: 2),
//     );

//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }
// }
