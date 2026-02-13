# NFC検知パッケージ ハイブリッド設計案 (Revised)

## 概要

Strategyパターンの堅牢性と、Riverpodの直感的な使いやすさを両立させた「ハイブリッド設計」の改良版です。
前回の案に対し、**「優先順決めのロジック強化」** と **「ルート監視のボイラープレート削減」** を盛り込んでいます。

---

## 改善のポイント（前回からの変更点）

1.  **優先順位の厳格化 (Two-Pass Logic)**
    *   リストの登録順序に依存せず、「そのルート専用の検知器 (`activeRoutes`)」が必ず「汎用検知器」より優先されるロジックを導入しました。
    *   `disabledRoutes` プロパティを追加し、特定のルートで汎用検知器を無効化できるようにしました。

2.  **ルート監視の自動化ヘルパー**
    *   `NfcDetectionProvider.routeFrom(routerProvider)` ヘルパーを追加。
    *   ユーザーが自分で `GoRouter` の内部構造を触る必要をなくしました。

---

## Architecture Overview

```
┌─────────────────────────────────────────────┐
│  Presentation Layer                         │
│  NfcDetectionScope (Optional)               │
│  - オーバーレイ表示                          │
│  - イベントハンドリング                       │
└─────────────────┬───────────────────────────┘
                  │ listnes to
┌─────────────────▼───────────────────────────┐
│  State Layer (Provider)                     │
│  NfcDetectionProvider                       │
│  - ルート監視 (routeFrom Helper)             │
│  - 優先順位解決 (Two-Pass Logic)             │
│  - ストリーム変換                            │
└─────────────────┬───────────────────────────┘
                  │ uses
┌─────────────────▼───────────────────────────┐
│  Logic Layer (Domain)                       │
│  NfcDetector <TEvent>                       │
│  - 検知ロジック (Context-free)               │
│  - Active/Disabled Routes 定義               │
└─────────────────────────────────────────────┘
```

---

## 1. Logic Layer: NfcDetector

`Strategy` パターンの後継となるインターフェースです。
「どのルートで有効か」と「どう検知するか」のロジックのみを持ちます。

```dart
abstract class NfcDetector<TEvent> {
  const NfcDetector();

  /// この検知器が優先的に有効となるルート（nullの場合は汎用）
  Set<String>? get activeRoutes => null;

  /// この検知器を明示的に無効化するルート
  /// (activeRoutesがnullの場合のみ効果がある)
  Set<String> get disabledRoutes => const {};

  /// NFCデータを解析してイベントを返す
  /// 検知対象でない場合は null を返す
  FutureOr<TEvent?> detect(NfcData data);
}
```

### 実装例: アプリ固有のDetector

```dart
class SecretNfcDetector extends NfcDetector<AppNfcEvent> {
  // ホーム画面でのみ有効（最優先）
  @override
  Set<String> get activeRoutes => {'HOM'};

  @override
  Future<AppNfcEvent?> detect(NfcData data) async {
    if (await checkSecret(data)) {
      return AppNfcEvent.secretFound(data);
    }
    return null;
  }
}

class MereNfcDetector extends NfcDetector<AppNfcEvent> {
  // 汎用（どこでも有効）だが、ホーム画面では無効化
  // (ホーム画面はSecretDetectorに任せるため)
  @override
  Set<String> get disabledRoutes => {};

  @override
  Future<AppNfcEvent?> detect(NfcData data) async {
    return AppNfcEvent.generic(data);
  }
}
```

---

## 2. State Layer: NfcDetectionProvider

`NfcDetector` のリストを受け取り、適切なイベントストリームを提供する Provider を生成します。

### [NEW] NfcDetectorSelector (Testable Logic)

選定ロジックを単体テスト可能なクラスとして切り出しました。

```dart
class NfcDetectorSelector {
  /// Two-Pass Logic に基づいて最適な検知器を選定する
  static NfcDetector<T>? select<T>(
    List<NfcDetector<T>> detectors,
    String? currentRoute,
  ) {
    // 1. Priority Pass: ActiveRoutes に含まれるものを優先
    if (currentRoute != null) {
      final activeMatch = detectors.firstWhereOrNull(
        (d) => d.activeRoutes?.contains(currentRoute) ?? false
      );
      if (activeMatch != null) return activeMatch;
    }

    // 2. Fallback Pass: 汎用(null)かつ無効化されていないもの
    return detectors.firstWhereOrNull((d) {
      final isGeneric = d.activeRoutes == null;
      final isEnabled = currentRoute == null || 
                        !d.disabledRoutes.contains(currentRoute);
      return isGeneric && isEnabled;
    });
  }
}
```

### ルート監視ヘルパー (Robust)

```dart
class NfcDetectionProvider {
  static Provider<String?> routeFrom(Provider<GoRouter> routerProvider) {
    return Provider<String?>((ref) {
      try {
        final router = ref.watch(routerProvider);
        // 安全なアクセス
        if (router.routerDelegate.currentConfiguration.matches.isEmpty) {
          return null;
        }
        return router.routerDelegate.currentConfiguration.matches.last.route.name;
      } catch (e) {
        // 初期化前やエラー時はnullとして扱う
        return null;
      }
    });
  }

  /// Provider生成メソッド
  static StreamProvider<TEvent> create<TEvent>({
     required List<NfcDetector<TEvent>> detectors,
     required Provider<String?> currentRouteProvider,
  }) {
    return StreamProvider<TEvent>((ref) {
      final currentRoute = ref.watch(currentRouteProvider);
      return NfcToolkit.instance.backgroundTagStream
          .asyncMap((data) async {
             // 切り出したロジックを使用
             final detector = NfcDetectorSelector.select(detectors, currentRoute);
             if (detector != null) {
               return await detector.detect(data);
             }
             return null;
          });
    });
  }
}
```

---

## 3. UI Layer: NfcDetectionScope

UIへの統合を行うラッパーウィジェットです。

```dart
class NfcDetectionScope<TEvent> extends ConsumerWidget {
  const NfcDetectionScope({
    required this.eventProvider,
    this.onEvent,
    this.showDefaultOverlay = false,
    required this.child,
  });

  // ...
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // イベント監視
    ref.listen(eventProvider, (prev, next) {
      if (next.hasValue) {
        final event = next.value!;
        // オーバーレイ表示やコールバック実行
      }
    });

    return child;
  }
}
```

---

## 利用側のコード (Complete Example)

```dart
// 1. 検出器の定義
final detectors = [
  SecretNfcDetector(),
  MereNfcDetector(),
  // MereNfcDetectorが汎用フォールバックとして機能するためDefaultNfcDetectorは不要
];

// 2. ルートプロバイダの定義 (ヘルパー使用)
final currentRouteProvider = NfcDetectionProvider.routeFrom(routerProvider);

// 3. イベントプロバイダの定義
final appNfcEventProvider = NfcDetectionProvider.create<AppNfcEvent>(
  detectors: detectors,
  currentRouteProvider: currentRouteProvider,
);

// 4. アプリへの組み込み
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NfcDetectionScope<AppNfcEvent>(
      eventProvider: appNfcEventProvider,
      showDefaultOverlay: true, // デフォルト通知を表示
      onEvent: (context, event) {
        // アプリ固有の遷移処理
        event.when(
          secretFound: (_) => context.go('/secret'),
          generic: (_) {}, // オーバーレイが出るので何もしない
        );
      },
      child: MaterialApp.router(
        routerConfig: ref.watch(routerProvider),
      ),
    );
  }
}
```

## メリット

*   **完全な疎結合**: Toolkitは `GoRouter` 本体や `AppNfcEvent` 型を知りません。
*   **ボイラープレート激減**: 複雑な `Notifier` や `Wrapper` の定義が不要。
*   **堅牢な優先順位**: Two-Pass Logic により、「専用検知器の定義」が確実に機能します。
