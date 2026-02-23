import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc_toolkit/nfc_toolkit.dart';
import '../../../router_provider.dart';
import '../../../application/providers/creation_providers.dart';

class CapacityCheckPage extends ConsumerStatefulWidget {
  const CapacityCheckPage({super.key});

  @override
  ConsumerState<CapacityCheckPage> createState() => _CapacityCheckPageState();
}

class _CapacityCheckPageState extends ConsumerState<CapacityCheckPage> {
  @override
  void initState() {
    super.initState();
    debugPrint('CapacityCheckPage: initState');
  }

  void _checkTransition(CreationState? previous, CreationState next) {
    if (next.step == CreationStep.inputData &&
        (previous?.step != CreationStep.inputData)) {
      context.goNamed(AppRoute.creationInput.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('CapacityCheckPage: build');
    final state = ref.watch(creationProvider);
    final notifier = ref.read(creationProvider.notifier);

    ref.listen(creationProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
      _checkTransition(prev, next);
    });

    // Capture tag capacity via GenericNfcDetected (any NFC tag, not just app tags)
    ref.listenNfcDetection<GenericNfcDetected>(context, (detection) async {
      final capacity = detection.nfcMaxSize ?? 137; // fallback to NTAG213
      notifier.selectManualCapacity(capacity);
      return NfcSessionAction.success(message: '容量を計測しました ($capacity bytes)');
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('新規データ作成 (2/5)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            notifier.backToMethodSelection();
            context.goNamed(AppRoute.creationLockType.name);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.nfc, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              NfcSessionTriggerWidget(
                instructionText: "NFCカードをタッチしてください\n書き込み可能なデータサイズを計測します",
                buttonText: '計測開始',
                onStartSession: (onError) {
                  ref.read(nfcServiceProvider).startSession();
                },
              ),
              const SizedBox(height: 48),
              TextButton(
                onPressed: () => _showManualSelectDialog(context, notifier),
                child: const Text(
                  "手動で選択する",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showManualSelectDialog(
    BuildContext context,
    CreationNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("NTAG213 (137 bytes)"),
              onTap: () {
                notifier.selectManualCapacity(137);
                Navigator.pop(context); // Close bottom sheet
              },
            ),
            ListTile(
              title: const Text("NTAG215 (492 bytes)"),
              onTap: () {
                notifier.selectManualCapacity(492);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("NTAG216 (868 bytes)"),
              onTap: () {
                notifier.selectManualCapacity(868);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
