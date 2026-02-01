import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppStartupWidget extends ConsumerWidget {
  const AppStartupWidget({super.key, required this.onLoaded});
  final WidgetBuilder onLoaded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final startupState = ref.watch(initializationProvider);

    // // 状態が data になった（初期化完了した）ときにスプラッシュを消去
    // // ref.listen を使うことで、
    // // 1．ビルド中に他のウィジット＝スプラッシュスクリーンを操作することで予期しないエラーになるのを防ぐ
    // // 2．再ビルドで再実行しない
    // ref.listen<AsyncValue<void>>(initializationProvider, (_, state) {
    //   if (state is AsyncData) {
    //     // FlutterNativeSplash.remove();
    //   }
    // });

    // return startupState.when(
    //   //初期化が済んだら本来のアプリ画面を呼ぶコールバックを呼ぶ
    //   data: (_) => onLoaded(context),
    //   // 初期化中は何も表示しない（背後でネイティブスプラッシュが出ているため）
    //   loading: () => const SizedBox.shrink(),
    //   // エラー時はスプラッシュを消して、エラー画面を表示
    //   error: (e, st) {
    //     // FlutterNativeSplash.remove();
    //     return AppStartupErrorWidget(
    //       message: e.toString(),
    //       onRetry: () => ref.invalidate(initializationProvider),
    //     );
    //   },
    // );

    return onLoaded(context);
  }
}

class AppStartupErrorWidget extends StatelessWidget {
  const AppStartupErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 初期化失敗時はMaterialAppがまだ無いので、独自に定義
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  '初期化に失敗しました',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('再試行する'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
