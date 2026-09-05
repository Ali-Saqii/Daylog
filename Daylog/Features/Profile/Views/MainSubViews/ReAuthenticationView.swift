//
//  ReAuthenticationView.swift
//  Daylog
//
//  Created by Mac mini on 20/08/2026.
//

import SwiftUI

struct ReAuthenticationView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @State private var isSecureField = false
    @State private var email = ""
    @State private var password = ""
    @Binding var showAuthenticate : Bool
    @Environment(\.dismiss) var dismiss
    @Binding var showUpdatePasswordView : Bool
    @Binding var showUpdateEmailView : Bool
    @Binding var selectedDestination : destination?
    var body: some View {
        NavigationStack {
            ZStack {
                Color.dlBackground.ignoresSafeArea(.all)
                VStack(spacing: 25) {
                    Text("user Authentication".capitalized)
                        .font(.dmSans(25, weight: .bold))
                        .foregroundStyle(Color.dlAccent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    AuthTextField(placeholder: "Email", text: $email, keyboardType: .emailAddress)
                    AuthTextField(placeholder: "Password", text: $password, isSecure: isSecureField)
                        .overlay(alignment: .trailing) {
                            Image(systemName: isSecureField ? "eye" : "eye.slash")
                                .foregroundStyle(isSecureField ?Color.dlInkMuted : Color.dlAccent)
                                .font(isSecureField ? .headline : .title3)
                                .onTapGesture {
                                    isSecureField.toggle()
                                }
                                .padding(.trailing)
                        }
                    PrimaryButton(title: "Authenticate", action: {authenticate()})
                        .padding()
                    if let errorMessage = profileVM.errorMessage {
                        Text(errorMessage)
                            .font(.dmSans(15, weight: .regular))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {profileVM.errorMessage = nil})
                                
                            }
                    }
                    Spacer()
                }.padding(.horizontal)
            }
        }
    }
    private func authenticate() {
        guard let destination = selectedDestination else {
            print("error while selection destination")
            return
        }
        Task {
            do{
                try await profileVM.reAuthenticateUser(email: email, password: password)
                switch destination {
                case .updateEmail:
                    showUpdateEmailView = true
                case .updatePassword:
                    showUpdatePasswordView = true
                }
        
                dismiss()
            } catch {
                profileVM.errorMessage = AppError.format(error)
            }
        }
    }
}

#Preview {
    ReAuthenticationView(showAuthenticate: .constant(true), showUpdatePasswordView: .constant(false), showUpdateEmailView: .constant(false), selectedDestination: .constant(.updatePassword))
        .environmentObject(ProfileViewModel())
}
