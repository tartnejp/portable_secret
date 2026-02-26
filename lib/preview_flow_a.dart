import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portable_sec/presentation/creation/steps/select_lock_type_page.dart';
import 'package:portable_sec/presentation/creation/steps/capacity_check_page.dart';
import 'package:portable_sec/presentation/creation/steps/input_data_page.dart';
import 'package:portable_sec/presentation/creation/steps/config_lock_page.dart';
import 'package:portable_sec/presentation/creation/steps/write_tag_page.dart';
import 'package:portable_sec/presentation/app_theme.dart';

@Preview()
Widget selectLockTypePagePreview() => _buildPreview(const SelectLockTypePage());

@Preview()
Widget capacityCheckPagePreview() => _buildPreview(const CapacityCheckPage());

@Preview()
Widget inputDataPagePreview() => _buildPreview(const InputDataPage());

@Preview()
Widget configLockPagePreview() => _buildPreview(const ConfigLockPage());

@Preview()
Widget writeTagPagePreview() => _buildPreview(const WriteTagPage());

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
