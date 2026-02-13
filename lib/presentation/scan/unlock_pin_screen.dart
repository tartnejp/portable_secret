import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import '../../application/providers/encryption_providers.dart';
import '../../router_provider.dart';
import '../../domain/value_objects/lock_method.dart';
import 'secret_view_screen.dart'; // Import for SecretViewArgs

class UnlockPinScreen extends ConsumerStatefulWidget {
  final String? encryptedText;
  final String? pattern;
  final int? lockType;
  final int? capacity;
  final bool isManualUnlockRequired;

  const UnlockPinScreen({
    super.key,
    this.encryptedText,
    this.pattern,
    this.lockType,
    this.capacity,
    this.isManualUnlockRequired = false,
  });

  @override
  ConsumerState<UnlockPinScreen> createState() => _UnlockPinScreenState();
}

class _UnlockPinScreenState extends ConsumerState<UnlockPinScreen> {
  String _inputPin = "";
  bool _isLoading = false;

  void _onDigitPress(String digit) {
    if (_inputPin.length < 20) {
      setState(() {
        _inputPin += digit;
      });
    }
  }

  void _onDeletePress() {
    if (_inputPin.isNotEmpty) {
      setState(() {
        _inputPin = _inputPin.substring(0, _inputPin.length - 1);
      });
    }
  }

  Future<void> _unlock() async {
    if (widget.encryptedText == null) return;
    if (_inputPin.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final bytes = base64Decode(widget.encryptedText!);
      final service = ref.read(encryptionServiceProvider);

      String inputSecret = _inputPin;
      if (widget.pattern != null) {
        inputSecret = "${widget.pattern}:$_inputPin";
      }

      final secret = await service.decrypt(bytes, inputSecret);

      if (mounted) {
        final args = SecretViewArgs(
          secret: secret,
          lockType: widget.lockType != null
              ? LockType.values[widget.lockType!]
              : LockType.pin, // Fallback
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
      appBar: AppBar(title: const Text('PINで解除')),
      body: Column(
        children: [
          const SizedBox(height: 32),
          const Text('PINを入力してください', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          // Display Area
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _inputPin.replaceAll(RegExp(r'.'), '*'),
              style: const TextStyle(fontSize: 24, letterSpacing: 4),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          // Keypad
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: SizedBox(
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
                  if (index == 9) return const SizedBox(); // Empty space
                  if (index == 11) {
                    return IconButton(
                      icon: const Icon(Icons.backspace_outlined),
                      onPressed: _isLoading ? null : _onDeletePress,
                    );
                  }

                  int number = (index + 1) % 11;
                  if (index == 10) number = 0;

                  return OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _onDigitPress(number.toString()),
                    child: Text(
                      "$number",
                      style: const TextStyle(fontSize: 24),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: (_isLoading || _inputPin.isEmpty) ? null : _unlock,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('解除'),
            ),
          ),
        ],
      ),
    );
  }
}
