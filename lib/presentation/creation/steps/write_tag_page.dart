import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc_toolkit/nfc_toolkit.dart';
import 'package:portable_sec/presentation/widgets/appscaffold.dart';

import '../../../application/providers/creation_providers.dart';
import '../../../router_provider.dart';

class WriteTagPage extends ConsumerStatefulWidget {
  const WriteTagPage({super.key});

  @override
  ConsumerState<WriteTagPage> createState() => _WriteTagPageState();
}

class _WriteTagPageState extends ConsumerState<WriteTagPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(creationProvider);

    ref.listen(creationProvider, (previous, next) {
      if (next.isSuccess && !(previous?.isSuccess ?? false)) {
        // Close the iOS scan sheet with a success message before showing the dialog
        ref
            .read(nfcServiceProvider)
            .stopSession(alertMessage: '書き込みが成功しました')
            .then((_) => _showSuccessDialog());
      }
      if (next.error != null && next.error != previous?.error) {
        // Show error but don't clear it immediately to avoid flickering loop if it persists?
      }
    });

    return AppScaffold(
      appBar: AppBar(
        title: const Text('新規データ作成 (5/5)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(creationProvider.notifier).backToLockConfig();
            context.goNamed(AppRoute.creationConfig.name);
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
              const Icon(Icons.nfc, size: 100, color: Colors.orange),
              const SizedBox(height: 24),
              NfcSessionTriggerWidget(
                instructionText: "NFCカードをタッチしてください\n(書き込み待機中...)",
                buttonText: "書き込み開始",
                onStartSession: (onError) {
                  ref.read(creationProvider.notifier).writeToNfc(onError: onError);
                },
              ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("書き込みが成功しました"),
              const SizedBox(height: 16),
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(creationProvider.notifier).finishWriting();
                Navigator.of(context).pop(); // Close Dialog
                context.goNamed(AppRoute.home.name); // Go to Home
              },
              child: const Text("ホームへ戻る"),
            ),
          ],
        );
      },
    );
  }
}
