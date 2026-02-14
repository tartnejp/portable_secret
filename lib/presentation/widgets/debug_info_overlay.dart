import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/package_info_provider.dart';
import 'package:go_router/go_router.dart';

class DebugInfoOverlay extends StatelessWidget {
  final Widget child;
  final GoRouter? router;

  const DebugInfoOverlay({super.key, required this.child, this.router});

  @override
  Widget build(BuildContext context) {
    //todo 戻す
    // if (!kDebugMode) {
    //   return child;
    // }

    return Stack(
      children: [
        child,
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 8,
          child: IgnorePointer(child: _ScreenIdDisplay(router: router)),
        ),
      ],
    );
  }
}

class _ScreenIdDisplay extends ConsumerWidget {
  final GoRouter? router;
  const _ScreenIdDisplay({this.router});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch Router State to update when route changes
    final router = this.router ?? GoRouter.of(context);

    return StreamBuilder(
      stream: router.routeInformationProvider.value.uri.toString() == ""
          ? null
          : Stream.periodic(
              const Duration(milliseconds: 500),
            ), // Polling fallback or listener?
      // Better: ListenableBuilder or AnimatedBuilder on routerDelegate.
      builder: (context, snapshot) {
        return ListenableBuilder(
          listenable: router.routerDelegate,
          builder: (context, _) {
            final matches = router.routerDelegate.currentConfiguration.matches;
            if (matches.isEmpty) return const SizedBox();

            final currentRoute = matches.last;
            // GoRoute's name
            final routeName = (currentRoute.route as GoRoute).name ?? '---';

            // Watch package info
            final pkgInfo = ref.watch(packageInfoProvider).asData?.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    routeName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                if (pkgInfo != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${pkgInfo.packageName}\nv${pkgInfo.version} (${pkgInfo.buildNumber})',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}
