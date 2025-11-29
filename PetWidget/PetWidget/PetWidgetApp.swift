//
//  PetWidgetApp.swift
//  PetWidget
//
//  Created by なお on 2025/10/11.
//

import SwiftUI
import CoreData
import WidgetKit

@main
struct PetWidgetApp: App {
    // SharedモジュールのCoreDataStackを使用
    let coreDataStack = CoreDataStack.shared
    @State private var showSplash = true

    init() {
        // App Group接続確認とファイル保護解除
        removeFileProtectionForAppGroup()

        // CoreDataStackの初期化
        do {
            try coreDataStack.setup()
            print("✅ App: CoreDataStack setup initiated.")
        } catch {
            print("❌ App: Failed to setup CoreDataStack: \(error)")
        }

        // App Group接続確認（UserDefaults）
        if let userDefaults = UserDefaults(suiteName: AppConfig.appGroupID) {
            print("✅ App: Successfully accessed shared UserDefaults.")
            userDefaults.set("Hello from App!", forKey: "group.test.message")
        } else {
            print("❌ App: Failed to access shared UserDefaults. App Group configuration might be wrong.")
        }
    }
    
    private func removeFileProtectionForAppGroup() {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConfig.appGroupID) else {
            print("❌ App: Failed to get App Group container URL.")
            return
        }
        
        // データベースファイルの保護属性を強制的に解除（バックグラウンドアクセス用）
        let fileNames = ["PetWidget.sqlite", "PetWidget.sqlite-wal", "PetWidget.sqlite-shm"]
        for fileName in fileNames {
            let fileURL = containerURL.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try? FileManager.default.setAttributes([.protectionKey: FileProtectionType.none], ofItemAtPath: fileURL.path)
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if let error = coreDataStack.initializationError {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)

                        Text("CoreDataの初期化に失敗しました")
                            .font(.headline)

                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .padding()
                } else if let viewContext = try? coreDataStack.viewContext {
                    MainTabView()
                        .environment(\.managedObjectContext, viewContext)
                        .task {
                            // Core Dataの準備が整ってから移行処理を実行
                            PetDataManager.shared.migrateWidgetData()
                            
                            // ウィジェットの更新をリクエスト
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                } else {
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("読み込み中...")
                    }
                }

                if showSplash {
                    SplashScreenView(isPresented: $showSplash)
                }
            }
        }
    }
}
