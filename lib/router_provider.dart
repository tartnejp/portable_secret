// ignore_for_file: prefer_const_constructors
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';
import 'package:portable_sec/presentation/home/home_screen.dart';
import 'package:portable_sec/presentation/creation/steps/select_lock_type_page.dart';
import 'package:portable_sec/presentation/creation/steps/capacity_check_page.dart';
import 'package:portable_sec/presentation/creation/steps/input_data_page.dart';
import 'package:portable_sec/presentation/creation/steps/config_lock_page.dart';
import 'package:portable_sec/presentation/creation/steps/write_tag_page.dart';
import 'package:portable_sec/presentation/scan/select_unlock_method_screen.dart';
import 'package:portable_sec/presentation/scan/unlock_password_screen.dart';
import 'package:portable_sec/presentation/scan/unlock_pin_screen.dart';
import 'package:portable_sec/presentation/scan/unlock_pattern_screen.dart';
import 'package:portable_sec/presentation/scan/secret_view_screen.dart';
import 'package:portable_sec/domain/value_objects/secret_data.dart';

final navigatorKeyProvider = Provider((ref) => GlobalKey<NavigatorState>());
final routeObserverProvider = Provider(
  (ref) => RouteObserver<ModalRoute<void>>(),
);

List<RouteBase> get appRoutes => [
  GoRoute(
    path: '/',
    name: 'HOM', // Home
    builder: (context, state) => const HomeScreen(),
  ),
  GoRoute(
    path: '/creation',
    name: 'CRE',
    redirect: (context, state) {
      final path = state.uri.path;
      debugPrint('Router: Redirect check on $path');
      if (path == '/creation' || path == '/creation/') {
        debugPrint('Router: Redirecting $path -> /creation/locktype');
        return '/creation/locktype';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: 'locktype',
        name: 'CLT',
        builder: (context, state) => const SelectLockTypePage(),
      ),
      GoRoute(
        path: 'capacity',
        name: 'CCA',
        builder: (context, state) => const CapacityCheckPage(),
      ),
      GoRoute(
        path: 'input',
        name: 'CIN',
        builder: (context, state) => const InputDataPage(),
      ),
      GoRoute(
        path: 'config',
        name: 'CCF',
        builder: (context, state) => const ConfigLockPage(),
      ),
      GoRoute(
        path: 'write',
        name: 'CWR',
        builder: (context, state) => const WriteTagPage(),
      ),
    ],
  ),
  GoRoute(
    path: '/select-unlock',
    name: 'SEL', // Select Unlock Method
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return SelectUnlockMethodScreen(
        encryptedText: extra?['encryptedText'] as String,
      );
    },
  ),
  GoRoute(
    path: '/unlock/password',
    name: 'UPS', // Unlock Password
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return UnlockPasswordScreen(
        encryptedText: extra?['encryptedText'] as String,
      );
    },
  ),
  GoRoute(
    path: '/unlock/pin',
    name: 'UPI', // Unlock PIN
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return UnlockPinScreen(
        encryptedText: extra?['encryptedText'] as String?,
        pattern: extra?['pattern'] as String?,
      );
    },
  ),
  GoRoute(
    path: '/unlock/pattern',
    name: 'UPA', // Unlock Pattern
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return UnlockPatternScreen(
        encryptedText: extra?['encryptedText'] as String?,
        lockType: extra?['lockType'] as int?,
      );
    },
  ),
  GoRoute(
    path: '/secret-view',
    name: 'SVS', // Secret View Screen
    builder: (context, state) {
      final secret = state.extra as SecretData;
      return SecretViewScreen(secret: secret);
    },
  ),
];

final routerProvider = Provider<GoRouter>((ref) {
  final navKey = ref.watch(navigatorKeyProvider);
  final observer = ref.watch(routeObserverProvider);

  return GoRouter(
    navigatorKey: navKey,
    observers: [observer],
    routes: appRoutes,
    debugLogDiagnostics: false,
  );
});
