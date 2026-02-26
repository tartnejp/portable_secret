import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portable_sec/presentation/widgets/appscaffold.dart';

import '../../application/providers/encryption_providers.dart';
import '../../domain/value_objects/lock_method.dart';
import '../../router_provider.dart';
import '../widgets/unlock_failure_overlay.dart';
import 'secret_view_screen.dart'; // Import for SecretViewArgs

class UnlockPasswordScreen extends ConsumerStatefulWidget {
  final String? encryptedText;
  final int? lockType;
  final int? capacity;
  final bool isManualUnlockRequired;

  const UnlockPasswordScreen({
    super.key,
    this.encryptedText,
    this.lockType,
    this.capacity,
    this.isManualUnlockRequired = false,
  });

  @override
  ConsumerState<UnlockPasswordScreen> createState() => _UnlockPasswordScreenState();
}

class _UnlockPasswordScreenState extends ConsumerState<UnlockPasswordScreen> {
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (widget.encryptedText == null) return;
    if (_passwordController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final bytes = base64Decode(widget.encryptedText!);
      final service = ref.read(encryptionServiceProvider);
      final secret = await service.decrypt(bytes, _passwordController.text);

      if (mounted) {
        final args = SecretViewArgs(
          secret: secret,
          lockType: widget.lockType != null ? LockType.values[widget.lockType!] : LockType.password,
          isManualUnlockRequired: widget.isManualUnlockRequired,
          capacity: widget.capacity ?? 0,
        );
        context.pushNamed(AppRoute.secretView.name, extra: args);
      }
    } catch (e) {
      if (mounted) {
        showUnlockFailureOverlay(context, lockMethodHint: 'パスワード');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('パスワードで解除')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('パスワードを入力してロックを解除してください', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'パスワード',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: (_isLoading || _passwordController.text.isEmpty) ? null : _unlock,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('解除'),
            ),
          ],
        ),
      ),
    );
  }
}
