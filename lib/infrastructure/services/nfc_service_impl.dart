import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';
import 'nfc_components/nfc_data.dart';
import '../../application/services/nfc_service_interface.dart';

class NfcServiceImpl with WidgetsBindingObserver implements NfcService {
  static final NfcServiceImpl instance = NfcServiceImpl._internal();

  NfcServiceImpl._internal() {
    _backgroundTagController = StreamController<NfcData>.broadcast(
      onListen: _onBackgroundTagListen,
    );
  }

  // Streams
  StreamController<NfcWriteState>? _writeController;
  late final StreamController<NfcData> _backgroundTagController;
  NfcData? _bufferedTag;

  void _onBackgroundTagListen() {
    if (_bufferedTag != null) {
      _backgroundTagController.add(_bufferedTag!);
      _bufferedTag = null;
    }
  }

  // Dynamic tag handler strategy
  Future<void> Function(NfcTag)? _onTagDiscovered;

  @override
  Stream<NfcData> get backgroundTagStream => _backgroundTagController.stream;

  @override
  Future<void> init() async {
    // ライフサイクル監視を即座に追加
    WidgetsBinding.instance.addObserver(this);

    // checkAvailabilityを待たずにセッションを開始
    _startNfcSession();

    // コールドスタート用のIntent起動チェック（MethodChannel経由）
    _checkLaunchIntent();

    // Default to background handler
    _onTagDiscovered = _handleBackgroundTag;

    NfcManager.instance.checkAvailability().then((available) {
      if (available != NfcAvailability.enabled) {
        // 必要に応じてエラーハンドリング
      }
    });
  }

  void _startNfcSession() {
    NfcManager.instance
        .startSession(
          pollingOptions: NfcPollingOption.values.toSet(),
          onDiscovered: (tag) async {
            if (_onTagDiscovered != null) {
              await _onTagDiscovered!(tag);
            }
          },
        )
        .then((_) {})
        .catchError((e) {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // バックグラウンドになったらセッション停止
        NfcManager.instance.stopSession();
        break;
      case AppLifecycleState.resumed:
        // フォアグラウンドに戻ったら再開
        _startNfcSession();
        break;
      default:
        break;
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NfcManager.instance.stopSession();
    _cleanupStream();
    _backgroundTagController.close();
  }

  Future<void> _handleBackgroundTag(NfcTag tag) async {
    try {
      final data = NfcData(tag);
      if (_backgroundTagController.hasListener) {
        _backgroundTagController.add(data);
      } else {
        _bufferedTag = data;
      }
    } catch (e) {
      // Ignored
    }
  }

  // --- Manual NDEF Record Creation Helpers ---

  NdefRecord _createRecord(NfcWriteData data) {
    if (data is NfcWriteDataUri) {
      return _createUriRecord(data.uri);
    } else if (data is NfcWriteDataText) {
      return _createTextRecord(data.text);
    } else if (data is NfcWriteDataMime) {
      return NdefRecord(
        typeNameFormat: TypeNameFormat.media,
        type: Uint8List.fromList(utf8.encode(data.type)),
        identifier: Uint8List(0),
        payload: Uint8List.fromList(data.data),
      );
    } else if (data is NfcWriteDataExternal) {
      return NdefRecord(
        typeNameFormat: TypeNameFormat.external,
        type: Uint8List.fromList(utf8.encode('${data.domain}:${data.type}')),
        identifier: Uint8List(0),
        payload: Uint8List.fromList(data.data),
      );
    } else if (data is NfcWriteDataCustom) {
      return NdefRecord(
        typeNameFormat: TypeNameFormat.values[data.tnf],
        type: Uint8List.fromList(data.type),
        identifier: Uint8List.fromList(data.id),
        payload: Uint8List.fromList(data.payload),
      );
    }
    throw UnimplementedError('Unknown NfcWriteData type');
  }

  NdefRecord _createUriRecord(Uri uri) {
    final uriString = uri.toString();
    int prefixCode = 0x00;
    String content = uriString;

    // Basic prefix mapping (can be expanded)
    if (uriString.startsWith('https://www.')) {
      prefixCode = 0x02;
      content = uriString.substring(12);
    } else if (uriString.startsWith('http://www.')) {
      prefixCode = 0x01;
      content = uriString.substring(11);
    } else if (uriString.startsWith('https://')) {
      prefixCode = 0x04;
      content = uriString.substring(8);
    } else if (uriString.startsWith('http://')) {
      prefixCode = 0x03;
      content = uriString.substring(7);
    }

    final payload = <int>[prefixCode, ...utf8.encode(content)];

    return NdefRecord(
      typeNameFormat: TypeNameFormat.wellKnown,
      type: Uint8List.fromList([0x55]), // 'U'
      identifier: Uint8List(0),
      payload: Uint8List.fromList(payload),
    );
  }

  NdefRecord _createTextRecord(String text) {
    // English language code 'en' for simplicity
    final languageCode = 'en';
    final languageBytes = utf8.encode(languageCode);
    final textBytes = utf8.encode(text);

    // Status byte: bit 7 (status) = 0 (UTF-8), bit 6 reserved = 0, bits 5-0 length of lang code
    final statusByte = languageBytes.length;

    final payload = <int>[statusByte, ...languageBytes, ...textBytes];

    return NdefRecord(
      typeNameFormat: TypeNameFormat.wellKnown,
      type: Uint8List.fromList([0x54]), // 'T'
      identifier: Uint8List(0),
      payload: Uint8List.fromList(payload),
    );
  }

  @override
  Future<Stream<NfcWriteState>> startWrite(
    List<NfcWriteData> dataList, {
    bool allowOverwrite = false,
  }) async {
    _cleanupStream();
    _writeController = StreamController<NfcWriteState>();

    // Use closure to capture state for this specific write request
    _onTagDiscovered = (tag) async {
      await _handleWriteTag(tag, dataList, allowOverwrite);
    };

    // Force session restart to ensure immediate detection
    await NfcManager.instance.stopSession();
    _startNfcSession();

    _writeController!.add(NfcWriteLoading());
    return _writeController!.stream;
  }

  Future<void> _handleWriteTag(
    NfcTag tag,
    List<NfcWriteData> targetData,
    bool allowOverwrite,
  ) async {
    if (_writeController == null) return;

    try {
      final ndef = Ndef.from(tag);
      if (ndef == null) {
        throw Exception('Tag is not NDEF compatible');
      }
      if (!ndef.isWritable) {
        throw Exception('Tag is not writable');
      }

      // Check for existing data
      final nfcData = NfcData(tag);
      final currentMessage = await nfcData.getOrReadMessage();

      if (!allowOverwrite &&
          currentMessage != null &&
          currentMessage.records.isNotEmpty) {
        _writeController!.add(NfcWriteOverwriteRequired());
        return;
      }

      final records = targetData.map(_createRecord).toList();
      final message = NdefMessage(records: records);

      // Capacity Check
      if (message.byteLength > ndef.maxSize) {
        _writeController!.add(
          NfcCapacityError(message.byteLength, ndef.maxSize),
        );
        return;
      }

      await ndef.write(message: message);
      _writeController!.add(NfcWriteSuccess());
    } catch (e) {
      _writeController!.add(NfcWriteError(e.toString()));
    }
  }

  // @override
  // void confirmOverwrite() removed

  @override
  void resetSession() {
    _cleanupStream();

    // Reset handler to background listener
    _onTagDiscovered = _handleBackgroundTag;

    // writing/scanning セッションが終わったので、バックグラウンド監視用のセッションを再開する
    // (既にセッションが生きていても、モード切替を確実にするため呼ぶのが無難だが、多重起動に注意)
    // ここでは念の為 stop -> start する
    NfcManager.instance
        .stopSession()
        .catchError((_) {
          // Ignore errors when stopping session (e.g. if it wasn't running)
        })
        .whenComplete(() {
          _startNfcSession();
        });
  }

  void _cleanupStream() {
    if (_writeController != null && !_writeController!.isClosed) {
      _writeController!.close();
    }
    _writeController = null;
  }

  // MethodChannel for cold start check
  static const platform = MethodChannel('com.toolart.portablesec/nfc');

  Future<void> _checkLaunchIntent() async {
    try {
      final dynamic result = await platform.invokeMethod(
        'getLaunchNdefMessage',
      );
      if (result != null && result is Map) {
        // Parse the Map into NdefMessage
        final records = (result['records'] as List).map((r) {
          return NdefRecord(
            typeNameFormat: TypeNameFormat.values[r['typeNameFormat'] as int],
            type: r['type'] as Uint8List,
            identifier: r['identifier'] as Uint8List,
            payload: r['payload'] as Uint8List,
          );
        }).toList();

        final message = NdefMessage(records: records);
        final data = NfcData.fromManual(message);

        // Use standard buffer logic
        _bufferedTag = data;

        // If listener is already there (rare case if init is fast), flush it
        if (_backgroundTagController.hasListener) {
          _backgroundTagController.add(data);
          _bufferedTag = null;
        }
      }
    } catch (e) {
      // Ignored
    }
  }
}
