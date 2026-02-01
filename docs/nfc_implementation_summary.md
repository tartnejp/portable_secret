# NFC実装要件と実装のまとめ

以下の要件を満たすための「必要十分」な実装構成

1.  NFCタグの処理を行う
2.  NFC Managerを使う
3.  アプリがフォアグラウンドの時は、NFCタグの処理はすべてこのアプリで行う
4.  MainActivityのみの想定
5.  MIMEで起動する
6.  二重起動はしない（MIME起動と手動起動の重複防止）
7.  コールドスタート対応（起動直後のタグ検知漏れを防ぐ）

# まとめ

| 要件 | 実現方法 (必要十分な実装) |
| :--- | :--- |
| NFC処理 & Manager利用 | `pubspec.yaml` に `nfc_manager` 追加 |
| フォアグラウンド優先処理 | Dart側で `startSession()` を呼ぶ (Androidの標準挙動としてForeground Dispatchが有効化される) |
| MainActivityのみ想定 | `flutter create` 生成物のまま、継承等の変更不要 |
| MIMEで起動 | Manifestに `<data android:mimeType="..." />` を含むIntent Filterを追加 |
| 二重起動防止 | `launchMode="singleTask"` に設定し、かつ **`taskAffinity=""` (空文字設定) を削除** する |
| コールドスタート対応 | `StreamController` の `onListen` を使い、リスナー接続まで初期イベントをバッファリングする |

## 1. Android設定 (AndroidManifest.xml)

最も重要な設定箇所です。

### 必須設定
*   **権限の追加**: NFCハードウェアへのアクセス権。
*   **LaunchModeの変更**: `singleTask` に設定し、**`taskAffinity` 設定を削除**（または標準に戻す）。
    *   **理由**: MIME検知による自動起動と、ランチャーからの手動起動で、同じ「1つのアプリインスタンス」を使い回すため。`taskAffinity` が空文字等のままだと別タスクとして扱われる可能性がある
*   **Intent Filterの追加**: `NDEF_DISCOVERED` と特定の `MIME` タイプ。
    *   **理由**: タグ検知時にアプリを起動（または復帰）させるため。`TECH_DISCOVERED` はフィルタが広すぎて誤動作（Suica等への反応）の原因となるため、特定のMIMEに絞るのが最適です。

```xml
<manifest ...>
    <!-- 1. 権限 -->
    <uses-permission android:name="android.permission.NFC"/>

    <application ...>
        <!-- 2. LaunchMode: singleTask (taskAffinityの削除も推奨) -->
        <activity
            android:name=".MainActivity"
            android:launchMode="singleTask"
            ...>
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>

            <!-- 3. MIME検知用 Intent Filter -->
            <intent-filter>
                <action android:name="android.nfc.action.NDEF_DISCOVERED"/>
                <category android:name="android.intent.category.DEFAULT"/>
                <!-- アプリ固有のMIMEタイプを指定 -->
                <data android:mimeType="application/myapp"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
```

---

## 2. MainActivity (Kotlin/Java)

*   `nfc_manager` (v4.0以降想定) を使用する場合、**追加の実装は不要**です。
*   プラグイン内部で `onNewIntent` 等が適切に処理され、Dart側のコールバックにタグ情報が渡されます。

---

## 3. Flutter実装 (Dart)

アプリがフォアグラウンドにある間の優先処理（Foreground Dispatch）を実現するためには、セッションの開始が必要です。

### 基本実装
*   `NfcManager.instance.startSession` を呼び出すことで、OSに対し「このアプリが最優先でNFCを処理する」と宣言することになります。
*   これにより、アプリ起動中は他のNFCアプリ（標準のタグリーダーなど）が反応せず、このアプリのコールバック関数が直接呼ばれます。

```dart
// 起動時または画面表示時にセッションを開始
void startNfc() {
  NfcManager.instance.startSession(
    onDiscovered: (NfcTag tag) async {
      // タグ検知時の処理
      // MIME起動の場合も、LaunchModeがsingleTaskであれば
      // 再開時(onNewIntent経由)でここが呼ばれる仕組みになっています
    },
  );
}
```

### ライフサイクル対応
「フォアグラウンドの時のみ処理する」を厳密に行う場合、アプリがバックグラウンドに回った際はセッションを停止するのが行儀の良い実装です。

```dart
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 復帰時に再開（優先権を取り戻す）
      NfcManager.instance.startSession(...);
    } else if (state == AppLifecycleState.paused) {
      // バックグラウンド時は停止（他のアプリに権利を譲る）
      NfcManager.instance.stopSession();
    }
  }
```

## 4. コールドスタート時のイベント処理 (Cold Start)
アプリが完全に終了している状態からNFCタグで起動した場合（コールドスタート）、その起動Intent時点のタグ情報はFlutter単独では取得できない。

### 問題点
`NfcManager` (および多くのNFCプラグイン) は、Androidの **`ReaderMode` API** を使用して実装されています。
*   `ReaderMode`: アプリがフォアグラウンドにある間、優先的に新しいタグをスキャンする機能。
*   `Launch Intent`: アプリを起動させた過去のイベント（タグ情報）。

`ReaderMode` は「これからかざされる未来のタグ」しか検知しないため、アプリ起動のトリガーとなった「過去のタグ情報（Launch Intent）」は構造的に無視されます。そのため、プラグイン任せではコールドスタート検知は機能しません。

### 解決策: MethodChannelによる起動データの手動取得

この構造的欠落を補うため、Androidネイティブ側から直接起動データを取得する「Pull型」の実装を追加します。

1.  **Android Native (`MainActivity.kt`)**:
    *   アプリ起動時の `Intent` から `NDEF Message` を直接抽出。
    *   `MethodChannel` を通じて、Dart側からの要求に応じてそのデータを返す。

    **MainActivity.kt 実装概要（最小構成）**:

    ```kotlin
    class MainActivity: FlutterActivity() {
        private val CHANNEL = "com.toolart.portablesec/nfc" // 任意のチャンネル名

        override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
            super.configureFlutterEngine(flutterEngine)
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
                if (call.method == "getLaunchNdefMessage") {
                    // ここで intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES) を取得して返す
                    // 詳細はソースコード参照
                    result.success(getLaunchNdefMessageMap())
                } else {
                    result.notImplemented()
                }
            }
        }
    }
    ```

2.  **Flutter Dart (`NfcServiceImpl.dart`)**:
    *   `init()` 時に `MethodChannel` を叩いて起動データをチェック。
    *   データがあれば、それを `NfcData` として手動で生成し、NFC検出通知用のストリームに流す。
    *   その後は通常通り `NfcManager` を開始し、フォアグラウンド検知に任せる。

これにより、NFC Managerプラグインが準備できる前のデータを確実に取り込みつつ、その後の動作は既存の `NfcManager` の仕組みを維持しています。


