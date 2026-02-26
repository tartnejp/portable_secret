import 'dart:async';

import 'package:flutter/material.dart';

/// An overlay widget that displays an unlock failure message.
/// It automatically dismisses after 2 seconds or can be manually closed.
class UnlockFailureOverlay extends StatefulWidget {
  final String lockMethodHint;
  final VoidCallback? onDismissed;

  const UnlockFailureOverlay({super.key, required this.lockMethodHint, this.onDismissed});

  @override
  State<UnlockFailureOverlay> createState() => _UnlockFailureOverlayState();
}

class _UnlockFailureOverlayState extends State<UnlockFailureOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _animationController.forward();
    _startAutoDismissTimer();
  }

  void _startAutoDismissTimer() {
    _dismissTimer = Timer(const Duration(seconds: 2), () {
      _dismiss();
    });
  }

  void _dismiss() {
    _dismissTimer?.cancel();
    _animationController.reverse().then((_) {
      widget.onDismissed?.call();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.black54,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _dismiss,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Icon(Icons.lock_outline, size: 48, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'ロック解除できません。\nロック方式あるいは${widget.lockMethodHint}を確認してください',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows an unlock failure overlay and returns a function to dismiss it.
VoidCallback showUnlockFailureOverlay(BuildContext context, {required String lockMethodHint}) {
  late OverlayEntry overlayEntry;
  bool _removed = false;

  void removeOverlay() {
    if (_removed) return;
    _removed = true;
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  }

  overlayEntry = OverlayEntry(
    builder: (context) =>
        UnlockFailureOverlay(lockMethodHint: lockMethodHint, onDismissed: removeOverlay),
  );

  Overlay.of(context).insert(overlayEntry);

  return removeOverlay;
}
