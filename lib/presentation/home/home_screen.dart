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

  @override
  Widget build(BuildContext context) {
    // Listen for Secret Detection
    ref.listenNfcDetection<SecretDetection>(context, (detection) async {
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
            NfcSessionTriggerWidget(
              instructionText: _statusMessage,
              buttonText: 'NFCタグの読み取りを開始',
              onStartSession: (onError) {
                if (mounted) {
                  setState(() {
                    _statusMessage = 'NFCタグをタッチしてください';
                  });
                }
                ref.read(nfcServiceProvider).startSession();
              },
            ),
            const SizedBox(height: 48),
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
