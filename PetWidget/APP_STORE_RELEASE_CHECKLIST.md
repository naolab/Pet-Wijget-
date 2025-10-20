# App Store リリースチェックリスト

## プロジェクト情報
- **アプリ名**: PetWidget
- **Bundle ID**: com.nao.PetWidget
- **現在のバージョン**: 1.0 (Build 1)
- **ターゲット**: iOS 26.0+

---

## 1. アプリアイコン (最優先・必須)

### 必要なファイル
- [ ] 1024x1024px のアプリアイコン画像 (PNG形式、透過なし)

### 配置場所
```
PetWidget/PetWidget/Assets.xcassets/AppIcon.appiconset/
```

### 注意事項
- アルファチャンネル(透過)は使用不可
- 角丸は自動で適用されるため、四角い画像を用意
- 最低でも1024x1024pxの画像が必須

---

## 2. プライバシーマニフェスト (必須)

### 作成が必要なファイル
- [ ] `PrivacyInfo.xcprivacy` ファイルを作成

### 含めるべき内容
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryPhotoLibrary</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>ペットの写真を選択してウィジェットに表示するため</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

### 配置場所
- メインアプリターゲット (`PetWidget/PetWidget/`)
- ウィジェットエクステンション (`PetWidget/PetWidgetExtension/`)

---

## 3. Apple Developer Program

### 必要な準備
- [ ] Apple Developer Program への登録 (年間 14,800円)
- [ ] App Store Connect へのアクセス確認
- [ ] 配布用証明書の作成
  - Distribution Certificate
  - App Store Provisioning Profile
- [ ] App Store Connect でアプリを新規登録
  - Bundle ID: `com.nao.PetWidget`

---

## 4. App Store Connect メタデータ

### アプリ情報
- [ ] **アプリ名** (日本語)
  - 表示名 (最大30文字)
  - App Store表示名を決定

- [ ] **アプリ名** (英語)
  - 英語圏向けのアプリ名

- [ ] **サブタイトル** (最大30文字)
  - アプリの簡潔な説明

- [ ] **説明文**
  - 日本語版 (最大4,000文字)
  - 英語版

- [ ] **キーワード** (最大100文字)
  - ペット, ウィジェット, 猫, 犬, 写真, など

- [ ] **カテゴリ**
  - プライマリカテゴリ: ライフスタイル or ユーティリティ
  - セカンダリカテゴリ (任意)

- [ ] **年齢制限**
  - 4+ 推奨

### スクリーンショット (必須)

最低限必要なサイズ:
- [ ] **6.7インチディスプレイ** (iPhone 15 Pro Max など)
  - 1290 x 2796 px
  - 最低3枚、最大10枚

- [ ] **6.5インチディスプレイ** (iPhone 11 Pro Max など)
  - 1284 x 2778 px
  - 最低3枚、最大10枚

推奨追加サイズ:
- [ ] 5.5インチディスプレイ (iPhone 8 Plus など)
  - 1242 x 2208 px

### プレビュー動画 (任意)
- [ ] アプリの使い方を紹介する短い動画
  - 最大30秒
  - スクリーンショットと同じサイズ

### URL情報
- [ ] **サポートURL** (必須)
  - お問い合わせページやヘルプページのURL

- [ ] **マーケティングURL** (任意)
  - アプリの公式サイト

- [ ] **プライバシーポリシーURL** (必須)
  - データの取り扱いに関するページ

### その他
- [ ] **著作権表記**
  - 例: 2025 Your Name

- [ ] **価格設定**
  - 無料 or 有料

---

## 5. コード署名・ビルド設定

### Entitlements の確認
現在の設定:
```xml
- aps-environment: development
- App Groups: group.com.nao.petwidget
- CloudKit: 有効
```

- [ ] **プッシュ通知を使う場合**
  - `aps-environment` を `production` に変更

- [ ] **本番用プロビジョニングプロファイル**
  - Development から Distribution に変更
  - App Store Connectで設定

### ビルド構成
- [ ] Release 構成でビルドエラーがないことを確認
- [ ] アーカイブの作成テスト
  - Xcode > Product > Archive

---

## 6. バージョン管理

### 現在のバージョン
- Marketing Version: 1.0
- Build Number: 1

### リリース前の確認
- [ ] バージョン番号の確認・更新
- [ ] ビルド番号の確認
- [ ] リリースノートの準備

---

## 7. テスト

### 実機テスト
- [ ] 各種iPhoneでの動作確認
- [ ] ウィジェットの表示確認
  - Small, Medium, Large サイズ
- [ ] 写真選択機能の動作確認
- [ ] データ保存・復元の確認
- [ ] App Group によるデータ共有の確認

### TestFlight (推奨)
- [ ] TestFlightにビルドをアップロード
- [ ] 内部テスターでのテスト
- [ ] 外部テスターでのテスト (任意)
- [ ] クラッシュレポートの確認

---

## 8. App Store 審査対策

### 審査で問われる可能性がある項目
- [ ] **デモアカウント**
  - 特殊な機能がある場合、テスト用アカウント情報を提供

- [ ] **審査ノート**
  - アプリの使い方や特記事項を記載

- [ ] **プライバシー関連**
  - データ収集の有無
  - 第三者との共有の有無
  - トラッキングの有無

### リジェクト対策
- [ ] App Storeレビューガイドラインの確認
  - https://developer.apple.com/app-store/review/guidelines/
- [ ] 最小限の機能でクラッシュしないことを確認
- [ ] すべての約束した機能が動作することを確認

---

## 9. 提出前の最終確認

- [ ] すべてのビルドエラー・警告の解消
- [ ] メモリリークのチェック
- [ ] パフォーマンステスト
- [ ] アクセシビリティのチェック
- [ ] 多言語対応 (日本語・英語)
- [ ] 利用規約・プライバシーポリシーの準備

---

## 10. リリース手順

1. [ ] Xcodeでアーカイブを作成
2. [ ] App Store Connectにアップロード
3. [ ] TestFlightでテスト (推奨)
4. [ ] App Store Connectでメタデータ入力
5. [ ] 審査に提出
6. [ ] 審査結果を待つ (通常1-3日)
7. [ ] 承認後、リリース日を設定

---

## 現在のステータス

### 完了済み
- ✅ アプリのビルド成功
- ✅ 基本機能の実装完了
- ✅ ウィジェット機能の実装完了

### 未完了 (優先度順)
1. ⚠️ **アプリアイコンの作成** (最優先)
2. ⚠️ **プライバシーマニフェストの作成**
3. ⚠️ **Apple Developer Program 登録・証明書設定**
4. ⚠️ **App Store Connect メタデータの準備**
5. ⚠️ **スクリーンショット・プレビューの作成**
6. ⚠️ **サポートURL・プライバシーポリシーURLの準備**
7. ⚠️ **TestFlightでのテスト**

---

## 参考リンク

- [App Store Connect](https://appstoreconnect.apple.com/)
- [Apple Developer](https://developer.apple.com/)
- [App Store審査ガイドライン](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines - App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [プライバシーマニフェストファイル](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files)
