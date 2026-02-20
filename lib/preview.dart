import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portable_sec/presentation/scan/prompt_rescan_screen.dart';

@Preview()
Widget promptRescanScreenPreview() {
  return const ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Preview',
      home: PromptRescanScreen(),
    ),
  );
}
