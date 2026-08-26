//
//  SignUpView.swift
//  DayLog
//
//  Features/Authentication/Views/SignUpView.swift
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct SignUpView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var appState: AppState
    @Binding var currentView: AuthViews
    @Environment(\.dismiss) private var dismiss
    @State private var isSecureField = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                
                VStack(spacing: 12) {
                    AuthTextField(placeholder: "Display name", text: $viewModel.displayName)
                    AuthTextField(placeholder: "Email", text: $viewModel.email, keyboardType: .emailAddress)
                    AuthTextField(placeholder: "Password", text: $viewModel.password, isSecure: isSecureField)
                        .overlay(alignment: .trailing) {
                            Image(systemName: isSecureField ? "eye" : "eye.slash")
                                .foregroundStyle(.secondary)
                                .onTapGesture {
                                    isSecureField.toggle()
                                }
                                .padding(.trailing)
                        }
                }
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.dmSans(20, weight: .regular))
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {viewModel.errorMessage = nil})
                            
                        }
                }
                PrimaryAuthButton(action: {
                    SignUp()
                }, title: "SignUp", isDiable: false, height: 50, radius: 20)
                Divider()
                    .overlay {
                        Text("Or Continue with".capitalized)
                            .foregroundStyle(Color.dlInkMuted)
                            .padding(.horizontal)
                            .background(Color.dlBackground)
                        
                    }
                    .padding(.vertical)
                HStack{
                    GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: GoogleSignInButtonStyle.icon, state: .normal),action: {signInWithGoogle()})
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.dlAccent,lineWidth: 1.5)
                        )
                }.padding(.vertical)
                    .frame(maxWidth: .infinity, alignment: .center)
                HStack(spacing: 0) {
                    Text("I already have Account ")
                        .foregroundStyle(Color.dlInkMuted)
                    Button("Login!") {
                        currentView = .login
                    }.font(.headline)
                        .fontWeight(.bold)
                        .tint(Color.dlAccent)
                }.frame(maxWidth: .infinity, alignment: .center)
            } .padding(20)
                .padding(.top, 20)
        }.background(Color.dlBackground.ignoresSafeArea())
            .navigationTitle("Sign Up")
            .onDisappear {
                viewModel.errorMessage = nil
                viewModel.email = ""
                viewModel.password = ""
                viewModel.displayName = ""
            }
        
    }
    private func signInWithGoogle() {
        Task {
            do{
                try await viewModel.signInGoogle()
                appState.isLoggedIn = true
            }catch{
                viewModel.errorMessage = "Unable to SignIn With Google"
            }
        }
    }
    private func SignUp() {
        viewModel.createAccount(email: viewModel.email, password: viewModel.password, name: viewModel.displayName)
        appState.isLoggedIn = viewModel.SignUpsucessful
        
    }
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Create your account")
                .font(.body)
                .foregroundStyle(Color.dlInk)
            Text("Start tracking habits and journaling today.")
                .font(AppFont.body(14))
                .foregroundStyle(Color.dlInkMuted)
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView(currentView: .constant(.signUp))
            .environmentObject(AuthViewModel())
            .environmentObject(AppState())
    }
}
