//
//  AuthView.swift
//  Daylog
//
//  Created by Mac mini on 17/08/2026.
//

import SwiftUI

enum AuthViews {
    case login
    case signUp
}

struct AuthView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var AuthVM: AuthViewModel
    @State var currentView: AuthViews = .login
    
    var body: some View {
        VStack {
            switch currentView {
            case .login:
                LoginView(title: "login", currentView: $currentView)
                    .environmentObject(AuthVM)
                    .environmentObject(appState)
            case .signUp:
                SignUpView(currentView: $currentView)
                    .environmentObject(AuthVM)
                    .environmentObject(appState)
            }
        }
    }
}
#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppState())
}
