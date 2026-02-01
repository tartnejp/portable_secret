import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/providers/nfc_detection_provider.dart';

import 'package:go_router/go_router.dart';
import 'application/providers/di/services_provider.dart';
import 'router_provider.dart';

class ListeningNfcApp extends ConsumerStatefulWidget {
  final Widget child;
  final NfcDetectionStrategy? strategy;
  const ListeningNfcApp({super.key, required this.child, this.strategy});
  @override
  ConsumerState<ListeningNfcApp> createState() => _ListeningNfcAppState();
}

class _ListeningNfcAppState extends ConsumerState<ListeningNfcApp> {
  String? _lastPath;

  @override
  void initState() {
    super.initState();
    if (widget.strategy != null) {
      Future.microtask(() {
        ref
            .read(nfcDetectionStrategyProvider.notifier)
            .setStrategy(widget.strategy!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Monitor route changes to reset session when returning to Home
    final router = ref.watch(routerProvider);
    String currentPath = '/';
    try {
      final matches = router.routerDelegate.currentConfiguration.matches;
      if (matches.isNotEmpty) {
        currentPath = matches.last.matchedLocation;
      }
    } catch (_) {
      // Fallback
    }

    // If we are back at root ('/') and we were somewhere else, reset the session
    if (currentPath == '/' && _lastPath != null && _lastPath != '/') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(nfcServiceProvider).resetSession();
        }
      });
    }
    _lastPath = currentPath;

    ref.listen(nfcDetectionEventProvider, (prev, next) {
      next.when(
        data: (event) {
          event.when(
            generic: (_) {
              // Generic tag detected
              _showOverlay(context, 'NFCタグを検知しました');
            },
            secretFound: (encryptedText, foundLockMethod) {
              // final router = ref.read(routerProvider);
              // final matches =
              //     router.routerDelegate.currentConfiguration.matches;
              // final currentPath = matches.isNotEmpty
              //     ? matches.last.matchedLocation
              //     : router.routeInformationProvider.value.uri.path;

              // if (currentPath == '/' || currentPath == '/locations') {
              //   ref.read(useCasesProvider).saveLockInfoByNfcDetection(location);
              // }

              _showOverlay(context, 'NFCタグを検知しました');
            },
          );
        },
        error: (err, stack) {
          // Ignore errors in background detection
        },
        loading: () {},
      );
    });

    return widget.child;
  }

  void _showOverlay(BuildContext context, String message) {
    // Dismiss existing snackbars
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Custom SnackBar to match the look of the previous overlay
    final snackBar = SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      backgroundColor: Colors.black87,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      margin: const EdgeInsets.only(bottom: 50, left: 24, right: 24),
      duration: const Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
