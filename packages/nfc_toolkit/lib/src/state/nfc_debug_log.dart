import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Debug log notifier for NFC processing events.
/// Used to surface internal NFC errors to the UI during debugging.
class NfcDebugLogNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void add(String msg) {
    final time = DateTime.now().toString().substring(11, 19);
    state = [...state.take(29), '$time $msg'];
  }

  void clear() {
    state = [];
  }
}

final nfcDebugLogProvider = NotifierProvider<NfcDebugLogNotifier, List<String>>(
  NfcDebugLogNotifier.new,
);
