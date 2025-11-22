# ウィジェット表示不具合の調査と修正報告 (2025/11/22)

## 概要
Xcodeシミュレーターでは正常に動作するが、実機（iPhone 16）においてウィジェットが何も表示されない（またはスケルトン表示のままになる）不具合が発生。
また、修正過程でアプリ本体が「読み込み中...」で止まる現象も確認された。

## 原因

### 1. Core Dataモデルの読み込み失敗
**現象:** ウィジェットがデータを取得できず、エラーまたは空の状態になる。
**詳細:** `CoreDataStack` クラスがモデルファイル (`.momd`) を探す際、`Bundle.main`（アプリ本体のバンドル）を優先して探していた。実機のウィジェット拡張機能（Extension）環境ではバンドル構成が異なるため、モデルファイルが見つからずに初期化に失敗していた。

### 2. Target Membershipの設定漏れ
**現象:** ウィジェット側でCore Dataのエンティティ定義が見つからない。
**詳細:** `PetWidget.xcdatamodeld` ファイルが、アプリ本体のターゲット (`PetWidget`) には含まれていたが、ウィジェット拡張機能のターゲット (`PetWidgetExtension`) にチェックが入っていなかった。これにより、ウィジェットビルド時にモデルファイルが含まれていなかった。

### 3. Core Data初期化処理の呼び出し漏れ
**現象:** アプリ本体が「読み込み中...」で止まる、ウィジェットがスケルトン表示になる。
**詳細:** `CoreDataStack.shared.setup()` メソッドが、アプリ (`PetWidgetApp`) およびウィジェット (`PetWidgetExtension`) の起動時 (`init`) に明示的に呼び出されていなかった。これまでは `PetDataManager` の初期化時に副作用として呼ばれていたが、呼び出し順序によっては初期化されず、`viewContext` が利用できない状態になっていた。

## 修正内容

### 1. コード修正: CoreDataStack.swift
モデルファイルの検索ロジックを変更し、`CoreDataStack` クラス自身が含まれるバンドル (`Bundle(for: CoreDataStack.self)`) を最優先で探すように修正。これにより、アプリ・ウィジェットどちらの環境でも正しくモデルをロードできるようになった。

```swift
// 修正前
// Bundle.main を優先探索

// 修正後
let bundle = Bundle(for: CoreDataStack.self) // クラス定義のあるバンドルを優先
```

### 2. 設定修正: Xcode Target Membership
`PetWidget.xcdatamodeld` の File Inspector にて、`PetWidgetExtension` にチェックを追加。

### 3. コード修正: エントリーポイント (App & Extension)
`PetWidgetApp.swift` と `PetWidgetExtension.swift` の `init()` メソッド内に、明示的なセットアップ処理を追加。

```swift
init() {
    do {
        try CoreDataStack.shared.setup()
    } catch {
        print("Failed to setup CoreDataStack: \(error)")
    }
}
```

## 今後の対策
- 新しいターゲット（Extensionなど）を追加した際は、共有リソース（Core Dataモデル、Utilityクラスなど）の **Target Membership** を必ず確認する。
- シングルトンの初期化 (`setup`) は、使用する側のエントリーポイントで明示的に呼び出す設計を徹底する。
