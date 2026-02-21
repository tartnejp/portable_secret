import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc_toolkit/nfc_toolkit.dart';

import '../../application/nfc/secret_detected.dart';
import '../../domain/value_objects/lock_method.dart';
import '../../router_provider.dart';

class PromptRescanScreen extends ConsumerStatefulWidget {
  const PromptRescanScreen({super.key});

  @override
  ConsumerState<PromptRescanScreen> createState() => _PromptRescanScreenState();
}

class _PromptRescanScreenState extends ConsumerState<PromptRescanScreen>
    with RouteAware {
  bool _isResumed = true;

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
    _isResumed = false;
  }

  @override
  void didPopNext() {
    _isResumed = true;
  }

  @override
  Widget build(BuildContext context) {
    // Listen for Secret Detection
    ref.listenNfcDetection<SecretDetection>((detection) {
      if (!_isResumed) return;

      final foundLockMethod = detection.foundLockMethod;
      final encryptedText = detection.encryptedText!;

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
    });

    // Listen for Generic/Unknown Detection
    ref.listenNfcDetection<GenericNfcDetected>((detection) {
      // Show failure snackbar, tell them to tap again
      if (mounted && _isResumed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未対応のタグです。もう一度正しいタグをタッチしてください。')),
        );
      }
    });

    // Listen for Read Errors
    ref.listenNfcDetection<NfcError>((detection) {
      if (mounted && _isResumed) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('読み取りエラー。もう一度タッチしてください。')));
      }
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
              onStartSession: (onError) {
                ref
                    .read(nfcServiceProvider)
                    .startSessionForIOS(onError: onError);
              },
            ),
          ],
        ),
      ),
    );
  }
}
