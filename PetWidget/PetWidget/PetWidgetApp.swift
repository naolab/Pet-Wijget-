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
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
