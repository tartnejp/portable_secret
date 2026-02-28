import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockNfcWriteModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void enableMode() => state = true;
  void disableMode() => state = false;
}

final mockNfcWriteModeProvider =
    NotifierProvider<MockNfcWriteModeNotifier, bool>(
      () => MockNfcWriteModeNotifier(),
    );
