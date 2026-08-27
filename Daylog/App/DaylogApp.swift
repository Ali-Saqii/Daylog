//
//  DaylogApp.swift
//  Daylog
//
//  Created by Mac mini on 10/08/2026.
//

import SwiftUI
import CoreData
import FirebaseCore
import FirebaseAppCheck
import FacebookCore

@main

struct DaylogApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let persistenceController = PersistenceController.shared
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .onOpenURL { url in
                    ApplicationDelegate.shared.application(
                        UIApplication.shared,
                        open: url,
                        sourceApplication: nil,
                        annotation: nil
                    )
                }
        }
    }
}



