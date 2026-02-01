import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/value_objects/lock_method.dart';

import '../../infrastructure/repositories/draft_repository_impl.dart';
import '../../application/providers/nfc_detection_provider.dart';
import '../../application/providers/di/services_provider.dart';

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
      ref
          .read(nfcDetectionStrategyProvider.notifier)
          .setStrategy(SecretNfcDetectionStrategy());
      // Force reset session to ensure we are listening fresh
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
    // Note: ref access in dispose can be tricky, but usually safe for simple reads if container alive.
    // However, to be safe from provider disposal issues, we might skip it or handle gracefully.
    // But standard pattern is to unsubscribe.
    // We wrap in try-catch in case provider is already gone (though unlikely here).
    try {
      ref.read(routeObserverProvider).unsubscribe(this);
    } catch (_) {}
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when we return to this screen from another screen
    debugPrint("HomeScreen: didPopNext -> Resetting NFC Session");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(nfcServiceProvider).resetSession();
      ref
          .read(nfcDetectionStrategyProvider.notifier)
          .setStrategy(SecretNfcDetectionStrategy());
      if (mounted) {
        setState(() {
          _statusMessage = 'NFCタグをタッチしてください';
          _isReading = false;
        });
      }
    });
  }

  String _statusMessage = 'NFCタグをタッチしてください';
  bool _isReading = false;

  @override
  Widget build(BuildContext context) {
    // Listen to NfcDetectionEvent for Secrets
    ref.listen(nfcDetectionEventProvider, (prev, next) {
      next.whenData((event) {
        setState(() => _isReading = true);

        event.when(
          generic: (_) {
            setState(() {
              _statusMessage = '未登録、または不明なNFCタグです';
              _isReading = false;
            });
          },
          secretFound: (encryptedText, foundLockMethod) {
            setState(() => _isReading = false);
            if (foundLockMethod == null) {
              if (mounted) {
                context.pushNamed(
                  'SEL',
                  extra: {'encryptedText': encryptedText},
                );
              }
            } else {
              String routeName;
              switch (foundLockMethod.type) {
                case LockType.password:
                  routeName = 'UPS';
                  break;
                case LockType.pin:
                  routeName = 'UPI';
                  break;
                case LockType.pattern:
                case LockType.patternAndPin:
                  routeName = 'UPA';
                  break;
              }
              context.pushNamed(
                routeName,
                extra: {
                  'encryptedText': encryptedText,
                  'lockType': foundLockMethod.type.index,
                },
              );
            }
          },
        );
      });

      if (next.isLoading) {
        // Optionally handle loading state from the stream if needed,
        // though the stream usually just emits events.
      }

      if (next.hasError) {
        setState(() {
          _statusMessage = 'エラーが発生しました: ${next.error}';
          _isReading = false;
        });
      }
    });

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
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
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
                    context.goNamed('CLT');
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
                // Delete
                Navigator.of(context).pop();
                final draftRepo = ref.read(wizardDraftRepositoryProvider);
                await draftRepo.deleteDraft();

                if (context.mounted) {
                  context.goNamed('CLT');
                }
              },
              child: const Text(
                "破棄して新規作成",
                style: TextStyle(color: Colors.red),
              ),
            ),
            FilledButton(
              onPressed: () async {
                // Restore
                Navigator.of(context).pop();
                if (context.mounted) {
                  // Navigate to start page with restore flag
                  context.goNamed('CLT', extra: {'restore': true});
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
