//
//  RootView.swift
//  Daylog
//
//  Created by Mac mini on 10/08/2026.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var authVm = AuthViewModel()
    @State private var showSplashScreen = true

    var body: some View {
        ZStack {
            if showSplashScreen {
                SplashScreenView(isActive: $showSplashScreen)
            } else {
                if appState.isLoggedIn {
                    NavigationStack {
                        MainTabView()
                            .environmentObject(appState)
                    }
                } else {
                    NavigationStack {
                        AuthView()
                            .environmentObject(authVm)
                            .environmentObject(appState)
                    }
                }
            }
        }
        .onAppear {
            // Brief splash before revealing the auth-driven UI.
            // AppState.isLoggedIn is already set by the Firebase auth listener
            // before this delay expires, so no manual check is needed.
            Task {
                try? await Task.sleep(for: .milliseconds(800))
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
