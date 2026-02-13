import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../router_provider.dart';
import '../../../application/providers/creation_providers.dart';
import '../../../domain/value_objects/lock_method.dart';
import '../../../domain/value_objects/secret_data.dart'; // Import SecretData
import '../../../application/services/capacity_calculator.dart';
import '../../scan/secret_view_screen.dart'; // Import SecretViewArgs

class InputDataPage extends ConsumerStatefulWidget {
  const InputDataPage({super.key});

  @override
  ConsumerState<InputDataPage> createState() => _InputDataPageState();
}

class _InputDataPageState extends ConsumerState<InputDataPage> {
  final _keyController = TextEditingController();
  final _valController = TextEditingController();

  void _startAdd() {
    _keyController.clear();
    _valController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '項目を追加',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _keyController,
                  decoration: const InputDecoration(
                    labelText: '項目名',
                    hintText: '例: ユーザー名',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _valController,
                  decoration: const InputDecoration(
                    label: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '値 '),
                          TextSpan(
                            text: '*',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    hintText: '例: user1',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Stop/Cancel Button
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.grey,
                            size: 36,
                          ),
                          onPressed: () {
                            _keyController.clear();
                            _valController.clear();
                            Navigator.of(context).pop();
                          },
                          tooltip: 'キャンセル',
                        ),
                        const Text(
                          "キャンセル",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    // Check/OK Button
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.blue,
                            size: 36,
                          ),
                          onPressed: () {
                            if (_valController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('値を入力してください')),
                              );
                              return;
                            }
                            ref
                                .read(creationProvider.notifier)
                                .addItem(
                                  _keyController.text,
                                  _valController.text,
                                );
                            _keyController.clear();
                            _valController.clear();
                            context.pop();
                          },
                          tooltip: 'OK',
                        ),
                        const Text(
                          "OK",
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(creationProvider);
    final notifier = ref.read(creationProvider.notifier);

    // Watch for step change to navigate next
    ref.listen(creationProvider, (prev, next) {
      if (next.step == CreationStep.lockConfig &&
          (prev?.step != CreationStep.lockConfig)) {
        context.goNamed(AppRoute.creationConfig.name);
      }
      if (next.isDraftSaved && !(prev?.isDraftSaved ?? false)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("下書きを保存しました")));
        context.pop(); // Return to Home on save? The original code did.
      }
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('新規データ作成 (3/5)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (state.isEditMode) {
              // Edit Mode: Return to SecretViewScreen
              final args = SecretViewArgs(
                secret: SecretData(items: state.items),
                lockType: state.selectedType,
                isManualUnlockRequired: state.isManualUnlockRequired,
                capacity: state.maxCapacity,
              );
              context.goNamed(AppRoute.secretView.name, extra: args);
            } else {
              notifier.backToCapacityCheck();
              context.goNamed(AppRoute.creationCapacity.name);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Lock Type Selector
            Row(
              children: [
                const Text(
                  "ロック方式: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                DropdownButton<LockType>(
                  value: state.selectedType,
                  items: const [
                    DropdownMenuItem(
                      value: LockType.pattern,
                      child: Text("パターン"),
                    ),
                    DropdownMenuItem(value: LockType.pin, child: Text("PIN")),
                    DropdownMenuItem(
                      value: LockType.patternAndPin,
                      child: Text("パターン + PIN"),
                    ),
                    DropdownMenuItem(
                      value: LockType.password,
                      child: Text("パスワード"),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      notifier.selectMethod(val);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "ロック解除時の方式（パスワード/PIN/パターン）選択",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            RadioListTile<bool>(
              title: const Text("解除方式も選択を必須とする（安全）"),
              value: true,
              groupValue: state.isManualUnlockRequired,
              onChanged: (val) {
                if (val != null) notifier.updateUnlockPreference(val);
              },
              dense: true,
            ),
            RadioListTile<bool>(
              title: const Text("解除方式を自動判別して選択不要とする"),
              value: false,
              groupValue: state.isManualUnlockRequired,
              onChanged: (val) {
                if (val != null) notifier.updateUnlockPreference(val);
              },
              dense: true,
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Input Area
            // Item List Label
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "保存するデータ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Add Button
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.blue),
                iconSize: 48,
                onPressed: _startAdd,
                tooltip: '項目を追加',
              ),
            ),

            // Item List
            Expanded(
              child: ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        item.key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item.value),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                        onPressed: () => notifier.removeItem(index),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Capacity Logic
            Builder(
              builder: (context) {
                final usedBytes = CapacityCalculator.calculateTotalBytes(
                  state.items,
                );
                final maxCapacity = state.maxCapacity;
                final isOver = maxCapacity > 0 && usedBytes > maxCapacity;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "容量: $usedBytes / $maxCapacity Bytes",
                    style: TextStyle(
                      color: isOver ? Colors.red : Colors.grey,
                      fontWeight: isOver ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
            // Navigation Buttons (Save Draft & Next)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await notifier.saveDraft();
                  },
                  icon: const Icon(Icons.save_alt),
                  label: const Text("下書き保存"),
                ),
                ElevatedButton(
                  key: const Key('next_step_button'),
                  onPressed:
                      (state.items.isNotEmpty &&
                          (state.maxCapacity == 0 ||
                              CapacityCalculator.calculateTotalBytes(
                                    state.items,
                                  ) <=
                                  state.maxCapacity))
                      ? notifier
                            .nextFromInputData // triggers state change to LockConfig
                      : null,
                  child: const Text("次へ (ロック設定)"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
