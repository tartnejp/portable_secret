import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DebugInfoOverlay extends StatelessWidget {
  final Widget child;
  final GoRouter? router;

  const DebugInfoOverlay({super.key, required this.child, this.router});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return child;
    }

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

class _ScreenIdDisplay extends StatelessWidget {
  final GoRouter? router;
  const _ScreenIdDisplay({this.router});

  @override
  Widget build(BuildContext context) {
    // Watch Router State to update when route changes
    final router = this.router ?? GoRouter.of(context);

    // We can't easily "watch" the route name directly from top-level without a listener.
    // However, GoRouter's routeInformationProvider notifies listeners.
    // Let's us StreamBuilder or similar?
    // Actually, simple way is just using GoRouterState if available in sub-tree,
    // but this overlay wraps the app.
    // Wait, if it wraps the app, it might be OUTSIDE the router if placed in builder.
    // 'MaterialApp.router' builder method gives us 'child' which IS the navigator/router output.
    // So we ARE inside the router's provider scope usually?
    // Let's check 'main.dart'.
    // builder: (context, child) => ...
    // Yes, 'context' here should be able to access Router if Router is initialized.
    // But 'builder' of MaterialApp.router puts the built widget ABOVE the Navigator?
    // No, specifically: "The builder attribute... is used to wrap the navigator".
    // So context here might NOT have the current Route match info directly accessible via context.watch/read of generic providers if we don't custom-build it.

    // However, GoRouter exposes `routerDelegate`. We can listen to it.

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

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
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
            );
          },
        );
      },
    );
  }
}
