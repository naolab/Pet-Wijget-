# 🏗️ PetWidget アーキテクチャ設計書

## 1. システムアーキテクチャ概要

### 1.1 全体構成

```
┌─────────────────────────────────────────────────────────┐
│                     iOS Device                          │
│                                                         │
│  ┌──────────────────┐      ┌────────────────────────┐ │
│  │   Main App       │      │   Widget Extension     │ │
│  │   (PetWidget)    │      │   (PetWidgetExtension) │ │
│  │                  │      │                        │ │
│  │  ┌────────────┐  │      │  ┌──────────────────┐ │ │
│  │  │   Views    │  │      │  │  Widget Views    │ │ │
│  │  │  (SwiftUI) │  │      │  │   (SwiftUI)      │ │ │
│  │  └──────┬─────┘  │      │  └────────┬─────────┘ │ │
│  │         │        │      │           │           │ │
│  │  ┌──────▼─────┐  │      │  ┌────────▼─────────┐ │ │
│  │  │ ViewModels │  │      │  │ TimelineProvider │ │ │
│  │  └──────┬─────┘  │      │  └────────┬─────────┘ │ │
│  │         │        │      │           │           │ │
│  │  ┌──────▼─────┐  │      │  ┌────────▼─────────┐ │ │
│  │  │   Models   │◄─┼──────┼─►│     Models       │ │ │
│  │  └──────┬─────┘  │      │  └────────┬─────────┘ │ │
│  │         │        │      │           │           │ │
│  │  ┌──────▼─────┐  │      │  ┌────────▼─────────┐ │ │
│  │  │ DataManager│◄─┼──────┼─►│   DataManager    │ │ │
│  │  └──────┬─────┘  │      │  └────────┬─────────┘ │ │
│  │         │        │      │           │           │ │
│  └─────────┼────────┘      └───────────┼───────────┘ │
│            │                           │             │
│            └───────────┬───────────────┘             │
│                        │                             │
│                  ┌─────▼──────┐                      │
│                  │ App Group  │                      │
│                  │ Container  │                      │
│                  │            │                      │
│                  │ ┌────────┐ │                      │
│                  │ │CoreData│ │                      │
│                  │ │  Store │ │                      │
│                  │ └────────┘ │                      │
│                  │            │                      │
│                  │ ┌────────┐ │                      │
│                  │ │UserDef-│ │                      │
│                  │ │aults   │ │                      │
│                  │ └────────┘ │                      │
│                  └────────────┘                      │
└─────────────────────────────────────────────────────┘
```

### 1.2 レイヤー構成

| レイヤー | 責務 | 主要コンポーネント |
|----------|------|-------------------|
| **Presentation** | UI表示・ユーザー操作 | SwiftUI Views, Widget Views |
| **Application** | ビジネスロジック | ViewModels, TimelineProvider |
| **Domain** | データモデル定義 | Pet, Settings, Enums |
| **Infrastructure** | データ永続化 | CoreData, UserDefaults, PhotosManager |

---

## 2. モジュール設計

### 2.1 Main App (PetWidget)

#### 責務
- ペット情報の登録・編集・削除
- レイアウト・テーマのカスタマイズ
- 写真の選択・保存

#### 主要コンポーネント

```
PetWidget/
├── App/
│   └── PetWidgetApp.swift          # アプリエントリーポイント
├── Views/
│   ├── PetListView.swift           # ペット一覧画面
│   ├── PetDetailView.swift         # ペット詳細・編集画面
│   ├── PetRegistrationView.swift  # ペット新規登録画面
│   ├── SettingsView.swift          # 設定画面
│   └── Components/
│       ├── PetPhotoPickerView.swift
│       ├── DatePickerField.swift
│       └── ThemePickerView.swift
├── ViewModels/
│   ├── PetListViewModel.swift
│   ├── PetDetailViewModel.swift
│   └── SettingsViewModel.swift
└── Resources/
    └── Assets.xcassets
```

### 2.2 Widget Extension (PetWidgetExtension)

#### 責務
- ホーム画面へのウィジェット表示
- 時刻の定期更新
- ペット情報の表示

#### 主要コンポーネント

```
PetWidgetExtension/
├── PetWidgetBundle.swift            # WidgetBundle定義
├── PetWidget.swift                  # Widget本体
├── TimelineProvider.swift           # Timeline更新ロジック
├── Views/
│   ├── SmallWidgetView.swift       # Smallサイズ用View
│   ├── MediumWidgetView.swift      # Mediumサイズ用View
│   └── LargeWidgetView.swift       # Largeサイズ用View
└── Resources/
    └── Assets.xcassets
```

### 2.3 Shared Module

#### 責務
- アプリとウィジェット間で共有するコード
- データモデル・データ管理・ユーティリティ

#### 主要コンポーネント

```
Shared/
├── Models/
│   ├── Pet.swift                    # ペットデータモデル
│   ├── PetType.swift                # ペット種別Enum
│   ├── WidgetSettings.swift         # ウィジェット設定
│   └── DisplaySettings.swift        # 表示設定
├── DataManager/
│   ├── PetDataManager.swift         # ペットデータCRUD
│   ├── SettingsManager.swift        # 設定管理
│   └── CoreDataStack.swift          # CoreDataセットアップ
├── Utilities/
│   ├── AgeCalculator.swift          # 年齢計算ロジック
│   ├── HumanAgeConverter.swift      # 人間換算ロジック
│   ├── DateFormatter+Extensions.swift
│   └── PhotoManager.swift           # 写真保存・読込
└── CoreData/
    └── PetWidget.xcdatamodeld       # CoreDataモデル
```

---

## 3. データフロー

### 3.1 ペット登録フロー

```
User Input (View)
    ↓
ViewModel.addPet()
    ↓
PetDataManager.create()
    ↓
CoreData.save()
    ↓
App Group Container
    ↓
WidgetCenter.reloadTimelines()
    ↓
Widget Update
```

### 3.2 ウィジェット更新フロー

```
iOS System Timer
    ↓
TimelineProvider.getTimeline()
    ↓
PetDataManager.fetch()
    ↓
App Group Container (CoreData)
    ↓
Create Timeline Entries
    ↓
WidgetKit Render
```

---

## 4. データ永続化戦略

### 4.1 CoreData

**用途**: ペット情報の保存

**Entity設計**:
```swift
Entity: PetEntity
- id: UUID (Primary Key)
- name: String
- birthDate: Date
- species: String (dog/cat/other)
- photoData: Binary Data
- createdAt: Date
- updatedAt: Date
```

**保存場所**: App Group Container
```swift
let appGroupID = "group.com.yourcompany.petwidget"
container.persistentStoreDescriptions.first?.url =
    FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: appGroupID
    )?.appendingPathComponent("PetWidget.sqlite")
```

### 4.2 UserDefaults

**用途**: ユーザー設定・表示設定の保存

**保存項目**:
- ウィジェットサイズ別の表示設定
- テーマ設定
- フォント設定
- 時刻フォーマット(12h/24h)

**保存場所**: App Group UserDefaults
```swift
let defaults = UserDefaults(suiteName: "group.com.yourcompany.petwidget")
```

---

## 5. 通信・同期設計

### 5.1 アプリ⇔ウィジェット間通信

**手段**: App Group Container (CoreData + UserDefaults)

**同期タイミング**:
- アプリでペット情報更新時
- アプリで設定変更時
- ウィジェットタイムライン更新時(最大15分間隔)

**更新通知**:
```swift
// アプリ側でデータ更新後
WidgetCenter.shared.reloadAllTimelines()

// または特定ウィジェットのみ
WidgetCenter.shared.reloadTimelines(ofKind: "PetWidget")
```

---

## 6. パフォーマンス最適化

### 6.1 画像最適化

- **保存時**: リサイズ(最大800x800px)、JPEG圧縮(0.8品質)
- **読込時**: キャッシュ利用、非同期読み込み
- **ウィジェット**: さらに小サイズ(最大300x300px)にリサイズ

### 6.2 メモリ管理

- **CoreData**: NSBatchFetchRequest使用、Fault回避
- **画像**: 必要時のみData→UIImageに変換
- **ウィジェット**: メモリ上限30MBを考慮

### 6.3 バッテリー消費対策

- ウィジェット更新頻度を最小限に(15分間隔)
- 時刻表示のみ毎分更新(TimelineEntry使用)
- バックグラウンド処理の最小化

---

## 7. エラーハンドリング

### 7.1 エラーの種類

```swift
enum PetWidgetError: LocalizedError {
    case dataLoadFailed
    case dataSaveFailed
    case photoAccessDenied
    case photoSaveFailed
    case invalidData

    var errorDescription: String? {
        switch self {
        case .dataLoadFailed: return "データの読み込みに失敗しました"
        case .dataSaveFailed: return "データの保存に失敗しました"
        case .photoAccessDenied: return "写真へのアクセスが拒否されました"
        case .photoSaveFailed: return "写真の保存に失敗しました"
        case .invalidData: return "不正なデータです"
        }
    }
}
```

### 7.2 エラー表示戦略

- **アプリ内**: Alert表示、再試行オプション提供
- **ウィジェット**: フォールバック表示(デフォルトペット/プレースホルダー)

---

## 8. セキュリティ設計

### 8.1 データ保護

- **写真データ**: 端末内ローカル保存のみ
- **App Group**: 同一開発者署名アプリのみアクセス可
- **外部送信**: 一切なし

### 8.2 アクセス制御

- **写真アクセス**: `NSPhotoLibraryUsageDescription` 設定
- **App Group**: Entitlements設定必須

---

## 9. テスト戦略

### 9.1 単体テスト

- **対象**: ViewModel, DataManager, Utilities
- **ツール**: XCTest
- **カバレッジ目標**: 80%以上

### 9.2 UI テスト

- **対象**: 主要画面遷移、ペット登録フロー
- **ツール**: XCTest UI Testing

### 9.3 ウィジェットテスト

- **手動テスト**: 各サイズでの表示確認
- **タイムライン検証**: 時刻更新の動作確認

---

## 10. 拡張性の考慮

### 10.1 将来の機能拡張

- **多言語対応**: Localizable.strings 準備
- **iCloud同期**: 将来的にCloudKit対応可能な設計
- **Apple Watch対応**: Shared Moduleを活用
- **通知機能**: ペットの誕生日通知など

### 10.2 コード設計原則

- **SOLID原則**: 特に単一責任、依存性逆転を重視
- **プロトコル指向**: DataManagerなどはプロトコル定義
- **疎結合**: ViewModelはDataManagerのプロトコルに依存

```swift
protocol PetDataManagerProtocol {
    func fetchAll() -> [Pet]
    func create(_ pet: Pet) throws
    func update(_ pet: Pet) throws
    func delete(_ pet: Pet) throws
}
```
