//
//  DaylogApp.swift
//  Daylog
//
//  Created by Mac mini on 10/08/2026.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck
import FacebookCore

@main

struct DaylogApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(.light)
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



