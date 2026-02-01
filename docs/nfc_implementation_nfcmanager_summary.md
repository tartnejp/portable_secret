# NFC Manager 実装詳細 (Implementation Details)

本ドキュメントは `doc/nfc_implementation_summary.md` の補足資料であり、`nfc_manager` パッケージ固有の技術的詳細と、生のNFCデータをアプリケーションドメインオブジェクトに変換するための実装上の選択について記述します。

## 1. パッケージ概要と制限事項

`nfc_manager` パッケージは、AndroidおよびiOSのNFCインタラクションのための統一されたAPIを提供します。

- **Android実装**: Androidの `NfcAdapter.enableReaderMode` API をラップしています。
- **iOS実装**: `CoreNFC` をラップしています。

使用する`nfc_manager` パッケージはバージョン4である必要があります。なお本ドキュメントでは、4.1.1で実装した時の内容を記載しています。
バージョン4でNdefクラスやNdefRecordクラスを使用するのに以下のインポート文が必要なことに注意が必要です。
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';

### 重要な制限: 起動インテント (Launch Intent)
Androidにおいて、`nfc_manager` は `ReaderMode` に依存しており、これはセッションがフォアグラウンドでアクティブな間のみタグを検出します。アプリケーションを起動した `NDEF_DISCOVERED` インテント（コールドスタート）を**自動的には捕捉しません**。

**影響**:
この制限が、メインサマリで説明されているカスタム `MethodChannel` 実装が必要となる主たる理由です。`NfcServiceImpl` は、アプリ起動時にデータが失われないように、`nfc_manager` が制御を開始する前にチャネル経由で起動インテントを明示的にチェックします。

## 2. 読み込みプロセス (`NfcServiceImpl`)

本サービスは `NfcTag` を生の入力として扱い、標準化された操作のために `Ndef` オブジェクトへ変換します。

### データフロー
1.  **セッション開始**: `NfcManager.startSession` がポーリングオプションと共に呼び出されます。
2.  **タグ検出**: コールバックが `NfcTag` オブジェクトを受け取ります。
3.  **NDEF解釈**: `Ndef.from(tag)` を使用してタグをNDEFとして解釈しようと試みます。
    - `null` の場合: タグがNDEFをサポートしていないか、ロックされている/未フォーマット等の理由で `nfc_manager` が読み取れません。
    - 有効な場合: `ndef.cachedMessage` にアクセスして現在のペイロードを読み取ります。

## 3. 書き込みプロセス

書き込みには、`Ndef` オブジェクトの可用性と書き込み可能性の慎重なハンドリングが必要です。

### 手順
1.  **モード切替**: サービスは `NfcOperationMode.write` に切り替わります。
2.  **検証**:
    *   `ndef.isWritable` をチェックします。
    *   **上書き防止**: `ndef.cachedMessage` をチェックします。レコードが存在し、かつ `_allowOverwrite` が false の場合、書き込みを中断し、`NfcWriteOverwriteRequired` ステートをUIに通知します。
3.  **レコード生成**:
    `nfc_manager` は低レベルな `NdefRecord` コンストラクタしか提供しないため、標準準拠を保証するために一般的なタイプ用の手動ヘルパー（実装内の `_createRecord` 参照）を実装しています：
    *   **URI**: `TypeNameFormat.wellKnown` とタイプ `U` (0x55) を使用。プレフィックスバイト圧縮（例：`https://` に対する `0x04`）を処理します。
    *   **Text**: `TypeNameFormat.wellKnown` とタイプ `T` (0x54) を使用。言語コード長のステータスバイト（例：'en' に特有）を含みます。
    *   **MIME**: バイトペイロードに対して `TypeNameFormat.media` を使用します。
    *   **External**: Android Application Records (AAR) やカスタムドメインに対して `TypeNameFormat.external` （例：`android.com:pkg`）を使用します。

## 4. セッション管理戦略

「バックグラウンドでのタグ監視」と「アクティブなスキャン/書き込み」のバランスを取るため、サービスはセッションのライフサイクルを明示的に管理します。

- **スキャン停止**: `stopScan()` を呼ぶと強制的に `NfcManager.stopSession()` が実行されます。これは、他のシステム動作を許可したり、次の操作のためにクリーンな状態を確保するために、`ReaderMode` フラグのリセットやクリアが必要になる場合があるため重要です。
- **クリーンアップ**: `dispose` または `stopScan` において、メモリリークを防ぐためにストリームを閉じ、NFCハードウェアの優先権を解放するためにセッションを停止します。

## 5. 一般的なバイト識別子リファレンス

`NdefRecord` の生データをデバッグする際、以下の識別子が使用されます：

| Identifier / Type | Byte Value | Description |
| :--- | :--- | :--- |
| **TNF Well Known** | `0x01` | Text, URI, Smart Poster |
| **TNF Mime Media** | `0x02` | Standard MIME (application/json, etc) |
| **TNF External** | `0x04` | Custom types (domain:type) |
| **RTD Text** | `0x54` ('T') | Text Record Type |
| **RTD URI** | `0x55` ('U') | URI Record Type |
