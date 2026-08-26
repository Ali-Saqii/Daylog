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


@main

struct DaylogApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let persistenceController = PersistenceController.shared
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
                RootView()
                    .environmentObject(appState)
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
#if DEBUG
    let providerFactory = AppCheckDebugProviderFactory()
    AppCheck.setAppCheckProviderFactory(providerFactory)
    #endif
    FirebaseApp.configure()
      print("configured firebase")
    return true
  }
}
