import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portable_sec/presentation/widgets/appscaffold.dart';

import '../../../application/providers/creation_providers.dart';
import '../../../domain/value_objects/lock_method.dart';
import '../../../router_provider.dart';
import '../../widgets/pattern_lock.dart';

class ConfigLockPage extends ConsumerWidget {
  const ConfigLockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creationProvider);
    final notifier = ref.read(creationProvider.notifier);

    ref.listen(creationProvider, (prev, next) {
      if (next.step == CreationStep.write &&
          (prev?.step != CreationStep.write)) {
        context.goNamed(AppRoute.creationWrite.name);
      }
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    String instruction = "${_getMethodName(state.selectedType)} を入力してください";
    if (state.selectedType == LockType.patternAndPin) {
      if (state.isLockSecondStage) {
        instruction = "PIN を入力してください (2/2)";
      } else {
        instruction = "パターン を入力してください (1/2)";
      }
    }

    if (state.isConfirming) {
      instruction = "確認のため、もう一度入力してください";
    }

    return AppScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('新規データ作成 (4/5)'),
        leading: state.isConfirming
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // If in second stage of Pattern+Pin, back goes to first stage
                  if (state.selectedType == LockType.patternAndPin &&
                      state.isLockSecondStage) {
                    notifier
                        .retryLockInput(); // This resets current stage, but we need to go back to stage 1?
                    // Actually retryLockInput resets verifying state.
                    // We probably need a 'backToStageOne' logic if we want strict back navigation.
                    // For now, let's assume the user completes the flow.
                    // Or, we can use the existing back button to go back to CIN.
                    // Wait, if isLockSecondStage is true, "back" should probably go back to Pattern input.
                    // But retryLockInput clears *current* input.
                    // To go back to stage 1, we need to reset isLockSecondStage.
                    // We don't have a direct method exposed for that easily without clearing everything.
                    // Let's rely on standard flow or add a specific method if needed.
                    // For simplicity, if they want to change pattern, they can restart from CIN or use "Retry".
                    // Ideally, leading button goes back to previous screen (CIN).
                  }

                  notifier.backToInputData();
                  context.goNamed(AppRoute.creationInput.name);
                },
              ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Text(
                instruction,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 24),

              // Input Widget based on type
              if (state.selectedType == LockType.pin ||
                  (state.selectedType == LockType.patternAndPin &&
                      state.isLockSecondStage))
                _buildPinInput(context, state, notifier)
              else if (state.selectedType == LockType.password)
                _buildPasswordInput(notifier, state)
              else if (state.selectedType == LockType.pattern ||
                  (state.selectedType == LockType.patternAndPin &&
                      !state.isLockSecondStage))
                _buildPatternInput(context, state, notifier, ref)
              else
                const Center(child: Text("この方式の入力UIは未実装です")),

              const Spacer(),

              if (state.selectedType == LockType.password ||
                  state.selectedType == LockType.pin ||
                  (state.selectedType == LockType.patternAndPin &&
                      state.isLockSecondStage))
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state.isConfirming) ...[
                      TextButton(
                        onPressed: notifier.retryLockInput,
                        child: const Text("やり直す"),
                      ),
                      const SizedBox(width: 16),
                    ],
                    ElevatedButton(
                      onPressed: state.lockInput.isNotEmpty
                          ? notifier.nextFromLockConfig
                          : null,
                      child: const Text("次へ"),
                    ),
                  ],
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _getMethodName(LockType type) {
    switch (type) {
      case LockType.pin:
        return "PIN";
      case LockType.password:
        return "パスワード";
      case LockType.pattern:
        return "パターン";
      case LockType.patternAndPin:
        return "パターンとPIN";
    }
  }

  Widget _buildPasswordInput(CreationNotifier notifier, CreationState state) {
    return TextField(
      key: ValueKey("password_input_${state.isConfirming}"),
      onChanged: notifier.updateLockInput,
      obscureText: true,
      onSubmitted: (_) {
        if (state.lockInput.isNotEmpty) {
          notifier.nextFromLockConfig();
        }
      },
      decoration: const InputDecoration(border: OutlineInputBorder()),
    );
  }

  Widget _buildPatternInput(
    BuildContext context,
    CreationState state,
    CreationNotifier notifier,
    WidgetRef ref,
  ) {
    return Column(
      children: [
        PatternLock(
          key: ValueKey("pattern_${state.isConfirming}"),
          value: state.lockInput,
          onChanged: (val) {
            notifier.updateLockInput(val);
          },
          onComplete: (val) {
            notifier.nextFromLockConfig();
          },
          onError: (msg) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(msg)));
          },
          dimension: 3,
        ),
        const SizedBox(height: 10),
        if (state.isConfirming)
          TextButton(
            onPressed: notifier.retryLockInput,
            child: const Text("やり直す"),
          )
        else
          Text("入力: ${state.lockInput.length} 点"),
      ],
    );
  }

  Widget _buildPinInput(
    BuildContext context,
    CreationState state,
    CreationNotifier notifier,
  ) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            state.lockInput.replaceAll(RegExp(r'.'), '*'),
            style: const TextStyle(fontSize: 24, letterSpacing: 4),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 280,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (context, index) {
              if (index == 9) return const SizedBox();
              if (index == 11) {
                return IconButton(
                  icon: const Icon(Icons.backspace_outlined),
                  onPressed: () {
                    if (state.lockInput.isNotEmpty) {
                      notifier.updateLockInput(
                        state.lockInput.substring(
                          0,
                          state.lockInput.length - 1,
                        ),
                      );
                    }
                  },
                );
              }

              int number = (index + 1) % 11;
              if (index == 10) number = 0;

              return OutlinedButton(
                onPressed: () {
                  if (state.lockInput.length < 20) {
                    notifier.updateLockInput(
                      state.lockInput + number.toString(),
                    );
                  }
                },
                child: Text(
                  "$number",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
