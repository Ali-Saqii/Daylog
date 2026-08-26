//
//  ResetLinkView.swift
//  Daylog
//
//  Created by Mac mini on 19/08/2026.
//

import SwiftUI

struct ResetLinkView: View {
    @EnvironmentObject var AuthVm : AuthViewModel
    @Binding var showResetLinkView : Bool
    var body: some View {
        ZStack {
            Color.dlBackground.ignoresSafeArea(.all)
            VStack(spacing: 30) {
                VStack {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.dlSurface)
                        .padding()
                        .background(
                            Circle()
                                .fill(Color.dlAccent)
                                .onTapGesture {
                                    withAnimation() {
                                        showResetLinkView.toggle()
                                    }
                                }
                        )
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    Text("Reset Password")
                        .font(.dmSans(30, weight: .black))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Reset Password link send to give email")
                        .font(.dmSans(18, weight: .regular))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                AuthTextField(placeholder: "Email", text: $AuthVm.email, keyboardType: .emailAddress)
                
                PrimaryButton(title: "ResetLink") {
                    AuthVm.resetPassword(email: AuthVm.email)
                 
                }
                if let errorMessage = AuthVm.errorMessage {
                    Text(errorMessage)
                        .font(.dmSans(15, weight: .regular))
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onAppear(perform: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {AuthVm.errorMessage = nil})
                        })
                }
                Spacer()
            }.padding()
        }.onDisappear {
            AuthVm.errorMessage = nil
        }
    }
}

#Preview {
    ResetLinkView(showResetLinkView: .constant(true))
        .environmentObject(AuthViewModel())
}
