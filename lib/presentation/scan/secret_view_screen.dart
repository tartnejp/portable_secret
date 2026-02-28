import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portable_sec/presentation/widgets/appscaffold.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../application/providers/creation_providers.dart';
import '../../domain/value_objects/lock_method.dart';
import '../../domain/value_objects/secret_data.dart';
import '../../router_provider.dart';

// Define arguments class for type safety
class SecretViewArgs {
  final SecretData secret;
  final LockType lockType;
  final bool isManualUnlockRequired;
  final int capacity;

  SecretViewArgs({
    required this.secret,
    required this.lockType,
    required this.isManualUnlockRequired,
    required this.capacity,
  });
}

class SecretViewScreen extends ConsumerWidget {
  final SecretViewArgs args;
  const SecretViewScreen({super.key, required this.args});

  Widget _buildValueText(BuildContext context, String value) {
    // Check if the value is a valid URL
    final isUrl = value.startsWith('http://') || value.startsWith('https://');

    final valueStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
      fontSize: 20,
    );

    if (isUrl) {
      return InkWell(
        onTap: () async {
          final uri = Uri.tryParse(value);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('URLを開けませんでした')));
            }
          }
        },
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
            fontSize: 20,
          ),
        ),
      );
    } else {
      return SelectableText(value, style: valueStyle);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final secret = args.secret;
    return AppScaffold(
      appBar: AppBar(
        title: const Text('復号された情報'),
        automaticallyImplyLeading: false, // AppBarの戻るボタンを非表示
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: secret.items.length,
              itemBuilder: (context, index) {
                final item = secret.items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.key,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(child: _buildValueText(context, item.value)),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              right: 8.0,
                            ),
                            constraints: const BoxConstraints(),
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: item.value),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${item.key}をコピーしました'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // "Edit" Flow
                        ref
                            .read(creationProvider.notifier)
                            .initializeForEdit(
                              args.secret,
                              args.lockType,
                              args.isManualUnlockRequired,
                              args.capacity,
                            );
                        context.goNamed(AppRoute.creationInput.name);
                      },
                      child: const Text('編集する'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.goNamed(AppRoute.home.name);
                      },
                      child: const Text('ホーム画面に戻る'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
