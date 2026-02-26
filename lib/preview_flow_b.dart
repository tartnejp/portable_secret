import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portable_sec/presentation/home/home_screen.dart';
import 'package:portable_sec/presentation/scan/select_unlock_method_screen.dart';
import 'package:portable_sec/presentation/scan/unlock_password_screen.dart';
import 'package:portable_sec/presentation/scan/unlock_pin_screen.dart';
import 'package:portable_sec/presentation/scan/unlock_pattern_screen.dart';
import 'package:portable_sec/presentation/scan/prompt_rescan_screen.dart';
import 'package:portable_sec/presentation/scan/secret_view_screen.dart';
import 'package:portable_sec/domain/value_objects/secret_data.dart';
import 'package:portable_sec/domain/value_objects/lock_method.dart';
import 'package:portable_sec/presentation/app_theme.dart';

@Preview()
Widget homeScreenPreview() => _buildPreview(const HomeScreen());

@Preview()
Widget selectUnlockMethodScreenPreview() => _buildPreview(
  const SelectUnlockMethodScreen(
    encryptedText: 'dummy_encrypted_text',
    capacity: 137,
  ),
);

@Preview()
Widget unlockPasswordScreenPreview() => _buildPreview(
  const UnlockPasswordScreen(
    encryptedText: 'dummy_encrypted_text',
    lockType: 2, // Password
    capacity: 137,
  ),
);

@Preview()
Widget unlockPinScreenPreview() => _buildPreview(
  const UnlockPinScreen(
    encryptedText: 'dummy_encrypted_text',
    lockType: 1, // PIN
    capacity: 137,
  ),
);

@Preview()
Widget unlockPatternScreenPreview() => _buildPreview(
  const UnlockPatternScreen(
    encryptedText: 'dummy_encrypted_text',
    lockType: 0, // Pattern
    capacity: 137,
  ),
);

@Preview()
Widget promptRescanScreenPreview() => _buildPreview(const PromptRescanScreen());

@Preview()
Widget secretViewScreenPreview() => _buildPreview(
  SecretViewScreen(
    args: SecretViewArgs(
      secret: SecretData(
        items: [
          SecretItem(key: 'Username', value: 'admin'),
          SecretItem(key: 'Password', value: 'secret123'),
          SecretItem(key: 'URL', value: 'https://example.com'),
        ],
      ),
      lockType: LockType.password,
      isManualUnlockRequired: false,
      capacity: 137,
    ),
  ),
);

Widget _buildPreview(Widget screen) {
  final router = GoRouter(
    routes: [GoRoute(path: '/', builder: (context, state) => screen)],
  );
  return ProviderScope(
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    ),
  );
}
