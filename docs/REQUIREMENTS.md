# 🐾 ペット写真ウィジェットアプリ 要件定義書（仮称:PetWidget)

## 1. 背景と目的

iPhoneのウィジェット機能を活用し、ユーザーが「ペットと共に過ごす時間」を日常的に感じられるようにすることを目的としたアプリ。
単なる時計・日付表示にとどまらず、**ペットの写真・名前・年齢(人間換算含む)を自由にレイアウトできる**ことを特徴とする。

---

## 2. 開発目標(MVP)

| カテゴリ | 要件内容 |
|-----------|-----------|
| 🐶 ペット登録 | ペットの写真・名前・生年月日・種別(犬/猫など)を登録可能 |
| 🕒 時計・日付表示 | 現在時刻(12/24h切替)、日付(和暦・西暦対応)を表示 |
| 📅 年齢計算 | 登録生年月日から自動で年齢を算出(年月単位) |
| 👤 人間換算年齢 | 種別ごとの換算式で表示(例:3歳=人間28歳) |
| 🖼️ レイアウト編集 | 表示項目ON/OFF・文字サイズ・配置のカスタマイズ可能 |
| 🧁 ウィジェット化 | ホーム画面にスモール/ミディアム/ラージで配置可能 |
| 💾 データ保持 | App Group経由でアプリとウィジェット間のデータ共有 |
| 🐾 多頭対応 | 複数ペット登録およびウィジェットごとの切替可能 |

---

## 3. システム構成概要

```
+-------------------+
|  iOSホーム画面    |
| [WidgetKit表示]   |
|  ├ 時計・日付     |
|  ├ ペット写真 🐾  |
|  └ 名前・年齢     |
+---------▲---------+
          │ App Group共有
+---------▼---------+
|  PetWidget App    |
| SwiftUI設定画面   |
|  ├ ペット情報入力 |
|  ├ レイアウト編集 |
|  └ テーマ選択     |
+-------------------+
```

---

## 4. 機能要件

### 4.1 ペット登録機能

- 名前、誕生日、種別(犬/猫/その他)、写真を登録
- 生年月日から年齢を自動算出
- 写真は `PhotosPicker` から選択し、端末ローカルに保存

### 4.2 表示機能(ウィジェット)

- 表示項目:写真、名前、年齢、人間換算年齢、時刻、日付
- ウィジェットサイズ別レイアウト対応(Small/Medium/Large)
- TimelineProvider による1分単位の時刻更新

### 4.3 カスタマイズ機能

- 表示項目のON/OFF
- 文字サイズ・フォントカラー・配置を変更
- 写真の枠形状(円形/角丸)
- 背景テーマ(ライト/ダーク/カスタムカラー/写真)

### 4.4 多頭対応

- 複数ペットの登録
- 各ウィジェットで表示するペットを個別に指定

### 4.5 データ保持

- アプリ内設定値とペット情報を `CoreData` で管理
- App Group経由でウィジェットにデータ共有
- データは端末ローカルにのみ保存

---

## 5. 非機能要件

| カテゴリ | 要件内容 |
|-----------|-----------|
| 対応OS | iOS 16以降 |
| 開発環境 | Xcode 16, Swift 5.10 以降 |
| 言語 | SwiftUI + WidgetKit |
| 更新頻度 | ウィジェットは最大15分間隔で自動更新(時刻は毎分再描画) |
| セキュリティ | 写真データはローカル保存のみ、外部送信なし |
| パフォーマンス | 初期起動3秒以内、ウィジェット読み込み1秒以内 |

---

## 6. 技術選定理由

| 項目 | 採用技術 | 理由 |
|------|-----------|------|
| 開発言語 | Swift | Apple公式推奨、WidgetKit対応必須 |
| UI | SwiftUI | 宣言的UI構築が容易、プレビュー即時反映 |
| ウィジェット拡張 | WidgetKit | iOS標準ウィジェット実装に必須 |
| データ保存 | CoreData / App Group | 複数ペット対応とデータ共有に最適 |
| 写真管理 | PhotosPicker | 安全なアクセス管理(iOS16+) |
| 設定保持 | AppStorage / UserDefaults | 軽量なユーザー設定反映 |
| 年齢計算 | Calendar API | 高精度な年月差算出 |
| 人間換算 | カスタムロジック | 種別別換算式を柔軟に拡張可能 |

---

## 7. データモデル

```swift
struct Pet: Identifiable, Codable {
    var id: UUID
    var name: String
    var birthDate: Date
    var species: PetType // .dog / .cat / .other
    var photoData: Data?
}

enum PetType: String, Codable {
    case dog, cat, other
}
```

### 年齢換算ロジック(例)

```swift
func humanAge(for pet: Pet, realAge: Double) -> Int {
    switch pet.species {
    case .dog, .cat:
        return Int(24 + max(0, (realAge - 2)) * 4)
    default:
        return Int(realAge * 5)
    }
}
```

---

## 8. カスタマイズ設定仕様

| 設定項目 | 型 | 説明 |
|----------|-----|------|
| 表示項目 | [String: Bool] | 名前・年齢などの表示ON/OFF |
| フォントサイズ | Double | ピクセル単位で調整可能 |
| フォントカラー | String(hex) | カラーピッカーで指定 |
| 写真枠形状 | Enum(circle, roundedRect) | 枠デザイン選択 |
| 背景テーマ | Enum(light, dark, customColor, photo) | 背景設定 |

---

## 9. プライバシー・セキュリティ要件

- 写真・設定データは端末内ローカル保存
- ネットワーク通信は行わない
- プライバシーポリシーをApp Storeに明記
- App Groupの利用範囲は同一開発者署名内に限定

---

## 10. 開発フェーズ

### Phase 1: 基本実装
- [ ] プロジェクト初期設定
- [ ] ペット登録画面実装
- [ ] 基本ウィジェット表示(Medium)
- [ ] 年齢計算ロジック実装

### Phase 2: カスタマイズ機能
- [ ] レイアウト編集機能
- [ ] テーマ設定機能
- [ ] 複数サイズ対応(Small/Large)

### Phase 3: 拡張機能
- [ ] 多頭対応
- [ ] ウィジェット設定個別化
- [ ] パフォーマンス最適化

### Phase 4: リリース準備
- [ ] テスト・デバッグ
- [ ] App Store申請準備
- [ ] ドキュメント整備

---

## 11. 参考リソース

- [WidgetKit | Apple Developer Documentation](https://developer.apple.com/documentation/widgetkit)
- [SwiftUI | Apple Developer Documentation](https://developer.apple.com/documentation/swiftui)
- [App Groups | Apple Developer Documentation](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups)
