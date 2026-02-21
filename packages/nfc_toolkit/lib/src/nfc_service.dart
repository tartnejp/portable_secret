import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Add defaultTargetPlatform
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/ndef_record.dart'; // Explicit import for NdefRecord
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart'; // Required for TypeNameFormat, NdefRecord etc in v4
import 'nfc_data.dart';

// --- Interface & Data Types ---

abstract class NfcService {
  Future<Stream<NfcWriteState>> startWrite(
    List<NfcWriteData> dataList, {
    bool allowOverwrite = false,
    void Function(String)? onError,
  });

  Future<void> init();

  /// Starts a session with an explicit timeout and callbacks.
  /// Used primarily for controlled explicit scans on iOS, or timed scans on Android.
  void startSessionWithTimeout({
    String? alertMessage,
    Duration? timeout,
    VoidCallback? onTimeout,
    void Function(String)? onError,
  });

  /// Explicitly starts an iOS scan session.
  /// This is a convenience wrapper around [startSessionWithTimeout] with default iOS behavior.
  void startSessionForIOS({
    String? alertMessage,
    Duration? timeout,
    VoidCallback? onTimeout,
    void Function(String)? onError,
  });

  /// Resets the NFC session to background idle mode.
  /// On iOS, this triggers the native scan UI and can show [alertMessage].
  void resetSession({String? alertMessage, void Function(String)? onError});

  /// Stream of tags detected while not in explicit scan/write mode
  Stream<NfcData?> get backgroundTagStream;

  /// Stream of raw NFC errors caught during sessions (e.g., user canceled)
  Stream<NfcError> get errorStream;

  /// Retrieves the tag data that triggered the app launch, if any.
  /// This should be consumed once.
  Future<NfcData?> getInitialTag();
}

sealed class NfcWriteState {}

class NfcWriteLoading extends NfcWriteState {}

class NfcWriteSuccess extends NfcWriteState {}

class NfcWriteOverwriteRequired extends NfcWriteState {}

class NfcWriteError extends NfcWriteState {
  final String message;
  NfcWriteError(this.message);
}

class NfcCapacityError extends NfcWriteError {
  final int required;
  final int available;
  NfcCapacityError(this.required, this.available)
    : super("容量不足: 必要 $required bytes / 空き $available bytes");
}

sealed class NfcWriteData {}

class NfcWriteDataUri extends NfcWriteData {
  final Uri uri;
  NfcWriteDataUri(this.uri);
}

class NfcWriteDataText extends NfcWriteData {
  final String text;
  NfcWriteDataText(this.text);
}

class NfcWriteDataMime extends NfcWriteData {
  final String type;
  final List<int> data;
  NfcWriteDataMime(this.type, this.data);
}

class NfcWriteDataExternal extends NfcWriteData {
  final String domain;
  final String type;
  final List<int> data;
  NfcWriteDataExternal(this.domain, this.type, this.data);
}

class NfcWriteDataCustom extends NfcWriteData {
  final List<int> payload;
  final int tnf;
  final List<int> type;
  final List<int> id;

  NfcWriteDataCustom({
    required this.payload,
    required this.tnf,
    required this.type,
    required this.id,
  });
}

// --- Implementation ---

class NfcServiceImpl with WidgetsBindingObserver implements NfcService {
  static final NfcServiceImpl instance = NfcServiceImpl._internal();

  // Configurable channel name
  final String _methodChannelName;
  late final MethodChannel _platform;

  factory NfcServiceImpl({String? methodChannelName}) {
    if (methodChannelName != null &&
        methodChannelName != instance._methodChannelName) {
      // Re-configure if needed (Singletons usually shouldn't be reconfigured, but for package flexibility)
      // Ideally this is handled by DI, but for singleton usage:
      return NfcServiceImpl._internal(methodChannelName: methodChannelName);
    }
    return instance;
  }

  NfcServiceImpl._internal({String? methodChannelName})
    : _methodChannelName = methodChannelName ?? 'com.example.nfc_toolkit/nfc' {
    _platform = MethodChannel(_methodChannelName);
    _backgroundTagController = StreamController<NfcData?>.broadcast(
      onListen: _onBackgroundTagListen,
    );
    _errorController = StreamController<NfcError>.broadcast();
  }

  // Streams
  StreamController<NfcWriteState>? _writeController;
  late final StreamController<NfcData?> _backgroundTagController;
  late final StreamController<NfcError> _errorController;
  NfcData? _initialTag;
  bool _initialTagConsumed = false;
  NfcData? _bufferedTag;
  bool _isIosSessionActive = false;

  void _onBackgroundTagListen() {
    if (_bufferedTag != null) {
      _backgroundTagController.add(_bufferedTag);
      _bufferedTag = null;
    }
  }

  // Dynamic tag handler strategy
  Future<void> Function(NfcTag)? _onTagDiscovered;
  Timer? _sessionTimeout;

  @override
  Stream<NfcData?> get backgroundTagStream => _backgroundTagController.stream;

  @override
  Stream<NfcError> get errorStream => _errorController.stream;

  @override
  Future<NfcData?> getInitialTag() async {
    if (_initialTagConsumed) {
      return null;
    }
    _initialTagConsumed = true;
    return _initialTag;
  }

  @override
  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    await _checkLaunchIntent();
    _onTagDiscovered = _handleBackgroundTag;

    NfcManager.instance.checkAvailability().then((available) {
      if (available != NfcAvailability.enabled) {
        // Handle error if needed
      }
    });

    // if (defaultTargetPlatform != TargetPlatform.iOS) {
    //   _startNfcSession();
    // }
  }

  void _startNfcSession({
    String? alertMessage,
    Duration? timeout,
    VoidCallback? onTimeout,
    void Function(String)? onError,
  }) {
    _sessionTimeout?.cancel();

    if (timeout != null) {
      _sessionTimeout = Timer(timeout, () {
        NfcManager.instance
            .stopSession(errorMessageIos: 'タイムアウトしました')
            .catchError((_) {});

        // Native OS closed, trigger callback if provided
        if (onTimeout != null) {
          onTimeout();
        }

        final errorMsg = 'タイムアウトしました';
        if (_writeController != null && !_writeController!.isClosed) {
          _writeController!.add(NfcWriteError(errorMsg));
        } else if (_errorController.hasListener) {
          _errorController.add(NfcError(message: errorMsg));
        }
      });
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      _isIosSessionActive = true;
    }

    NfcManager.instance
        .startSession(
          pollingOptions: NfcPollingOption.values.toSet(),
          alertMessageIos: alertMessage ?? 'スキャンの準備ができました',
          onDiscovered: (tag) async {
            _sessionTimeout?.cancel();
            if (_onTagDiscovered != null) {
              await _onTagDiscovered!(tag);
            }
          },
          onSessionErrorIos: (error) {
            _sessionTimeout?.cancel();
            if (defaultTargetPlatform == TargetPlatform.iOS) {
              _isIosSessionActive = false;
            }
            final dynamic e = error;
            final String errorMsg = e.message.toString();

            if (onError != null) {
              onError(errorMsg);
            }

            if (_writeController != null && !_writeController!.isClosed) {
              _writeController!.add(NfcWriteError(errorMsg));
            } else if (_errorController.hasListener) {
              _errorController.add(NfcError(message: errorMsg));
            }
          },
        )
        .catchError((e) {
          _sessionTimeout?.cancel();
          if (defaultTargetPlatform == TargetPlatform.iOS) {
            _isIosSessionActive = false;
          }
          // Push the raw error directly so the UI can log/copy it.
          final errorMsg = e.toString();

          if (onError != null) {
            onError(errorMsg);
          }

          if (_writeController != null && !_writeController!.isClosed) {
            _writeController!.add(NfcWriteError(errorMsg));
          } else if (_errorController.hasListener) {
            _errorController.add(NfcError(message: errorMsg));
          }
        });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (defaultTargetPlatform == TargetPlatform.iOS)
      return; // Prevent auto-start on resume for iOS

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          _isIosSessionActive = false;
        }
        NfcManager.instance.stopSession();
        break;
      case AppLifecycleState.resumed:
        // _startNfcSession();
        break;
      default:
        break;
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      _isIosSessionActive = false;
    }
    NfcManager.instance.stopSession();
    _cleanupStream();
    _backgroundTagController.close();
    _errorController.close();
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
      type: Uint8List.fromList([0x55]),
      identifier: Uint8List(0),
      payload: Uint8List.fromList(payload),
    );
  }

  NdefRecord _createTextRecord(String text) {
    const languageCode = 'en';
    final languageBytes = utf8.encode(languageCode);
    final textBytes = utf8.encode(text);
    final statusByte = languageBytes.length;
    final payload = <int>[statusByte, ...languageBytes, ...textBytes];
    return NdefRecord(
      typeNameFormat: TypeNameFormat.wellKnown,
      type: Uint8List.fromList([0x54]),
      identifier: Uint8List(0),
      payload: Uint8List.fromList(payload),
    );
  }

  @override
  Future<Stream<NfcWriteState>> startWrite(
    List<NfcWriteData> dataList, {
    bool allowOverwrite = false,
    void Function(String)? onError,
  }) async {
    _cleanupStream();
    _writeController = StreamController<NfcWriteState>();
    _onTagDiscovered = (tag) async {
      await _handleWriteTag(tag, dataList, allowOverwrite);
    };
    try {
      // Allow enough time for stopSession to complete on iOS,
      // as starting immediately after can cause "Multiple sessions cannot be active".
      if (defaultTargetPlatform != TargetPlatform.iOS || _isIosSessionActive) {
        await NfcManager.instance.stopSession().timeout(
          const Duration(milliseconds: 500),
        );
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          _isIosSessionActive = false;
          await Future.delayed(
            const Duration(milliseconds: 300),
          ); // Delay for UI animation to clear
        }
      }
    } catch (_) {}
    _startNfcSession(
      onError: onError,
      timeout: defaultTargetPlatform == TargetPlatform.iOS
          ? const Duration(seconds: 10)
          : null,
    );
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
      if (ndef == null) throw Exception('Tag is not NDEF compatible');
      if (!ndef.isWritable) throw Exception('Tag is not writable');

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

  @override
  void resetSession({
    String? alertMessage,
    void Function(String)? onError,
  }) async {
    _cleanupStream();
    _sessionTimeout?.cancel();
    _onTagDiscovered = _handleBackgroundTag;

    // Clear the current stream state by adding null (Idle)
    if (_backgroundTagController.hasListener) {
      _backgroundTagController.add(null);
    }

    try {
      if (defaultTargetPlatform != TargetPlatform.iOS || _isIosSessionActive) {
        await NfcManager.instance.stopSession().timeout(
          const Duration(milliseconds: 500),
        );
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          _isIosSessionActive = false;
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    } catch (_) {}

    _startNfcSession(
      alertMessage: alertMessage,
      onError: onError,
      timeout: defaultTargetPlatform == TargetPlatform.iOS
          ? const Duration(seconds: 10)
          : null,
    );
  }

  @override
  void startSessionWithTimeout({
    String? alertMessage,
    Duration? timeout,
    VoidCallback? onTimeout,
    void Function(String)? onError,
  }) async {
    _cleanupStream();
    _sessionTimeout?.cancel();
    _onTagDiscovered = _handleBackgroundTag;

    try {
      if (defaultTargetPlatform != TargetPlatform.iOS || _isIosSessionActive) {
        await NfcManager.instance.stopSession().timeout(
          const Duration(milliseconds: 500),
        );
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          _isIosSessionActive = false;
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    } catch (_) {}

    _startNfcSession(
      alertMessage: alertMessage,
      timeout: timeout,
      onTimeout: onTimeout,
      onError: onError,
    );
  }

  @override
  void startSessionForIOS({
    String? alertMessage,
    Duration? timeout,
    VoidCallback? onTimeout,
    void Function(String)? onError,
  }) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    startSessionWithTimeout(
      alertMessage: alertMessage,
      timeout: timeout ?? const Duration(seconds: 10),
      onTimeout: onTimeout,
      onError: onError,
    );
  }

  void _cleanupStream() {
    if (_writeController != null && !_writeController!.isClosed) {
      _writeController!.close();
    }
    _writeController = null;
  }

  Future<void> _checkLaunchIntent() async {
    try {
      final dynamic result = await _platform.invokeMethod(
        'getLaunchNdefMessage',
      );
      if (result != null && result is Map) {
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

        // Store as initial tag
        _initialTag = data;
      }
    } catch (e) {
      // Ignored
    }
  }
}
