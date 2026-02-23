import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/value_objects/lock_method.dart';
import '../../infrastructure/repositories/draft_repository_impl.dart';
import 'package:nfc_toolkit/nfc_toolkit.dart'; // Imports nfcServiceProvider, NfcDetectionRefExtension, GenericNfcDetected
import '../../application/nfc/secret_detected.dart'; // Imports SecretDetection
// import '../../application/nfc/url_detection.dart'; // Imports UrlDetection (optional usage)

import '../../router_provider.dart';
import '../widgets/nfc_info_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    // Initialize the detection strategy for secrets
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Force reset session to ensure we are listening fresh on Start/Rebuild
      if (defaultTargetPlatform != TargetPlatform.iOS) {
        ref.read(nfcServiceProvider).startSession();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final observer = ref.read(routeObserverProvider);
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      observer.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    try {
      ref.read(routeObserverProvider).unsubscribe(this);
    } catch (_) {}
    super.dispose();
  }

  @override
  void didPushNext() {
    // No longer need to track _isResumed — Toolkit handles frontmost check
  }

  @override
  void didPopNext() {
    // Called when we return to this screen from another screen
    debugPrint("HomeScreen: didPopNext -> Resetting NFC Session");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        if (defaultTargetPlatform != TargetPlatform.iOS) {
          ref.read(nfcServiceProvider).startSession();
        }
      }
    });

    if (mounted) {
      setState(() {
        _statusMessage = 'NFCタグをタッチしてください';
      });
    }
  }

  String _statusMessage = 'NFCタグをタッチしてください';
  final List<String> _debugLog = [];

  void _addLog(String msg) {
    if (mounted) {
      setState(() {
        _debugLog.add('${DateTime.now().toString().substring(11, 19)} $msg');
        if (_debugLog.length > 10) _debugLog.removeAt(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // DEBUG: Listen to raw stream to see what's coming through
    ref.listen<AsyncValue<NfcDetection>>(nfcDetectionStreamProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (d) => _addLog('STREAM: ${d.runtimeType}'),
        error: (e, _) => _addLog('STREAM ERR: $e'),
        loading: () => _addLog('STREAM: loading'),
      );
    });

    // Listen for Secret Detection
    ref.listenNfcDetection<SecretDetection>(context, (detection) async {
      _addLog('SECRET handler fired');
      // Frontmost check is handled automatically by Toolkit

      final foundLockMethod = detection.foundLockMethod;
      final encryptedText = detection.encryptedText!;

      return NfcSessionAction.success(
        message: 'ロック解除画面へ移動します',
        onComplete: () {
          if (foundLockMethod == null) {
            if (mounted) {
              context.pushNamed(
                AppRoute.selectUnlock.name,
                extra: {
                  'encryptedText': encryptedText,
                  'capacity': detection.capacity,
                },
              );
            }
          } else {
            String routeName = AppRoute.unlockPattern.name;
            switch (foundLockMethod.type) {
              case LockType.password:
                routeName = AppRoute.unlockPassword.name;
                break;
              case LockType.pin:
                routeName = AppRoute.unlockPin.name;
                break;
              case LockType.pattern:
              case LockType.patternAndPin:
                routeName = AppRoute.unlockPattern.name;
                break;
            }
            if (mounted) {
              context.pushNamed(
                routeName,
                extra: {
                  'encryptedText': encryptedText,
                  'lockType': foundLockMethod.type.index,
                  'capacity': detection.capacity,
                  'isManualUnlockRequired': false,
                },
              );
            }
          }
        },
      );
    });

    // Listen for Generic NFC (non-app tags) → show message on scan sheet and re-enable scanning
    ref.listenNfcDetection<GenericNfcDetected>(context, (detection) async {
      _addLog('GENERIC handler fired');
      return NfcSessionAction.error(
        message: 'このアプリで作成されたタグではありません',
        onComplete: () {
          if (mounted) {
            ref.read(nfcServiceProvider).startSession();
          }
        },
      );
    });

    // Listen for Read Errors
    ref.listenNfcDetection<NfcError>(context, (detection) async {
      _addLog('ERROR handler fired: ${detection.message}');
      if (mounted) {
        setState(() {
          _statusMessage = '読み取りエラー: 再度タッチしてください';
        });
      }
      return NfcSessionAction.error(message: '読み取りエラーが発生しました');
    });

    // Optional: Listen for URL Detection
    return Scaffold(
      appBar: AppBar(title: const Text('Portable Sec')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.nfc, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: NfcSessionTriggerWidget(
                    instructionText: _statusMessage,
                    buttonText: 'NFCタグの読み取りを開始',
                    onStartSession: (onError) {
                      if (mounted) {
                        setState(() {
                          _statusMessage = 'NFCタグをタッチしてください';
                        });
                      }
                      _addLog('startSession() called');
                      ref.read(nfcServiceProvider).startSession();
                    },
                  ),
                ),
                const NfcInfoButton(
                  message:
                      'iPhoneやiPadが反応しないNFCタグがあります。このような場合はデータに関わらず本アプリでも扱えません。'
                      'その際は、NFC Toolsというアプリでタグの初期化を実施の上、書き込みを行ってください。',
                  url: 'https://apps.apple.com/jp/app/nfc-tools/id1252962749',
                ),
              ],
            ),
            const SizedBox(height: 24),
            // DEBUG LOG (HomeScreen events + Toolkit internal)
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '── UI ──',
                    style: TextStyle(color: Colors.yellow, fontSize: 10),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      reverse: true,
                      child: Text(
                        _debugLog.join('\n'),
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    '── Toolkit ──',
                    style: TextStyle(color: Colors.yellow, fontSize: 10),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      reverse: true,
                      child: Consumer(
                        builder: (_, ref, __) {
                          final tkLog = ref.watch(nfcDebugLogProvider);
                          return Text(
                            tkLog.join('\n'),
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ElevatedButton.icon(
              onPressed: () async {
                final draftRepo = ref.read(wizardDraftRepositoryProvider);
                final hasDraft = await draftRepo.hasDraft();

                if (context.mounted) {
                  if (hasDraft) {
                    _showDraftDialog(context, ref);
                  } else {
                    context.goNamed(AppRoute.creationLockType.name);
                  }
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('新しく秘密データを入力してNFCカードに保存する'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDraftDialog(BuildContext context, WidgetRef ref) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("下書きが見つかりました"),
          content: const Text("以前作成したデータの下書きが残っています。\n復元しますか？"),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final draftRepo = ref.read(wizardDraftRepositoryProvider);
                await draftRepo.deleteDraft();

                if (context.mounted) {
                  context.goNamed(AppRoute.creationLockType.name);
                }
              },
              child: const Text(
                "破棄して新規作成",
                style: TextStyle(color: Colors.red),
              ),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (context.mounted) {
                  context.goNamed(
                    AppRoute.creationLockType.name,
                    extra: {'restore': true},
                  );
                }
              },
              child: const Text("復元する"),
            ),
          ],
        );
      },
    );
  }
}
