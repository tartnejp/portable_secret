import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc_toolkit/nfc_toolkit.dart'; // Imports nfcServiceProvider, NfcDetectionRefExtension, GenericNfcDetected
import 'package:portable_sec/presentation/widgets/appscaffold.dart';

import '../../application/nfc/secret_detected.dart'; // Imports SecretDetection
import '../../domain/value_objects/lock_method.dart';
import '../../infrastructure/repositories/draft_repository_impl.dart';
import '../../router_provider.dart';
import '../app_colors.dart';

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

  /// デバッグパネルの表示フラグ。true にすると画面下部にログパネルが表示される。
  static const bool _kShowDebugPanel = false;

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
    ref.listen<AsyncValue<NfcDetection>>(nfcDetectionStreamProvider, (previous, next) {
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
                extra: {'encryptedText': encryptedText, 'capacity': detection.capacity},
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
    return AppScaffold(
      appBar: AppBar(title: const Text('Portable Sec')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(flex: 4),
          // NFCアイコン（アクセントカラー）
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.nfc, size: 60, color: AppColors.accent),
          ),
          SizedBox(height: (defaultTargetPlatform == TargetPlatform.iOS) ? 72 : 18),
          NfcSessionTriggerWidget(
            instructionText: _statusMessage,
            buttonText: 'NFCタグの読み取りを開始',
            onStartSession: (onError) {
              if (mounted) {
                setState(() {
                  _statusMessage = 'NFCカードを検知すると読み取り開始します';
                });
              }
              _addLog('startSession() called');
              ref.read(nfcServiceProvider).startSession();
            },
          ),
          if (_kShowDebugPanel) ...[
            const SizedBox(height: 24),
            // DEBUG LOG (HomeScreen events + Toolkit internal)
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('── UI ──', style: TextStyle(color: AppColors.accent, fontSize: 10)),
                  Expanded(
                    child: SingleChildScrollView(
                      reverse: true,
                      child: Text(
                        _debugLog.join('\n'),
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    '── Toolkit ──',
                    style: TextStyle(color: AppColors.accent, fontSize: 10),
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
                              color: Color(0xFF80DEEA), // cyanAccent相当
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
          ],
          SizedBox(height: (defaultTargetPlatform == TargetPlatform.iOS) ? 24 : 72),

          //・ 新規作成ボタン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              height: 80,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.background,
                ),
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
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: AppColors.accent, size: 18),
                ),
                label: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: const Text('新しく秘密データを入力してNFCカードに保存する'),
                ),
              ),
            ),
          ),
          Spacer(flex: 6),
        ],
      ),
    );
  }

  Future<void> _showDraftDialog(BuildContext context, WidgetRef ref) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text("下書きが見つかりました", style: TextStyle(color: AppColors.textPrimary)),
          content: const Text(
            "以前作成したデータの下書きが残っています。\n復元しますか？",
            style: TextStyle(color: AppColors.textSecondary),
          ),
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
              child: const Text("破棄して新規作成", style: TextStyle(color: AppColors.error)),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (context.mounted) {
                  context.goNamed(AppRoute.creationLockType.name, extra: {'restore': true});
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.background,
              ),
              child: const Text("復元する", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
