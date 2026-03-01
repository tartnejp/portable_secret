import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc_toolkit/nfc_toolkit.dart';

import '../../application/nfc/secret_detected.dart';
import '../../domain/value_objects/lock_method.dart';
import '../../router_provider.dart';
import '../widgets/nfc_info_button.dart';

class PromptRescanScreen extends ConsumerStatefulWidget {
  const PromptRescanScreen({super.key});

  @override
  ConsumerState<PromptRescanScreen> createState() => _PromptRescanScreenState();
}

class _PromptRescanScreenState extends ConsumerState<PromptRescanScreen> {
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
              context.pushReplacementNamed(
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
              context.pushReplacementNamed(
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

    // GenericNfcDetected is now handled internally by NfcDetectionScope
    // (no longer flows through the stream)

    // Listen for Read Errors
    ref.listenNfcDetection<NfcError>(context, (detection) async {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('読み取りエラー。もう一度タッチしてください。')));
      }
      return NfcSessionAction.error(message: '読み取りエラーが発生しました');
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('データの読み取り'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.goNamed(AppRoute.home.name),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.nfc, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            NfcSessionTriggerWidget(
              instructionText: 'アプリが起動しました。\nデータを復号するために\nもう一度NFCタグをタッチしてください。',
              buttonText: 'NFCタグの読み取りを開始',
              infoButton: const NfcInfoButton(),
              onStartSession: (onError) {
                ref.read(nfcServiceProvider).startSession();
              },
            ),
          ],
        ),
      ),
    );
  }
}
