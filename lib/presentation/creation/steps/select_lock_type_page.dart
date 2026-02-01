import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/creation_providers.dart';
import '../../../domain/value_objects/lock_method.dart';

class SelectLockTypePage extends ConsumerStatefulWidget {
  const SelectLockTypePage({super.key});

  @override
  ConsumerState<SelectLockTypePage> createState() => _SelectLockTypePageState();
}

class _SelectLockTypePageState extends ConsumerState<SelectLockTypePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      if (extra != null && extra['restore'] == true) {
        _restoreDraft();
      }
    });
  }

  Future<void> _restoreDraft() async {
    final notifier = ref.read(creationProvider.notifier);
    await notifier.loadDraft();
    if (!mounted) return;

    final state = ref.read(creationProvider);
    // Navigate based on step
    switch (state.step) {
      case CreationStep.methodSelection:
        // Already here
        break;
      case CreationStep.capacityCheck:
        context.goNamed('CCA');
        break;
      case CreationStep.inputData:
        context.goNamed('CIN');
        break;
      case CreationStep.lockConfig:
        context.goNamed('CCF');
        break;
      case CreationStep.write:
        context.goNamed('CWR');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('SelectLockTypePage: build');
    final state = ref.watch(creationProvider);
    final notifier = ref.read(creationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('新規データ作成 (1/5)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('HOM'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "どの方式でロックをかけますか？",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildOption(context, notifier, state, LockType.pattern, "パターン"),
            _buildOption(context, notifier, state, LockType.pin, "PIN (数字のみ)"),
            _buildOption(
              context,
              notifier,
              state,
              LockType.patternAndPin,
              "パターン + PIN",
            ),
            _buildOption(
              context,
              notifier,
              state,
              LockType.password,
              "パスワード (文字と数字)",
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                key: const Key('next_button_method_selection'),
                onPressed: () {
                  debugPrint(
                    'SelectLockTypePage: Next button pressed. Current location: ${GoRouterState.of(context).matchedLocation}',
                  );
                  // Update state to match next step
                  notifier.nextFromMethodSelection();
                  // Navigate
                  context.goNamed('CCA');
                },
                child: const Text("次へ"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    CreationNotifier notifier,
    CreationState state,
    LockType type,
    String label,
  ) {
    return ListTile(
      key: type == LockType.pattern ? const Key('option_pattern') : null,
      title: Text(label),
      leading: Radio<LockType>(
        value: type,
        groupValue: state.selectedType,
        onChanged: (v) {
          if (v != null) notifier.selectMethod(v);
        },
      ),
      onTap: () => notifier.selectMethod(type),
    );
  }
}
