import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portable_sec/presentation/widgets/appscaffold.dart';

import '../../../application/providers/creation_providers.dart';
import '../../../domain/value_objects/lock_method.dart';
import '../../../router_provider.dart';
import '../../app_colors.dart';

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
      } else {
        ref.read(creationProvider.notifier).reset();
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
        context.goNamed(AppRoute.creationCapacity.name);
        break;
      case CreationStep.inputData:
        context.goNamed(AppRoute.creationInput.name);
        break;
      case CreationStep.lockConfig:
        context.goNamed(AppRoute.creationConfig.name);
        break;
      case CreationStep.write:
        context.goNamed(AppRoute.creationWrite.name);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('SelectLockTypePage: build');
    final state = ref.watch(creationProvider);
    final notifier = ref.read(creationProvider.notifier);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('新規データ作成 (1/5)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(AppRoute.home.name),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
            child: Text(
              'どの方式でロックをかけますか？',
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
                _LockTypeTile(
                  icon: Icons.pattern_rounded,
                  label: 'パターン',
                  isSelected: state.selectedType == LockType.pattern,
                  onTap: () => notifier.selectMethod(LockType.pattern),
                ),
                _LockTypeTile(
                  icon: Icons.pin_rounded,
                  label: 'PIN',
                  isSelected: state.selectedType == LockType.pin,
                  onTap: () => notifier.selectMethod(LockType.pin),
                ),
                _LockTypeTile(
                  icon: Icons.verified_user_rounded,
                  label: 'パターン + PIN',
                  isSelected: state.selectedType == LockType.patternAndPin,
                  onTap: () => notifier.selectMethod(LockType.patternAndPin),
                ),
                _LockTypeTile(
                  icon: Icons.password_rounded,
                  label: 'パスワード',
                  isSelected: state.selectedType == LockType.password,
                  onTap: () => notifier.selectMethod(LockType.password),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: ElevatedButton(
              key: const Key('next_button_method_selection'),
              onPressed: () {
                debugPrint(
                  'SelectLockTypePage: Next button pressed. Current location: ${GoRouterState.of(context).matchedLocation}',
                );
                // Update state to match next step
                notifier.nextFromMethodSelection();
                // Navigate
                context.goNamed(AppRoute.creationCapacity.name);
              },
              child: const Text("次へ"),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockTypeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LockTypeTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

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
              color: isSelected
                  ? AppColors.accent
                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.30),
              width: isSelected ? 2.5 : 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: Theme.of(context).colorScheme.onPrimary),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
