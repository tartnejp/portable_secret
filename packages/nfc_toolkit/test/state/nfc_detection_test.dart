import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_toolkit/nfc_toolkit.dart';

// === Mocks ===

/// A mock implementation of NfcService for testing.
class MockNfcService implements NfcService {
  final StreamController<NfcData?> _streamController =
      StreamController<NfcData?>();
  NfcData? _initialTag;
  bool _initialTagConsumed = false;

  void setInitialTag(NfcData? tag) {
    _initialTag = tag;
    _initialTagConsumed = false;
  }

  void emitTag(NfcData? tag) {
    _streamController.add(tag);
  }

  @override
  Stream<NfcData?> get backgroundTagStream => _streamController.stream;
  @override
  Stream<NfcError> get errorStream => const Stream.empty();

  @override
  Future<NfcData?> getInitialTag() async {
    if (_initialTagConsumed) {
      return null;
    }
    _initialTagConsumed = true;
    return _initialTag;
  }

  @override
  Future<void> init() async {}

  @override
  void resetSession({String? alertMessage, void Function(String)? onError}) {}

  @override
  void startSessionWithTimeout({
    String? alertMessage,
    Duration? timeout,
    VoidCallback? onTimeout,
    void Function(String)? onError,
  }) {}

  @override
  void startSessionForIOS({
    String? alertMessage,
    Duration? timeout,
    VoidCallback? onTimeout,
    void Function(String)? onError,
  }) {}

  Future<void> startSession({List<String>? pathPattern}) async {}
  Future<void> stopSession() async {}
  Future<bool> isAvailable() async => true;
  Future<NdefMessage?> readNDEF() async => null;
  Future<void> writeNDEF(NdefMessage message, {bool lock = false}) async {}

  @override
  Future<Stream<NfcWriteState>> startWrite(
    List<NfcWriteData> dataList, {
    bool allowOverwrite = false,
    void Function(String)? onError,
  }) async {
    return const Stream.empty();
  }
}

class TestDetection extends NfcDetection {
  const TestDetection();

  @override
  FutureOr<NfcDetection?> detect(NfcData data) async {
    final msg = await data.getOrReadMessage();
    if (msg == null || msg.records.isEmpty) return null;

    final record = msg.records.first;
    final payloadRaw = record.payload;
    final payloadStr = String.fromCharCodes(payloadRaw);

    if (payloadStr.startsWith("MATCH")) {
      return const TestMatchingEvent("Matched!");
    }
    return null;
  }
}

class TestMatchingEvent extends NfcDetection {
  final String info;
  const TestMatchingEvent(this.info);

  @override
  FutureOr<NfcDetection?> detect(NfcData data) => null;

  @override
  String toString() => 'TestMatchingEvent($info)';
}

class MockNfcDataWithError extends NfcData {
  final String _mockError;
  MockNfcDataWithError(this._mockError) : super.fromManual(null);

  @override
  String? get readError => _mockError;

  @override
  Future<NdefMessage?> getOrReadMessage() async => null;
}

// === Tests ===

void main() {
  late MockNfcService mockNfcService;
  late ProviderContainer container;

  setUp(() {
    mockNfcService = MockNfcService();
    // Default container setup for other tests
    container = ProviderContainer(
      overrides: [
        nfcServiceProvider.overrideWithValue(mockNfcService),
        nfcDetectionRegistryProvider.overrideWithValue(
          NfcDetectionRegistry([() => const TestDetection()]),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  NfcData createData(String content) {
    final record = NdefRecord(
      typeNameFormat: TypeNameFormat.wellKnown,
      type: Uint8List.fromList([0x54]),
      identifier: Uint8List(0),
      payload: Uint8List.fromList(content.codeUnits),
    );
    final message = NdefMessage(records: [record]);
    return NfcData.fromManual(message);
  }

  test('Initial Tag is emitted followed by Generic', () async {
    final tag = createData("MATCH:123");
    mockNfcService.setInitialTag(tag);

    container.dispose();
    container = ProviderContainer(
      overrides: [
        nfcServiceProvider.overrideWithValue(mockNfcService),
        nfcDetectionRegistryProvider.overrideWithValue(
          NfcDetectionRegistry([() => const TestDetection()]),
        ),
      ],
    );

    final events = <NfcDetection>[];

    container.listen<AsyncValue<NfcDetection>>(nfcDetectionStreamProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (d) => events.add(d),
        error:
            (
              e,
              s,
            ) {}, // Ignore errors for clean output, assertions catch missing events
        loading: () {},
      );
    }, fireImmediately: true);

    // Give ample time
    await Future.delayed(const Duration(milliseconds: 500));

    expect(
      events.whereType<GenericNfcDetected>().length,
      1,
      reason: "Should emit exactly one GenericNfcDetected",
    );
    expect(
      events.whereType<TestMatchingEvent>().length,
      1,
      reason: "Should emit exactly one TestMatchingEvent",
    );
  });

  test('Stream emits IdleDetection when null is received', () async {
    final events = <NfcDetection>[];

    container.listen<AsyncValue<NfcDetection>>(nfcDetectionStreamProvider, (
      previous,
      next,
    ) {
      next.whenData(events.add);
    }, fireImmediately: true);

    mockNfcService.emitTag(null);

    await Future.delayed(const Duration(milliseconds: 100));

    expect(events.isNotEmpty, isTrue);
    expect(events.last, isA<IdleDetection>());
  });

  test(
    'Stream emits GenericNfcDetected when no specific detection matches',
    () async {
      final tag = createData("NOMATCH:123");
      final events = <NfcDetection>[];

      container.listen<AsyncValue<NfcDetection>>(nfcDetectionStreamProvider, (
        previous,
        next,
      ) {
        next.whenData(events.add);
      }, fireImmediately: true);

      mockNfcService.emitTag(tag);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(events.any((e) => e is GenericNfcDetected), isTrue);
      expect(events.any((e) => e is TestMatchingEvent), isFalse);
    },
  );

  test('Read Error prevents other detections', () async {
    final errorTag = MockNfcDataWithError("IO Error");
    final events = <NfcDetection>[];

    container.listen<AsyncValue<NfcDetection>>(nfcDetectionStreamProvider, (
      previous,
      next,
    ) {
      next.whenData(events.add);
    });

    mockNfcService.emitTag(errorTag);

    await Future.delayed(const Duration(milliseconds: 100));

    expect(events.any((e) => e is NfcError), isTrue);
    expect(events.any((e) => e is GenericNfcDetected), isFalse);
    expect(events.any((e) => e is TestMatchingEvent), isFalse);
  });
}
