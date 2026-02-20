import 'package:flutter/material.dart';
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
      ref.read(nfcServiceProvider).resetSession();
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
    // Called when we navigate away from this screen
    _isResumed = false;
  }

  @override
  void didPopNext() {
    // Called when we return to this screen from another screen
    debugPrint("HomeScreen: didPopNext -> Resetting NFC Session");
    _isResumed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        ref.read(nfcServiceProvider).resetSession();
      }
    });

    if (mounted) {
      setState(() {
        _statusMessage = 'NFCタグをタッチしてください';
        _isReading = false;
      });
    }
  }

  String _statusMessage = 'NFCタグをタッチしてください';
  bool _isReading = false;
  bool _isResumed = true; // Tracks if this screen is currently top-most

  @override
  Widget build(BuildContext context) {
    // Listen for Secret Detection
    ref.listenNfcDetection<SecretDetection>((detection) {
      if (!_isResumed)
        return; // Ignore detections if we are not the active screen

      setState(() => _isReading = false);
      final foundLockMethod = detection.foundLockMethod;
      final encryptedText = detection.encryptedText!;

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
    });

    // Listen for Generic/Unknown Detection (Update UI message)
    ref.listenNfcDetection<GenericNfcDetected>((detection) {
      setState(() {
        _statusMessage = '未登録、または不明なNFCタグです';
        _isReading = false;
      });
      // Note: Overlay might be suppressed by NfcDetectionScope configuration for Home,
      // but this local state update ensures the UI text changes.
    });

    // Listen for Read Errors
    ref.listenNfcDetection<NfcError>((detection) {
      setState(() {
        _statusMessage = '読み取りエラー: 再度タッチしてください';
        _isReading = false;
      });
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
            if (_isReading)
              const CircularProgressIndicator()
            else
              NfcSessionTriggerWidget(
                instructionText: _statusMessage,
                buttonText: '読み取り開始',
                onStartSession: () {
                  setState(() {
                    _statusMessage = 'NFCタグをタッチしてください';
                  });
                  ref.read(nfcServiceProvider).resetSession();
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
