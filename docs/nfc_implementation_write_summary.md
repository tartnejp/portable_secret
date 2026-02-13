# NFC書き込み実装詳細 (Write Implementation Summary)


本ドキュメントは、NFCタグへの書き込みプロセス、特に容量管理と安全対策に関する実装詳細をまとめたものです。

## 1. 書き込みデータの構成

セキュリティとNDEF規格への準拠を両立するため、独特のデータ構造を採用しています。

### データ構造 (Payload Structure)
書き込まれるデータは、以下の要素で構成されたバイナリ列です。

`[Hint Byte (1)] + [Encrypted Blob (N bytes)]`

*   **Hint Byte (1 byte)**:
    *   目的: 読み取り時に、どのロック方式（パスワード、PIN、パターン等）で解除すべきかを高速に判定するため。
    *   値: `LockType.index + 1` (例: Pattern=1, PIN=2)。自動判別無効設定(`isManualUnlockRequired=true`)時は `0x00` (Unknown/Secure) となり、総当たり攻撃に対する耐性を高めます。
*   **Encrypted Blob**:
    *   暗号化された実データ。PSECヘッダー、Salt、IVを含みます。

## 2. 容量計算ロジック (Capacity Calculation)

ユーザーが入力項目を追加している間、リアルタイムで正確な容量予測を行います。`CapacityCalculator` は以下の手順でバイト数を積み上げ計算します：

1.  **JSON化**: 入力項目（キー・値）を `SecretData` オブジェクトに変換し、JSON文字列へシリアライズしてUTF-8バイト配列化します。
2.  **ヘッダー付与**: PSEC独自のヘッダー (38 bytes) を前方に結合します。
3.  **パディング計算**: AES暗号化に必要なブロックサイズ (16 bytes) に合わせて PKCS7 パディング分を加算します。
4.  **ラッパー付与**: 暗号化データにさらに Salt, IV, Hint Byte (計33 bytes) のオーバーヘッドを加算します。
5.  **NDEFオーバーヘッド計算**: 上記の合計ペイロード長に基づき、NFCタグのレコードヘッダーサイズ（Short Record か Normal Record かによる変動を含む）を厳密に計算して加算します。具体的には、 レコードフラグ、タイプ長、ID長、ペイロード長、MIMEタイプを含みます。


### 計算式
合計サイズ = `NDEF Overhead` + `App Wrapper Overhead` + `Encrypted Content Size`

#### 詳細内訳
1.  **実データ (JSON)**: ユーザー入力データをJSON化 + UTF-8エンコード。
2.  **暗号化ペイロード (Plaintext)**:
    *   `PSEC Header` (38 bytes): Magic(4) + Version(1) + Type(1) + Hash(32)
    *   `JSON Data` (可変長)
3.  **AESパディング**: PKCS7 (16byteブロック) によるパディング。
4.  **App Wrapper Overhead (33 bytes)**:
    *   Hint Byte (1) + Salt (16) + IV (16)
5.  **NDEF Overhead**:
    *   ペイロード長が255バイト以下なら `Short Record (SR=1)`、それ以上なら `Normal Record (SR=0)` としてヘッダーサイズを分岐計算。
    *   MIMEタイプ `application/portablesec` (23 bytes) の長さも加算。

これにより、書き込みエラーを未然に防ぎます。

## 3. 書き込みプロセスと安全対策

### 処理フロー (`CreationNotifier.writeToNfc`)

1.  **ハッシュ生成**: 入力されたロック解除キー（パターンの数字列など）から検証用ハッシュを生成。
2.  **データ暗号化**: `EncryptionService` によりデータを暗号化。
3.  **ペイロード構築**: Hint Byteと結合。
4.  **事前容量チェック**: `CapacityCalculator` の結果と `state.maxCapacity` (タグ読み取り時に取得済み) を比較。

### 実行時チェック (`NfcServiceImpl.startWrite`)

実際にタグにかざして書き込む瞬間にも、物理的なタグ容量に対する最終チェックを行います。

```dart
// Capacity Check
if (message.byteLength > ndef.maxSize) {
  _writeController!.add(
    NfcCapacityError(message.byteLength, ndef.maxSize),
  );
  return; // 書き込み中止
}
```

この二重チェック（入力時の事前チェック + 書き込み時の物理チェック）により、タグの破損や中途半端なデータ書き込みを防ぎます。

## 4. セッションとUXの最適化

### 書き込み成功時の挙動
書き込みが成功 (`NfcWriteSuccess`) しても、**即座にNFCセッションを切断しません**。

*   **理由**: Androidではセッションを切断すると即座に次のタグ検知（Discovery）が始まります。ユーザーがまだタグをスマホに密着させている場合、書き込み直後に「新しいタグが見つかりました」という通知が出たり、アプリが二重に起動しようとする問題が発生します。
*   **対策**: 完了ダイアログが表示されている間はセッションを維持（Pause状態のような扱い）し、ユーザーが「OK」を押して画面を離脱するタイミングで `resetSession()` を呼び出し、安全に通常のスキャンモードへ戻します。
