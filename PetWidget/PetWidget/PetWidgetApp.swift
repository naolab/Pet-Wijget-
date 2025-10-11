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
                PetListView()
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
