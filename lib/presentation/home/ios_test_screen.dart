import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc_toolkit/nfc_toolkit.dart';

class IosTestScreen extends ConsumerStatefulWidget {
  const IosTestScreen({super.key});

  @override
  ConsumerState<IosTestScreen> createState() => _IosTestScreenState();
}

class _IosTestScreenState extends ConsumerState<IosTestScreen> {
  String _status = '待機中';
  bool _isScanning = false;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    // Listen directly to the raw NFC data stream
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscription = ref.read(nfcServiceProvider).backgroundTagStream.listen((
        data,
      ) {
        if (data != null && mounted) {
          setState(() {
            _status =
                'タグを検出しました！\n種類: ${data.tagType}\nUID: ${data.formatIdentifier()}';
            _isScanning = false;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _status = 'スキャン中...';
      _isScanning = true;
    });

    ref
        .read(nfcServiceProvider)
        .startSessionWithTimeout(
          alertMessage: 'NFCタグをタッチしてください',
          onTimeout: () {
            if (mounted) {
              setState(() {
                _status = 'タイムアウトしました';
                _isScanning = false;
              });
            }
          },
          onError: (errorMsg) {
            if (mounted) {
              setState(() {
                _status = 'エラー: $errorMsg';
                _isScanning = false;
              });
            }
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('iOS NFC 単体テスト画面')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ステータス:\n$_status',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              if (_isScanning)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _startScan,
                  child: const Text('読み取り開始 (startSessionWithTimeout)'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
