import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import '../widgets/pattern_lock.dart';
import '../../application/providers/encryption_providers.dart';
import '../../router_provider.dart';
import '../../domain/value_objects/lock_method.dart';
import 'secret_view_screen.dart'; // Import for SecretViewArgs

class UnlockPatternScreen extends ConsumerStatefulWidget {
  final String? encryptedText;
  final int? lockType;
  final int? capacity;
  final bool isManualUnlockRequired;

  const UnlockPatternScreen({
    super.key,
    this.encryptedText,
    this.lockType,
    this.capacity,
    this.isManualUnlockRequired = false,
  });

  @override
  ConsumerState<UnlockPatternScreen> createState() =>
      _UnlockPatternScreenState();
}

class _UnlockPatternScreenState extends ConsumerState<UnlockPatternScreen> {
  // ignore: unused_field
  String _pattern = "";
  bool _isLoading = false;

  void _onPatternChange(String pattern) {
    setState(() {
      _pattern = pattern;
    });
  }

  Future<void> _onPatternComplete(String pattern) async {
    if (widget.encryptedText == null) return;

    // Pattern+PINの場合の分岐
    // LockType.patternAndPin (index 3)
    if (widget.lockType == 3) {
      if (mounted) {
        context.pushNamed(
          AppRoute.unlockPin.name,
          extra: {
            'encryptedText': widget.encryptedText,
            'pattern': pattern,
            'lockType': widget.lockType,
            'capacity': widget.capacity,
            'isManualUnlockRequired': widget.isManualUnlockRequired,
          },
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bytes = base64Decode(widget.encryptedText!);
      final service = ref.read(encryptionServiceProvider);
      final secret = await service.decrypt(bytes, pattern);

      if (mounted) {
        // Transition to next screen (content view)
        // Transition using GoRouter
        final args = SecretViewArgs(
          secret: secret,
          lockType: widget.lockType != null
              ? LockType.values[widget.lockType!]
              : LockType.pattern, // Fallback?
          isManualUnlockRequired: widget.isManualUnlockRequired,
          capacity: widget.capacity ?? 0,
        );
        context.pushNamed(AppRoute.secretView.name, extra: args);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ロック解除に失敗しました')));
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
    return Scaffold(
      appBar: AppBar(title: const Text('パターンで解除')),
      body: Column(
        children: [
          const SizedBox(height: 32),
          const Text('パターンを入力してください', style: TextStyle(fontSize: 16)),
          const Spacer(),
          Center(
            child: _isLoading
                ? const CircularProgressIndicator()
                : PatternLock(
                    onChanged: _onPatternChange,
                    onComplete: _onPatternComplete,
                    dimension: 3,
                    value: _pattern,
                  ),
          ),
          const Spacer(),
          const SizedBox(height: 50), // Reserve space where button was
        ],
      ),
    );
  }
}
