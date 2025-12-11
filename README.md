# ScamGuard

国際電話や警察庁が提供する詐欺番号リストからの着信・発信を遮断するiOSアプリの初期プロジェクトです。

## 特徴
- SwiftUIベースのダッシュボードUI
- 警察庁推奨番号リスト（疑似データ）と国際番号のブロック設定
- AIによるリスク検知イベント（モックサービス）と検知ログ表示
- 防犯アドバイザリ通知（モックサービス）
- XcodeGen用 `project.yml` を同梱

## 開発手順
1. [XcodeGen](https://github.com/yonaskolb/XcodeGen) をインストールします。
2. リポジトリ直下で `xcodegen` を実行し `ScamGuard.xcodeproj` を生成します。
3. 生成されたプロジェクトをXcodeで開き、`ScamGuardApp` ターゲットを実機またはシミュレータで実行してください。
4. `ScamDetectionService` や `ScamNumberProvider` を実サービスに置き換えれば、警察庁の公式リスト連携やAI検知を実装できます。

## ディレクトリ
- `App/Sources`: アプリ本体のSwiftUIコード
- `App/Resources`: Assetカタログなどリソース配置場所
- `project.yml`: XcodeGen用の設定ファイル
