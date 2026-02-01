import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'infrastructure/services/nfc_service_impl.dart';
import 'application/providers/nfc_detection_provider.dart';
import 'listening_nfc_app.dart';
import 'router_provider.dart';
import 'startup.dart';
import 'presentation/widgets/debug_info_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NfcServiceImpl.instance.init();
  runApp(const ProviderScope(child: MainApp()));
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
        // Wrap the Home with the Listener so it's active when Home is showing
        builder: (context, child) {
          return DebugInfoOverlay(
            router: router,
            child: ListeningNfcApp(
              strategy: SecretNfcDetectionStrategy(),
              child: child!,
            ),
          );
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
