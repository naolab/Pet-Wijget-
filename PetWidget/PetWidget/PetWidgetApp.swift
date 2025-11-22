//
//  PetWidgetApp.swift
//  PetWidget
//
//  Created by なお on 2025/10/11.
//

import SwiftUI
import CoreData

@main
struct PetWidgetApp: App {
    // SharedモジュールのCoreDataStackを使用
    let coreDataStack = CoreDataStack.shared

    init() {
        // CoreDataStackの初期化
        do {
            try coreDataStack.setup()
            print("✅ App: CoreDataStack setup initiated.")
        } catch {
            print("❌ App: Failed to setup CoreDataStack: \(error)")
        }

        if let userDefaults = UserDefaults(suiteName: AppConfig.appGroupID) {
            userDefaults.set("Hello from App!", forKey: "group.test.message")
            print("✅ App: Wrote 'Hello from App!' to shared UserDefaults for key 'group.test.message'.")
        } else {
            print("❌ App: Failed to get shared UserDefaults.")
        }
    }

    var body: some Scene {
        WindowGroup {
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
            } else {
                VStack(spacing: 20) {
                    ProgressView()
                    Text("読み込み中...")
                }
            }
        }
    }
}
