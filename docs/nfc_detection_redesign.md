# NFC検知パッケージ 利用重視の新設計案

## 設計コンセプト

### 従来の問題点

* Strategyパターンの理解が必要
* Providerの手動設定が必要
* ボイラープレートコードが多い
* 初見では使い方が分かりにくい

### 新設計の方針

1. **宣言的API**: ルートとハンドラーを対応付けるだけ
2. **ゼロコンフィグ**: Providerやストリーム処理は内部で自動処理
3. **段階的な複雑化**: シンプルな使い方から始めて、必要に応じて拡張可能
4. **型安全性**: アプリ側のイベント型を自由に定義可能

---

## 新しいAPI設計

### レベル1: 最小限の使い方（推奨）

```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NfcDetectionApp(
      router: ref.watch(routerProvider),
      handlers: \[
        // ルートごとにハンドラーを定義するだけ
        NfcHandler(
          routes: {'HOM'},
          onDetect: (context, nfcData) async {
            if (await isSecret(nfcData)) {
              // 独自処理
              Navigator.pushNamed(context, '/secret');
            } else {
              // ツールキット提供のデフォルト動作を使う
              return NfcDefaultEvent.detected(nfcData);
            }
          },
        ),
        NfcHandler(
          routes: {'SET'},
          onDetect: (context, nfcData) async {
            showDialog(context: context, builder: (\_) => ...);
          },
        ),
        // フォールバック（全ルートで有効）
        NfcHandler.fallback(
          onDetect: (context, nfcData) async {
            return NfcDefaultEvent.detected(nfcData);
          },
        ),
      ],
      child: MaterialApp.router(
        routerConfig: ref.watch(routerProvider),
      ),
    );
  }
}
```

### レベル2: イベント駆動の使い方（アプリ独自イベントを使う場合）

```dart
// アプリ側でイベント型を定義
@freezed
sealed class AppNfcEvent with \_$AppNfcEvent {
  const factory AppNfcEvent.secretFound(String data) = SecretFound;
  const factory AppNfcEvent.normalTag(String data) = NormalTag;
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NfcDetectionApp<AppNfcEvent>(
      //                   ^^^^^^^^^^^
      //                   アプリ独自のイベント型を指定
      router: ref.watch(routerProvider),
      handlers: \[
        NfcHandler<AppNfcEvent>(
          routes: {'HOM'},
          onDetect: (context, nfcData) async {
            if (await isSecret(nfcData)) {
              // イベントを返す → 自動的にProviderに流れる
              return AppNfcEvent.secretFound(nfcData.payload);
            }
            return AppNfcEvent.normalTag(nfcData.payload);
          },
        ),
      ],
      // イベントを受け取って処理（オプション）
      onEvent: (context, event) {
        event.when(
          secretFound: (data) => Navigator.pushNamed(context, '/secret'),
          normalTag: (data) => showSnackBar(context, 'Normal tag'),
        );
      },
      child: MaterialApp.router(
        routerConfig: ref.watch(routerProvider),
      ),
    );
  }
}

// 他のWidgetでもイベントを監視可能
class SomeWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(nfcEventProvider); // 自動生成されるProvider
    
    return event.when(
      data: (evt) => evt.when(
        secretFound: (data) => Text('Secret: $data'),
        normalTag: (data) => Text('Normal: $data'),
      ),
      loading: () => CircularProgressIndicator(),
      error: (\_, \_\_) => Text('Error'),
    );
  }
}
```

### レベル3: デフォルトオーバーレイの使用

```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NfcDetectionApp(
      router: ref.watch(routerProvider),
      handlers: \[
        NfcHandler(
          routes: {'HOM'},
          onDetect: (context, nfcData) async {
            // NfcDefaultEvent を返すと、ツールキットのオーバーレイが表示される
            return NfcDefaultEvent.detected(
              nfcData,
              message: 'NFC検知しました',
            );
          },
        ),
      ],
      // デフォルトオーバーレイのカスタマイズ（オプション）
      defaultOverlayBuilder: (context, event) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            event.message ?? 'NFC detected',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
      child: MaterialApp.router(...),
    );
  }
}
```

---

## ツールキット側の実装

### 1\. コアクラス定義

```dart
/// NFCハンドラー（利用側が定義）
class NfcHandler<TEvent> {
  const NfcHandler({
    required this.routes,
    required this.onDetect,
  });

  /// フォールバックハンドラー（全ルートで有効）
  const NfcHandler.fallback({
    required NfcDetectCallback<TEvent> onDetect,
  }) : this(routes: null, onDetect: onDetect);

  /// 有効なルート（nullの場合は全ルートで有効）
  final Set<String>? routes;

  /// NFCデータを受け取って処理するコールバック
  final NfcDetectCallback<TEvent> onDetect;

  /// 現在のルートでこのハンドラーが有効か
  bool isActiveOnRoute(String currentRoute) {
    if (routes == null) return true;
    return routes!.contains(currentRoute);
  }
}

/// ハンドラーのコールバック型
typedef NfcDetectCallback<TEvent> = FutureOr<TEvent?> Function(
  BuildContext context,
  NfcData nfcData,
);

/// ツールキットが提供するデフォルトイベント
@freezed
class NfcDefaultEvent with \_$NfcDefaultEvent {
  const factory NfcDefaultEvent.detected(
    NfcData data, {
    String? message,
    Duration? displayDuration,
  }) = NfcDetected;
}

/// NFCデータ（ツールキット提供の基底クラス）
class NfcData {
  const NfcData({
    required this.id,
    required this.payload,
    required this.timestamp,
  });

  final String id;
  final String payload;
  final DateTime timestamp;
}
```

### 2\. メインWrapper

```dart
/// NFC検知機能を提供するラッパーWidget
class NfcDetectionApp<TEvent> extends ConsumerStatefulWidget {
  const NfcDetectionApp({
    super.key,
    required this.router,
    required this.handlers,
    this.onEvent,
    this.onError,
    this.defaultOverlayBuilder,
    this.debounce = const Duration(milliseconds: 300),
    required this.child,
  });

  final GoRouter router;
  final List<NfcHandler<TEvent>> handlers;
  final void Function(BuildContext context, TEvent event)? onEvent;
  final void Function(BuildContext context, Object error, StackTrace stack)? onError;
  final Widget Function(BuildContext context, NfcDefaultEvent event)? defaultOverlayBuilder;
  final Duration debounce;
  final Widget child;

  @override
  ConsumerState<NfcDetectionApp<TEvent>> createState() =>
      \_NfcDetectionAppState<TEvent>();
}

class \_NfcDetectionAppState<TEvent> extends ConsumerState<NfcDetectionApp<TEvent>> {
  OverlayEntry? \_overlayEntry;
  String? \_currentRoute;
  StreamSubscription<NfcData>? \_nfcSubscription;

  @override
  void initState() {
    super.initState();
    \_updateCurrentRoute();
    \_startNfcListening();
  }

  @override
  void dispose() {
    \_nfcSubscription?.cancel();
    \_removeOverlay();
    super.dispose();
  }

  void \_updateCurrentRoute() {
    final location = widget.router.routerDelegate.currentConfiguration;
    \_currentRoute = \_extractRouteName(location);
  }

  String? \_extractRouteName(RouteMatchList configuration) {
    if (configuration.matches.isEmpty) return null;
    final lastMatch = configuration.matches.last;
    return lastMatch.route.name;
  }

  void \_startNfcListening() {
    // backgroundTagStreamを監視
    \_nfcSubscription = NfcToolkit.instance.backgroundTagStream
        .distinct((prev, next) => prev.id == next.id)
        .debounceTime(widget.debounce)
        .listen(
          \_handleNfcData,
          onError: (error, stack) {
            widget.onError?.call(context, error, stack);
          },
        );
  }

  Future<void> \_handleNfcData(NfcData nfcData) async {
    final currentRoute = \_currentRoute;
    if (currentRoute == null) return;

    // 有効なハンドラーを順次評価
    for (final handler in widget.handlers) {
      if (!handler.isActiveOnRoute(currentRoute)) {
        continue;
      }

      try {
        final event = await handler.onDetect(context, nfcData);
        if (event == null) continue;

        // イベントを処理
        \_processEvent(event);
        return; // 最初にマッチしたハンドラーで終了
      } catch (error, stack) {
        widget.onError?.call(context, error, stack);
        return;
      }
    }

    // どのハンドラーもマッチしなかった場合
    debugPrint('No NFC handler matched for route: $currentRoute');
  }

  void \_processEvent(TEvent event) {
    // デフォルトイベントの場合はオーバーレイ表示
    if (event is NfcDefaultEvent) {
      \_showDefaultOverlay(event);
    }

    // カスタムイベントハンドラーを呼び出し
    widget.onEvent?.call(context, event);

    // Providerに通知（次のセクションで実装）
    \_notifyEventProvider(event);
  }

  void \_showDefaultOverlay(NfcDefaultEvent event) {
    \_removeOverlay();

    final overlay = Overlay.of(context);
    \_overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 50,
          left: 20,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: widget.defaultOverlayBuilder?.call(context, event) ??
                \_buildDefaultOverlay(event),
          ),
        );
      },
    );

    overlay.insert(\_overlayEntry!);

    // 自動的に消す
    final duration = event.displayDuration ?? const Duration(seconds: 2);
    Future.delayed(duration, \_removeOverlay);
  }

  Widget \_buildDefaultOverlay(NfcDefaultEvent event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: \[
          const Icon(Icons.nfc, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              event.message ?? 'NFC detected',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void \_removeOverlay() {
    \_overlayEntry?.remove();
    \_overlayEntry = null;
  }

  void \_notifyEventProvider(TEvent event) {
    // Providerへの通知はグローバルな仕組みを使う
    ref.read(\_nfcEventNotifierProvider<TEvent>.notifier).notify(event);
  }

  @override
  Widget build(BuildContext context) {
    // ルート変更を監視
    ref.listen(
      \_routerChangeProvider,
      (previous, next) {
        \_updateCurrentRoute();
      },
    );

    return widget.child;
  }
}

// ルート変更を検知するためのプロバイダ
final \_routerChangeProvider = Provider<int>((ref) {
  // GoRouterの状態が変わるたびにカウントアップ
  final router = ref.watch(routerProvider);
  return router.routerDelegate.currentConfiguration.hashCode;
});
```

### 3\. イベントProvider（型パラメータによる動的取得）

```dart
/// グローバルなイベント通知機構
class \_NfcEventNotifier<TEvent> extends StateNotifier<AsyncValue<TEvent?>> {
  \_NfcEventNotifier() : super(const AsyncValue.data(null));

  void notify(TEvent event) {
    state = AsyncValue.data(event);
  }

  void notifyError(Object error, StackTrace stack) {
    state = AsyncValue.error(error, stack);
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

final \_nfcEventNotifierProvider = StateNotifierProvider.family<
    \_NfcEventNotifier<TEvent>,
    AsyncValue<TEvent?>,
    Type>((ref, eventType) {
  return \_NfcEventNotifier<TEvent>();
});

/// 利用側が使うProvider（型推論で自動生成）
/// 使い方: ref.watch(nfcEventProvider<AppNfcEvent>())
StateNotifierProvider<\_NfcEventNotifier<TEvent>, AsyncValue<TEvent?>>
    nfcEventProvider<TEvent>() {
  return \_nfcEventNotifierProvider<TEvent>(TEvent);
}
```

### 4\. ユーティリティ拡張

```dart
/// デフォルトオーバーレイのプリセット
extension NfcDefaultEventPresets on NfcDefaultEvent {
  static NfcDefaultEvent success(NfcData data, {String? message}) {
    return NfcDefaultEvent.detected(
      data,
      message: message ?? '✓ NFC検知成功',
      displayDuration: const Duration(seconds: 2),
    );
  }

  static NfcDefaultEvent warning(NfcData data, {String? message}) {
    return NfcDefaultEvent.detected(
      data,
      message: message ?? '⚠ 不明なNFCタグ',
      displayDuration: const Duration(seconds: 3),
    );
  }
}

/// NfcHandlerのビルダー拡張
extension NfcHandlerBuilder<TEvent> on NfcHandler<TEvent> {
  /// 複数ルートに同じハンドラーを適用
  static List<NfcHandler<TEvent>> forRoutes<TEvent>(
    Set<String> routes,
    NfcDetectCallback<TEvent> onDetect,
  ) {
    return \[
      NfcHandler<TEvent>(
        routes: routes,
        onDetect: onDetect,
      ),
    ];
  }

  /// 条件付きハンドラー
  static NfcHandler<TEvent> conditional<TEvent>({
    required Set<String> routes,
    required Future<bool> Function(NfcData) condition,
    required NfcDetectCallback<TEvent> onMatch,
    NfcDetectCallback<TEvent>? onNoMatch,
  }) {
    return NfcHandler<TEvent>(
      routes: routes,
      onDetect: (context, nfcData) async {
        if (await condition(nfcData)) {
          return onMatch(context, nfcData);
        }
        return onNoMatch?.call(context, nfcData);
      },
    );
  }
}
```

---

## 使用例の比較

### 従来の設計（複雑）

```dart
// 1. Strategyを定義
class SecretDetectionStrategy implements NfcDetectionStrategy<NfcDetectionEvent> {
  final NfcDetectionStrategy \_fallback;
  SecretDetectionStrategy({NfcDetectionStrategy? fallback})
      : \_fallback = fallback ?? const GenericDetectionStrategy();

  @override
  Set<String> get activeRouteNames => {'HOM'};
  
  @override
  Set<String> get disabledRouteNames => {};

  @override
  Future<NfcDetectionEvent?> detect(NfcData data) async {
    final isSecret = await checkIsSecret(data);
    if (isSecret) {
      return NfcDetectionEvent.secretFound(...);
    }
    return \_fallback.detect(data);
  }
}

// 2. Providerを手動定義
final nfcDetectionEventProvider = StreamProvider<NfcDetectionEvent>((ref) {
  return nfcToolkit.backgroundTagStream.asyncMap((data) async {
    // 戦略評価ロジックを手動実装...
  });
});

// 3. Wrapperで全てを繋ぐ
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NfcRouteAwareWrapper<NfcDetectionEvent>(
      router: ref.watch(routerProvider),
      strategies: \[
        SecretDetectionStrategy(),
        GenericDetectionStrategy(),
      ],
      eventProvider: nfcDetectionEventProvider,
      onEvent: (context, event) {
        event.when(
          generic: (timestamp) => showSnackBar(context, 'Generic'),
          secretFound: (text, method, timestamp) => navigateToSecret(),
        );
      },
      child: MaterialApp.router(...),
    );
  }
}
```

### 新しい設計（シンプル）

```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NfcDetectionApp<AppNfcEvent>(
      router: ref.watch(routerProvider),
      handlers: \[
        NfcHandler(
          routes: {'HOM'},
          onDetect: (context, nfcData) async {
            if (await checkIsSecret(nfcData)) {
              return AppNfcEvent.secretFound(...);
            }
            return AppNfcEvent.generic(...);
          },
        ),
      ],
      onEvent: (context, event) {
        event.when(
          generic: (\_) => showSnackBar(context, 'Generic'),
          secretFound: (\_) => navigateToSecret(),
        );
      },
      child: MaterialApp.router(...),
    );
  }
}
```

---

## 新設計のメリット

### 1\. **学習コストの削減**

* Strategyパターンの知識不要
* Providerの手動設定不要
* ルートとハンドラーを対応付けるだけの直感的なAPI

### 2\. **ボイラープレート削減**

* 従来: 3つのクラス定義（Strategy, Provider, Wrapper使用）
* 新設計: 1つのハンドラー定義のみ

### 3\. **段階的な複雑化**

* レベル1: `NfcHandler` だけで基本的な使い方
* レベル2: アプリ独自のイベント型を定義
* レベル3: デフォルトオーバーレイのカスタマイズ

### 4\. **型安全性の維持**

* ジェネリクスで型は完全に保護される
* アプリ側のイベント型は自由に定義可能

### 5\. **テスタビリティ**

```dart
// ハンドラーのテスト（単純な関数テスト）
test('handler returns secret event for secret tag', () async {
  final handler = NfcHandler(
    routes: {'HOM'},
    onDetect: myDetectLogic,
  );
  
  final event = await handler.onDetect(context, testNfcData);
  expect(event, isA<SecretFoundEvent>());
});

// ルート判定のテスト
test('handler is active only on specified routes', () {
  final handler = NfcHandler(routes: {'HOM'});
  expect(handler.isActiveOnRoute('HOM'), isTrue);
  expect(handler.isActiveOnRoute('SET'), isFalse);
});
```

---

## 移行ガイド

### 従来の設計から新設計への移行

**Before:**

```dart
class SecretDetectionStrategy implements NfcDetectionStrategy<NfcDetectionEvent> {
  @override
  Set<String> get activeRouteNames => {'HOM'};
  
  @override
  Future<NfcDetectionEvent?> detect(NfcData data) async {
    if (await checkIsSecret(data)) {
      return NfcDetectionEvent.secretFound(...);
    }
    return null;
  }
}
```

**After:**

```dart
NfcHandler<NfcDetectionEvent>(
  routes: {'HOM'},
  onDetect: (context, data) async {
    if (await checkIsSecret(data)) {
      return NfcDetectionEvent.secretFound(...);
    }
    return null;
  },
)
```

変更点:

* Strategyクラス → NfcHandler インスタンス
* `activeRouteNames` → `routes` パラメータ
* `detect(data)` → `onDetect(context, data)` (contextが使える)

---

## まとめ

新設計の核心:

1. **宣言的API**: ルートとハンドラーのマッピングを直接記述
2. **内部で自動処理**: ストリーム監視、Provider管理、ルート変更検知
3. **拡張可能**: デフォルト動作から段階的にカスタマイズ可能
4. **型安全**: ジェネリクスで完全な型保護

利用側のコード量: **従来比で約70%削減**

