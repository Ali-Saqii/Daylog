//
//  EditProfileView.swift
//  Daylog
//
//  Created by Mac mini on 29/08/2026.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var profileVm : ProfileViewModel
    @State private var displayName = ""
    @State private var showLinkEmailAlert = false
    @State private var linkEmail = ""
    @State private var linkPassword = ""
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            Color.dlBackground.ignoresSafeArea()
            VStack {
                Section {
                    AuthTextField(placeholder: displayName.isEmpty ? "Enter Display name": displayName, text: $displayName)
                        .overlay(alignment: .trailing) {
                            Text(profileVm.user?.displayName == nil || (profileVm.user?.displayName?.isEmpty ?? true) ? "Add" : "Change")             .font(.dmSans(20, weight: .semiBold))
                                .foregroundStyle(Color.dlAccent)
                                .onTapGesture {
                                    profileVm.updateUserName(displayName: displayName)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {dismiss()})
                                }
                                .padding(.horizontal)
                        }
                } header: {
                    Text("Display Name")
                        .foregroundStyle(Color.dlInkMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                let isEmailLinked = profileVm.isProviderLinked(.email)
                let isFacebookLinked = profileVm.isProviderLinked(.faceBook)
                let isGoogleLinked = profileVm.isProviderLinked(.google)
                let hasUnlinkedProviders = !isEmailLinked || !isFacebookLinked || !isGoogleLinked

                if hasUnlinkedProviders {
                    Section {
                        List {
                            if !isEmailLinked {
                                RowView(image: "link", title: "Link email & Password", text: "")
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        linkEmail = ""
                                        linkPassword = ""
                                        showLinkEmailAlert = true
                                    }
                            }
                            if !isFacebookLinked {
                                RowView(image: "link", title: "Link facebook Account", text: "")
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        profileVm.linkFacebook()
                                    }
                            }
                            if !isGoogleLinked {
                                RowView(image: "link", title: "Link Google Account", text: "")
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        profileVm.linkGoogle()
                                    }
                            }
                        }.listStyle(.plain)
                            
                    } header: {
                        Text("Link Your Accounts")
                            .foregroundStyle(Color.dlInkMuted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
             Spacer()
            }.padding(.horizontal)
            if let errorMessage = profileVm.errorMessage {
                Text(errorMessage)
                    .font(.dmSans(20, weight: .regular))
                    .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .center)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {profileVm.errorMessage = nil})

                }
            }
        }.onAppear {
            getUserDisplayNme()
            getAuthProvider()
        }
        .navigationTitle("Edit your Profile")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Link Email & Password", isPresented: $showLinkEmailAlert) {
            TextField("Email", text: $linkEmail)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            SecureField("Password", text: $linkPassword)
            Button("Link") {
                profileVm.linkEmailAndPassword(email: linkEmail, password: linkPassword)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter the email and password you would like to link to your account.")
        }
    }
}

#Preview {
    NavigationStack {
        EditProfileView()
            .environmentObject(ProfileViewModel())
    }
}

extension EditProfileView {
    private func getUserDisplayNme() {
        guard let user = profileVm.user,
              let displayName = user.displayName else {
            return
        }
        self.displayName = displayName
    }
    
    private func getAuthProvider() {
        Task {
            do{
               try profileVm.getAuthProvider()
            }catch let error {
                profileVm.errorMessage = error.localizedDescription
            }
        }
    }
}
