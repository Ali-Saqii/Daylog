//
//  RootView.swift
//  Daylog
//
//  Created by Mac mini on 10/08/2026.
//

import SwiftUI
import CoreData


struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject var AuthVm = AuthViewModel()
    @State var showSplashScreen = false
    var body: some View {
        ZStack {
            if !showSplashScreen {
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
            } else {
                SplashScreenView(isActive: $showSplashScreen)
            }
        }.onAppear {
            showSplashScreen = true
            Task {
                // Yield so SwiftUI renders the splash before the auth check runs
                try? await Task.sleep(for: .milliseconds(800))
                let authUser = try? AuthenticationManager.shared.getUser()
                appState.isLoggedIn = authUser != nil
                withAnimation(.easeInOut(duration: 0.3)) {
                    showSplashScreen = false
                }
            }
        }
    }
}
#Preview {
    RootView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppState())
}
