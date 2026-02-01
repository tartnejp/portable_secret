import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/value_objects/lock_method.dart';

class SelectUnlockMethodScreen extends ConsumerWidget {
  final String encryptedText;

  const SelectUnlockMethodScreen({super.key, required this.encryptedText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('ロック解除方法の選択')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'このデータを開くには正しい解除方法を指定する必要があります。\n解除方法を選択してください。',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('パスワード'),
            onTap: () {
              context.pushNamed(
                'UPS',
                extra: {
                  'encryptedText': encryptedText,
                  'lockType': LockType.password.index,
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.pattern),
            title: const Text('パターン'),
            onTap: () {
              context.pushNamed(
                'UPA',
                extra: {
                  'encryptedText': encryptedText,
                  'lockType': LockType.pattern.index,
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.pin),
            title: const Text('PIN'),
            onTap: () {
              context.pushNamed(
                'UPI',
                extra: {
                  'encryptedText': encryptedText,
                  'lockType': LockType.pin.index,
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('パターン + PIN'),
            onTap: () {
              context.pushNamed(
                'UPA',
                extra: {
                  'encryptedText': encryptedText,
                  'lockType': LockType.patternAndPin.index,
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
