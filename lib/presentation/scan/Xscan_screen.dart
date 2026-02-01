// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../application/providers/scan_providers.dart.old';
// import '../../domain/value_objects/lock_method.dart'; // For LockType
// import '../widgets/pattern_lock.dart';
// import 'secret_view_screen.dart';

// class ScanScreen extends ConsumerStatefulWidget {
//   const ScanScreen({super.key});

//   @override
//   ConsumerState<ScanScreen> createState() => _ScanScreenState();
// }

// class _ScanScreenState extends ConsumerState<ScanScreen> {
//   final TextEditingController _pinController = TextEditingController();

//   String _getInstruction(LockType type) {
//     switch (type) {
//       case LockType.pin:
//         return "Enter PIN";
//       case LockType.password:
//         return "Enter Password";
//       case LockType.pattern:
//         return "Draw Pattern";
//       case LockType.patternAndPin:
//         return "Draw Pattern & Enter PIN";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final scanState = ref.watch(scanProvider);

//     // Navigation Listener
//     ref.listen(scanProvider, (previous, next) {
//       if (next is ScanStateUnlocked) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (_) => SecretViewScreen(secret: next.secret),
//           ),
//         );
//       }
//     });

//     return Scaffold(
//       appBar: AppBar(title: const Text('Unlock Secret')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: _buildBody(scanState),
//       ),
//     );
//   }

//   Widget _buildBody(ScanState state) {
//     if (state is ScanStateIdle) {
//       return const Center(child: Text('Waiting for NFC...'));
//     } else if (state is ScanStateScanning) {
//       return const Center(child: CircularProgressIndicator());
//     } else if (state is ScanStateError) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error, color: Colors.red, size: 48),
//             const SizedBox(height: 16),
//             Text('Error: ${state.message}'),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => ref.read(scanProvider.notifier).reset(),
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     } else if (state is ScanStateLocked) {
//       final lockType = state.lockMethod.type;

//       return Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.lock, size: 60),
//           const SizedBox(height: 24),

//           // Lock Type Selector (since we don't know it from the opaque blob)
//           DropdownButton<LockType>(
//             value: lockType,
//             items: const [
//               DropdownMenuItem(value: LockType.pin, child: Text('PIN')),
//               DropdownMenuItem(
//                 value: LockType.password,
//                 child: Text('Password'),
//               ),
//               DropdownMenuItem(value: LockType.pattern, child: Text('Pattern')),
//             ],
//             onChanged: (val) {
//               if (val != null) {
//                 ref.read(scanProvider.notifier).switchLockType(val);
//               }
//             },
//           ),

//           const SizedBox(height: 16),
//           Text(_getInstruction(lockType)),
//           const SizedBox(height: 16),

//           if (lockType == LockType.pattern)
//             SizedBox(
//               height: 300,
//               child: PatternLock(
//                 onChanged:
//                     (
//                       val,
//                     ) {}, // Maybe just track for visual? Or wait for complete?
//                 // PatternLock usually triggers onComplete.
//                 // We can use onComplete to auto-submit?
//                 onComplete: (val) {
//                   ref.read(scanProvider.notifier).validateAndDecrypt(val);
//                 },
//                 dimension: 3,
//               ),
//             )
//           else
//             TextField(
//               controller: _pinController,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'Input Key',
//               ),
//               keyboardType: lockType == LockType.pin
//                   ? TextInputType.number
//                   : TextInputType.text,
//               obscureText: true,
//               onSubmitted: (val) {
//                 ref.read(scanProvider.notifier).validateAndDecrypt(val);
//               },
//             ),

//           if (state.error != null)
//             Padding(
//               padding: const EdgeInsets.only(top: 16),
//               child: Text(
//                 state.error!,
//                 style: const TextStyle(color: Colors.red),
//               ),
//             ),

//           const SizedBox(height: 24),
//           if (lockType != LockType.pattern)
//             ElevatedButton(
//               onPressed: () {
//                 ref
//                     .read(scanProvider.notifier)
//                     .validateAndDecrypt(_pinController.text);
//               },
//               child: const Text('Unlock'),
//             ),
//         ],
//       );
//     }
//     return const SizedBox.shrink();
//   }
// }
