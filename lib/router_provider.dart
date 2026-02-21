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
import 'package:portable_sec/presentation/scan/prompt_rescan_screen.dart';
// import 'package:portable_sec/domain/value_objects/secret_data.dart';

final navigatorKeyProvider = Provider((ref) => GlobalKey<NavigatorState>());
final routeObserverProvider = Provider(
  (ref) => RouteObserver<ModalRoute<void>>(),
);

enum AppRoute {
  home('HOM-'),
  creation('CRE'),
  creationLockType('CLT'),
  creationCapacity('CCA'),
  creationInput('CIN'),
  creationConfig('CCF'),
  creationWrite('CWR'),
  selectUnlock('SEL'),
  unlockPassword('UPS'),
  unlockPin('UPI'),
  unlockPattern('UPA'),
  promptRescan('PRS'),
  secretView('SVS');

  final String name;
  const AppRoute(this.name);
}

List<RouteBase> get appRoutes => [
  GoRoute(
    path: '/',
    name: AppRoute.home.name,
    builder: (context, state) => const HomeScreen(),
  ),
  GoRoute(
    path: '/creation',
    name: AppRoute.creation.name,
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
        name: AppRoute.creationLockType.name,
        builder: (context, state) => const SelectLockTypePage(),
      ),
      GoRoute(
        path: 'capacity',
        name: AppRoute.creationCapacity.name,
        builder: (context, state) => const CapacityCheckPage(),
      ),
      GoRoute(
        path: 'input',
        name: AppRoute.creationInput.name,
        builder: (context, state) => const InputDataPage(),
      ),
      GoRoute(
        path: 'config',
        name: AppRoute.creationConfig.name,
        builder: (context, state) => const ConfigLockPage(),
      ),
      GoRoute(
        path: 'write',
        name: AppRoute.creationWrite.name,
        builder: (context, state) => const WriteTagPage(),
      ),
    ],
  ),
  GoRoute(
    path: '/select-unlock',
    name: AppRoute.selectUnlock.name, // Select Unlock Method
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return SelectUnlockMethodScreen(
        encryptedText: extra?['encryptedText'] as String,
        capacity: extra?['capacity'] as int? ?? 0,
      );
    },
  ),
  GoRoute(
    path: '/unlock/password',
    name: AppRoute.unlockPassword.name, // Unlock Password
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return UnlockPasswordScreen(
        encryptedText: extra?['encryptedText'] as String?,
        lockType: extra?['lockType'] as int?,
        capacity: extra?['capacity'] as int?,
        isManualUnlockRequired:
            extra?['isManualUnlockRequired'] as bool? ?? false,
      );
    },
  ),
  GoRoute(
    path: '/unlock/pin',
    name: AppRoute.unlockPin.name, // Unlock PIN
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return UnlockPinScreen(
        encryptedText: extra?['encryptedText'] as String?,
        pattern: extra?['pattern'] as String?,
        lockType: extra?['lockType'] as int?,
        capacity: extra?['capacity'] as int?,
        isManualUnlockRequired:
            extra?['isManualUnlockRequired'] as bool? ?? false,
      );
    },
  ),
  GoRoute(
    path: '/unlock/pattern',
    name: AppRoute.unlockPattern.name, // Unlock Pattern
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return UnlockPatternScreen(
        encryptedText: extra?['encryptedText'] as String?,
        lockType: extra?['lockType'] as int?,
        capacity: extra?['capacity'] as int?,
        isManualUnlockRequired:
            extra?['isManualUnlockRequired'] as bool? ?? false,
      );
    },
  ),
  GoRoute(
    path: '/unlock',
    name:
        AppRoute.promptRescan.name, // Prompt Rescan Screen for Universal Links
    builder: (context, state) => const PromptRescanScreen(),
  ),
  GoRoute(
    path: '/secret-view',
    name: AppRoute.secretView.name, // Secret View Screen
    builder: (context, state) {
      final args = state.extra as SecretViewArgs;
      return SecretViewScreen(args: args);
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
