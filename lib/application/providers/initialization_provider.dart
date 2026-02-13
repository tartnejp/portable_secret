import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc_toolkit/nfc_toolkit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'initialization_provider.g.dart';

@Riverpod(keepAlive: true)
Future<void> initialization(Ref ref) async {
  // Initialize NFC Service
  await ref.read(nfcServiceProvider).init();
}
