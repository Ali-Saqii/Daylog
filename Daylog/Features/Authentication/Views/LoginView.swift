//
//  LoginView.swift
//  DayLog
//
//  Features/Authentication/Views/LoginView.swift
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import FacebookLogin

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var appState: AppState
    let title: String
    @Binding var currentView: AuthViews
    @State private var isSecureField = true
    @State private var showResetLinkView = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                VStack(spacing: 12) {
                    AuthTextField(placeholder: "Email", text: $viewModel.email, keyboardType: .emailAddress)
                    AuthTextField(placeholder: "Password", text: $viewModel.password, isSecure: isSecureField)
                        .overlay(alignment: .trailing) {
                            Image(systemName: isSecureField ? "eye" : "eye.slash")
                                .foregroundStyle(isSecureField ?Color.dlInkMuted : Color.dlAccent)
                                .font(isSecureField ? .headline : .title3)
                                .onTapGesture {
                                    isSecureField.toggle()
                                }
                                .padding(.trailing)
                        }
                }
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.dmSans(15, weight: .regular))
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {viewModel.errorMessage = nil})
                            
                        }
                }
                Text("forget Password".capitalized)
                    .font(.dmSans(showResetLinkView ? 20 :15, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundStyle(showResetLinkView ?Color.dlAccent :Color.dlInkMuted)
                    .onTapGesture {
                        withAnimation() {
                            showResetLinkView.toggle()
                        }
                    }
                PrimaryAuthButton(action: {
                    logIn()
                }, title: "logIn", isDiable: false, height: 50, radius: 20)
            } .padding(20)
                .padding(.top, 40)
            Divider()
                .overlay {
                    Text("Or Continue with".capitalized)
                        .foregroundStyle(Color.dlInkMuted)
                        .padding(.horizontal)
                        .background(Color.dlBackground)
                    
                }
                .padding(.vertical)
            HStack{
                Spacer()
                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: GoogleSignInButtonStyle.icon, state: .normal),action: {signInWithGoogle()})
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.dlAccent,lineWidth: 1.5)
                    )
                Spacer()
                Button {
                    Task {
                        await viewModel.signInFacebook()
                    }
                } label: {
                    Image("facebook")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.dlAccent, lineWidth: 1.5)
                        )
                }

                Spacer()
            }.padding(.vertical)
            HStack {
                Text("Don't have an account?")
                    .foregroundStyle(Color.dlInkMuted)
                Button("SignUp!") {
                    currentView = .signUp
                }
                .fontWeight(.bold)
                .foregroundStyle(Color.dlAccent)
            }
            .font(AppFont.body(14))
            .frame(maxWidth: .infinity, alignment: .center)
        }.background(Color.dlBackground.ignoresSafeArea())
            .navigationTitle(title)
            .onDisappear {
                viewModel.errorMessage = nil
                viewModel.email = ""
                viewModel.password = ""
                viewModel.displayName = ""
            }
            .sheet(isPresented: $showResetLinkView) {
                ResetLinkView(showResetLinkView: $showResetLinkView)
                    .environmentObject(viewModel)
                    .presentationDetents([.medium])
                
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
    private func logIn() {
        viewModel.SignIn(email: viewModel.email, password: viewModel.password)
        appState.isLoggedIn = viewModel.logInsucessful
    }
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome back")
                .font(AppFont.serifTitle(26))
                .foregroundStyle(Color.dlInk)
            Text("Log in to keep your streaks going.")
                .font(AppFont.body(14))
                .foregroundStyle(Color.dlInkMuted)
        }
        
        
    }
}



#Preview {
    NavigationStack {
        LoginView(title: "login", currentView: .constant(.login))
            .environmentObject(AuthViewModel())
            .environmentObject(AppState())
    }
}
