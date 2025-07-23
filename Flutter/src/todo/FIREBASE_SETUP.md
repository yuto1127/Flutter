# Firebase設定手順

このTodoアプリケーションをFirebase Firestoreと接続するための設定手順です。

## 1. Firebaseプロジェクトの作成

1. [Firebase Console](https://console.firebase.google.com/) にアクセス
2. 「プロジェクトを追加」をクリック
3. プロジェクト名を入力（例：todo-app）
4. Google Analyticsの有効化は任意
5. プロジェクトを作成

## 2. Firestoreデータベースの設定

1. Firebase Consoleで「Firestore Database」を選択
2. 「データベースを作成」をクリック
3. セキュリティルールを選択（本番環境では適切なルールを設定）
4. 場所を選択（例：asia-northeast1）

## 3. セキュリティルールの設定

Firestore Database > ルール で以下のルールを設定：

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /TodoData/{document} {
      allow read, write: if true; // 開発用（本番環境では適切な認証を設定）
    }
  }
}
```

## 4. Android設定

1. Firebase Consoleで「プロジェクトの設定」を選択
2. 「アプリを追加」でAndroidアプリを追加
3. パッケージ名：`com.example.todo`
4. アプリの登録
5. `google-services.json`ファイルをダウンロード
6. ダウンロードしたファイルを `android/app/` ディレクトリに配置
7. 既存のテンプレートファイルを上書き

## 5. iOS設定

1. Firebase Consoleで「プロジェクトの設定」を選択
2. 「アプリを追加」でiOSアプリを追加
3. Bundle ID：`com.example.todo`
4. アプリの登録
5. `GoogleService-Info.plist`ファイルをダウンロード
6. ダウンロードしたファイルを `ios/Runner/` ディレクトリに配置
7. 既存のテンプレートファイルを上書き

## 6. 依存関係のインストール

```bash
flutter pub get
```

## 7. アプリの実行

```bash
flutter run
```

## データ構造

Firestoreの`TodoData`コレクションには以下のフィールドが含まれます：

- `description` (string): Todoの説明
- `limit` (timestamp): 期限（null可）
- `status` (boolean): 完了状態（デフォルト：false）
- `createdAt` (timestamp): 作成日時

## 注意事項

- 本番環境では適切なセキュリティルールを設定してください
- APIキーなどの機密情報は公開リポジトリにコミットしないでください
- 現在の設定は開発用です 