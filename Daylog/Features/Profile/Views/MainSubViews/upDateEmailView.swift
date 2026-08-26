//
//  upDateEmailView.swift
//  Daylog
//
//  Created by Mac mini on 20/08/2026.
//

import SwiftUI

struct upDateEmailView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @State private var email = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack{
            Color.dlBackground.ignoresSafeArea(.all)
            VStack(spacing:30) {
                AuthTextField(placeholder: "Enter New Email", text: $email, keyboardType: .emailAddress)
                PrimaryButton(title: "Update Email", action: {updateEmail()})
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
        }.navigationTitle("Update Email")
            .navigationBarTitleDisplayMode(.inline)
           
    }
    private func updateEmail() {
        Task {
            do{
                try await profileVM.upDateEmail(email: email)
                dismiss()
            }catch {
                profileVM.errorMessage = "Un able to update password"
            }
        }
    }
}

#Preview {
    upDateEmailView()
        .environmentObject(ProfileViewModel())
}
