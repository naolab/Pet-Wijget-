# 📋 PetWidget API設計書

## 1. データモデル定義

### 1.1 Pet (ペット情報)

```swift
struct Pet: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var birthDate: Date
    var species: PetType
    var photoData: Data?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        birthDate: Date,
        species: PetType,
        photoData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.species = species
        self.photoData = photoData
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // 年齢計算(年単位)
    var ageInYears: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }

    // 年齢計算(月単位まで)
    var ageComponents: DateComponents {
        Calendar.current.dateComponents([.year, .month], from: birthDate, to: Date())
    }

    // 人間換算年齢
    var humanAge: Int {
        HumanAgeConverter.convert(pet: self)
    }
}
```

### 1.2 PetType (ペット種別)

```swift
enum PetType: String, Codable, CaseIterable {
    case dog = "dog"
    case cat = "cat"
    case other = "other"

    var displayName: String {
        switch self {
        case .dog: return "犬"
        case .cat: return "猫"
        case .other: return "その他"
        }
    }

    var icon: String {
        switch self {
        case .dog: return "🐶"
        case .cat: return "🐱"
        case .other: return "🐾"
        }
    }
}
```

### 1.3 WidgetSettings (ウィジェット設定)

```swift
struct WidgetSettings: Codable {
    var selectedPetID: UUID?
    var displaySettings: DisplaySettings
    var themeSettings: ThemeSettings

    static var `default`: WidgetSettings {
        WidgetSettings(
            selectedPetID: nil,
            displaySettings: .default,
            themeSettings: .default
        )
    }
}
```

### 1.4 DisplaySettings (表示設定)

```swift
struct DisplaySettings: Codable {
    // 表示項目ON/OFF
    var showName: Bool
    var showAge: Bool
    var showHumanAge: Bool
    var showTime: Bool
    var showDate: Bool

    // 時刻・日付フォーマット
    var use24HourFormat: Bool
    var dateFormat: DateFormatType

    // フォント設定
    var nameFontSize: CGFloat
    var ageFontSize: CGFloat
    var timeFontSize: CGFloat
    var dateFontSize: CGFloat

    static var `default`: DisplaySettings {
        DisplaySettings(
            showName: true,
            showAge: true,
            showHumanAge: true,
            showTime: true,
            showDate: true,
            use24HourFormat: true,
            dateFormat: .yearMonthDay,
            nameFontSize: 16,
            ageFontSize: 14,
            timeFontSize: 24,
            dateFontSize: 12
        )
    }
}

enum DateFormatType: String, Codable, CaseIterable {
    case yearMonthDay = "yyyy年M月d日"
    case monthDay = "M月d日"
    case dayOfWeek = "M月d日(E)"
    case western = "yyyy/MM/dd"

    var displayName: String {
        switch self {
        case .yearMonthDay: return "2025年1月1日"
        case .monthDay: return "1月1日"
        case .dayOfWeek: return "1月1日(水)"
        case .western: return "2025/01/01"
        }
    }
}
```

### 1.5 ThemeSettings (テーマ設定)

```swift
struct ThemeSettings: Codable {
    var backgroundType: BackgroundType
    var backgroundColor: String // Hex color
    var backgroundImageData: Data?
    var fontColor: String // Hex color
    var photoFrameType: PhotoFrameType

    static var `default`: ThemeSettings {
        ThemeSettings(
            backgroundType: .color,
            backgroundColor: "#FFFFFF",
            backgroundImageData: nil,
            fontColor: "#000000",
            photoFrameType: .circle
        )
    }
}

enum BackgroundType: String, Codable, CaseIterable {
    case color = "color"
    case image = "image"
    case gradient = "gradient"

    var displayName: String {
        switch self {
        case .color: return "単色"
        case .image: return "写真"
        case .gradient: return "グラデーション"
        }
    }
}

enum PhotoFrameType: String, Codable, CaseIterable {
    case circle = "circle"
    case roundedRect = "roundedRect"
    case none = "none"

    var displayName: String {
        switch self {
        case .circle: return "円形"
        case .roundedRect: return "角丸四角"
        case .none: return "なし"
        }
    }
}
```

---

## 2. データ管理API

### 2.1 PetDataManager

```swift
protocol PetDataManagerProtocol {
    func fetchAll() throws -> [Pet]
    func fetch(by id: UUID) throws -> Pet?
    func create(_ pet: Pet) throws
    func update(_ pet: Pet) throws
    func delete(_ pet: Pet) throws
}

final class PetDataManager: PetDataManagerProtocol {
    static let shared = PetDataManager()

    private let coreDataStack: CoreDataStack

    private init() {
        self.coreDataStack = CoreDataStack.shared
    }

    func fetchAll() throws -> [Pet] {
        let context = coreDataStack.viewContext
        let request = PetEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]

        let entities = try context.fetch(request)
        return entities.compactMap { $0.toDomain() }
    }

    func fetch(by id: UUID) throws -> Pet? {
        let context = coreDataStack.viewContext
        let request = PetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        let entities = try context.fetch(request)
        return entities.first?.toDomain()
    }

    func create(_ pet: Pet) throws {
        let context = coreDataStack.viewContext
        let entity = PetEntity(context: context)
        entity.update(from: pet)

        try coreDataStack.saveContext()
    }

    func update(_ pet: Pet) throws {
        let context = coreDataStack.viewContext
        let request = PetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", pet.id as CVarArg)
        request.fetchLimit = 1

        guard let entity = try context.fetch(request).first else {
            throw PetWidgetError.invalidData
        }

        entity.update(from: pet)
        try coreDataStack.saveContext()
    }

    func delete(_ pet: Pet) throws {
        let context = coreDataStack.viewContext
        let request = PetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", pet.id as CVarArg)
        request.fetchLimit = 1

        guard let entity = try context.fetch(request).first else {
            throw PetWidgetError.invalidData
        }

        context.delete(entity)
        try coreDataStack.saveContext()
    }
}
```

### 2.2 SettingsManager

```swift
final class SettingsManager {
    static let shared = SettingsManager()

    private let defaults: UserDefaults?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // UserDefaults Keys
    private enum Keys {
        static let widgetSettings = "widgetSettings"
        static let selectedPetID = "selectedPetID"
    }

    private init() {
        self.defaults = UserDefaults(suiteName: AppConfig.appGroupID)
    }

    // ウィジェット設定の保存
    func saveWidgetSettings(_ settings: WidgetSettings) throws {
        let data = try encoder.encode(settings)
        defaults?.set(data, forKey: Keys.widgetSettings)
    }

    // ウィジェット設定の読み込み
    func loadWidgetSettings() throws -> WidgetSettings {
        guard let data = defaults?.data(forKey: Keys.widgetSettings) else {
            return .default
        }
        return try decoder.decode(WidgetSettings.self, from: data)
    }

    // 選択中のペットID
    var selectedPetID: UUID? {
        get {
            guard let uuidString = defaults?.string(forKey: Keys.selectedPetID) else {
                return nil
            }
            return UUID(uuidString: uuidString)
        }
        set {
            defaults?.set(newValue?.uuidString, forKey: Keys.selectedPetID)
        }
    }
}
```

---

## 3. ユーティリティAPI

### 3.1 AgeCalculator (年齢計算)

```swift
final class AgeCalculator {
    static func calculateAge(from birthDate: Date, to currentDate: Date = Date()) -> (years: Int, months: Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: birthDate, to: currentDate)
        return (components.year ?? 0, components.month ?? 0)
    }

    static func ageString(from birthDate: Date) -> String {
        let (years, months) = calculateAge(from: birthDate)

        if years == 0 {
            return "\(months)ヶ月"
        } else if months == 0 {
            return "\(years)歳"
        } else {
            return "\(years)歳\(months)ヶ月"
        }
    }
}
```

### 3.2 HumanAgeConverter (人間換算年齢)

```swift
final class HumanAgeConverter {
    static func convert(pet: Pet) -> Int {
        let realAge = Double(pet.ageInYears)

        switch pet.species {
        case .dog, .cat:
            // 最初の2年は1年=12歳、以降は1年=4歳で計算
            if realAge <= 2 {
                return Int(realAge * 12)
            } else {
                return Int(24 + (realAge - 2) * 4)
            }

        case .other:
            // その他は単純に5倍
            return Int(realAge * 5)
        }
    }

    static func humanAgeString(for pet: Pet) -> String {
        let humanAge = convert(pet: pet)
        return "人間年齢: \(humanAge)歳"
    }
}
```

### 3.3 PhotoManager (写真管理)

```swift
import UIKit
import Photos

final class PhotoManager {
    static let shared = PhotoManager()

    private init() {}

    // UIImageをリサイズしてData化
    func processImage(_ image: UIImage, maxSize: CGFloat = 800, compressionQuality: CGFloat = 0.8) -> Data? {
        let resizedImage = resizeImage(image, maxSize: maxSize)
        return resizedImage.jpegData(compressionQuality: compressionQuality)
    }

    // ウィジェット用にさらに小さくリサイズ
    func processImageForWidget(_ image: UIImage) -> Data? {
        return processImage(image, maxSize: 300, compressionQuality: 0.7)
    }

    // DataからUIImageに変換
    func loadImage(from data: Data) -> UIImage? {
        return UIImage(data: data)
    }

    // 画像リサイズ
    private func resizeImage(_ image: UIImage, maxSize: CGFloat) -> UIImage {
        let size = image.size
        let ratio = size.width / size.height

        var newSize: CGSize
        if size.width > size.height {
            newSize = CGSize(width: maxSize, height: maxSize / ratio)
        } else {
            newSize = CGSize(width: maxSize * ratio, height: maxSize)
        }

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
```

### 3.4 DateFormatter Extensions

```swift
extension DateFormatter {
    static let widgetDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日(E)"
        return formatter
    }()

    static let widgetTime24: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static let widgetTime12: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    static func formatDate(_ date: Date, format: DateFormatType) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = format.rawValue
        return formatter.string(from: date)
    }
}
```

---

## 4. Widget Timeline API

### 4.1 TimelineEntry

```swift
struct PetWidgetEntry: TimelineEntry {
    let date: Date
    let pet: Pet?
    let settings: WidgetSettings

    // プレビュー用
    static var placeholder: PetWidgetEntry {
        PetWidgetEntry(
            date: Date(),
            pet: Pet(
                name: "ポチ",
                birthDate: Calendar.current.date(byAdding: .year, value: -3, to: Date())!,
                species: .dog
            ),
            settings: .default
        )
    }
}
```

### 4.2 TimelineProvider

```swift
struct PetWidgetTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> PetWidgetEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (PetWidgetEntry) -> Void) {
        let entry = createEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PetWidgetEntry>) -> Void) {
        // 現在時刻から1時間分のエントリーを毎分作成
        var entries: [PetWidgetEntry] = []
        let currentDate = Date()

        for minuteOffset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = createEntry(for: entryDate)
            entries.append(entry)
        }

        // 次回更新は1時間後
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }

    private func createEntry(for date: Date = Date()) -> PetWidgetEntry {
        do {
            let settings = try SettingsManager.shared.loadWidgetSettings()
            var pet: Pet?

            if let selectedPetID = settings.selectedPetID {
                pet = try PetDataManager.shared.fetch(by: selectedPetID)
            } else {
                // 選択されていない場合は最初のペットを表示
                let allPets = try PetDataManager.shared.fetchAll()
                pet = allPets.first
            }

            return PetWidgetEntry(date: date, pet: pet, settings: settings)
        } catch {
            print("Failed to create entry: \(error)")
            return .placeholder
        }
    }
}
```

---

## 5. エラー定義

```swift
enum PetWidgetError: LocalizedError {
    case dataLoadFailed
    case dataSaveFailed
    case photoAccessDenied
    case photoSaveFailed
    case invalidData
    case coreDataError(Error)

    var errorDescription: String? {
        switch self {
        case .dataLoadFailed:
            return "データの読み込みに失敗しました"
        case .dataSaveFailed:
            return "データの保存に失敗しました"
        case .photoAccessDenied:
            return "写真へのアクセスが拒否されました"
        case .photoSaveFailed:
            return "写真の保存に失敗しました"
        case .invalidData:
            return "不正なデータです"
        case .coreDataError(let error):
            return "データベースエラー: \(error.localizedDescription)"
        }
    }
}
```

---

## 6. 設定値

```swift
enum AppConfig {
    static let appGroupID = "group.com.yourcompany.petwidget"
    static let widgetKind = "PetWidget"

    // 画像設定
    static let maxImageSize: CGFloat = 800
    static let widgetImageSize: CGFloat = 300
    static let imageCompressionQuality: CGFloat = 0.8

    // ウィジェット設定
    static let timelineUpdateInterval: TimeInterval = 3600 // 1時間
}
```
