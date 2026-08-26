//
//  ContentView.swift
//  Daylog
//
//  Created by Mac mini on 10/08/2026.
//

import SwiftUI
import CoreData


struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject var AuthVm = AuthViewModel()
    var body: some View {
        ZStack {
            if appState.isLoggedIn {
                NavigationStack {
                    MainTabView()
                        .environmentObject(appState)
                }
            } else {
                NavigationStack {
                    AuthView()
                        .environmentObject(AuthVm)
                        .environmentObject(appState)
                }
            }
        }.onAppear {
            let authUser = try? AuthenticationManager.shared.getUser()
            appState.isLoggedIn = authUser != nil ? true : false
        }
    }
}
#Preview {
    RootView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppState())
}
