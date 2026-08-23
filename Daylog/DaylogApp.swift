//
//  DaylogApp.swift
//  Daylog
//
//  Created by Mac mini on 23/08/2026.
//

import SwiftUI
import CoreData

@main
struct DaylogApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
