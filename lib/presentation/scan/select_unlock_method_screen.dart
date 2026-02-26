import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portable_sec/presentation/widgets/appscaffold.dart';

import '../../domain/value_objects/lock_method.dart';
import '../../router_provider.dart';
import '../app_colors.dart';

class SelectUnlockMethodScreen extends ConsumerWidget {
  final String encryptedText;
  final int capacity;

  const SelectUnlockMethodScreen({super.key, required this.encryptedText, required this.capacity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const extraBase = {'isManualUnlockRequired': true};

    return AppScaffold(
      appBar: AppBar(title: const Text('ロック解除方法の選択')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
            child: Text(
              'このデータを開くには正しい解除方法を指定する必要があります。\n解除方法を選択してください。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 15,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                _UnlockMethodTile(
                  icon: Icons.password_rounded,
                  label: 'パスワード',
                  onTap: () =>
                      _navigateTo(context, AppRoute.unlockPassword, LockType.password, extraBase),
                ),
                _UnlockMethodTile(
                  icon: Icons.pattern_rounded,
                  label: 'パターン',
                  onTap: () =>
                      _navigateTo(context, AppRoute.unlockPattern, LockType.pattern, extraBase),
                ),
                _UnlockMethodTile(
                  icon: Icons.pin_rounded,
                  label: 'PIN',
                  onTap: () => _navigateTo(context, AppRoute.unlockPin, LockType.pin, extraBase),
                ),
                _UnlockMethodTile(
                  icon: Icons.verified_user_rounded,
                  label: 'パターン + PIN',
                  onTap: () => _navigateTo(
                    context,
                    AppRoute.unlockPattern,
                    LockType.patternAndPin,
                    extraBase,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(
    BuildContext context,
    AppRoute route,
    LockType lockType,
    Map<String, bool> extraBase,
  ) {
    context.pushNamed(
      route.name,
      extra: {
        'encryptedText': encryptedText,
        'lockType': lockType.index,
        'capacity': capacity,
        ...extraBase,
      },
    );
  }
}

class _UnlockMethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UnlockMethodTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: AppColors.accent.withValues(alpha: 0.15),
        highlightColor: AppColors.accent.withValues(alpha: 0.08),
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.30),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: Theme.of(context).colorScheme.onPrimary),
              ),
              const SizedBox(height: 16),
              Text(label, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}
