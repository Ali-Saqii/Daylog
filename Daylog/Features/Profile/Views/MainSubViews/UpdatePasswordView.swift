//
//  UpdatePasswordView.swift
//  Daylog
//
//  Created by Mac mini on 20/08/2026.
//

import SwiftUI

struct UpdatePasswordView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @State private var password = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
                    ZStack{
                Color.dlBackground.ignoresSafeArea(.all)
                VStack(spacing:30) {
                    AuthTextField(placeholder: "Enter New Password", text: $password, keyboardType: .emailAddress)
                    PrimaryButton(title: "Update Password", action: {updatePassword()})
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
                }.padding()
            }.navigationTitle("Update Password")
                .navigationBarTitleDisplayMode(.inline)
        }
           
    
    private func updatePassword() {
        Task {
            do{
                try await profileVM.upDatePassword(password: password)
                dismiss()
            } catch {
                profileVM.errorMessage = AppError.format(error)
            }
        }
    }
}

#Preview {
    UpdatePasswordView()
        .environmentObject(ProfileViewModel())
}
