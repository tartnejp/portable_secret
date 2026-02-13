import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // import for GoRouterState

import 'package:nfc_toolkit/nfc_toolkit.dart';
import 'application/nfc/secret_detected.dart';
import 'router_provider.dart';
import 'startup.dart';
import 'presentation/widgets/debug_info_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [
        nfcDetectionRegistryProvider.overrideWithValue(
          NfcDetectionRegistry([
            () => const SecretDetection(),
            // Generic is handled by default fallbacks in the provider logic if nothing else matches
          ]),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

// final routeObserver = RouteObserver<ModalRoute<void>>(); // Moved to app_observer.dart

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return AppStartupWidget(
      onLoaded: (context) => MaterialApp.router(
        title: 'Portable Sec',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: router,
        // Wrap the Home with the Listener so it's active everywhere
        builder: (context, child) {
          return DebugInfoOverlay(
            router: router,
            child: NfcDetectionScope(
              // Explicitly pass router name getter for GoRouter
              routeNameGetter: (context) {
                try {
                  return GoRouterState.of(context).name;
                } catch (_) {
                  return null;
                }
              },
              disableGenericDetectionRoutes: {
                AppRoute.home.name, // Enable overlay on Home
                // Add other routes if needed
              },
              child: child!,
            ),
          );
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
