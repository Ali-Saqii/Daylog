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
    var body: some View {
        ZStack {
            Color.dlBackground.ignoresSafeArea()
            VStack {
                Section {
                    AuthTextField(placeholder: displayName.isEmpty ? "Enter Display name": displayName, text: $displayName)
                        .overlay(alignment: .trailing) {
                            Text("change")
                                .font(.dmSans(20, weight: .semiBold))
                                .foregroundStyle(Color.dlAccent)
                                .onTapGesture {
                                    profileVm.updateUserName(displayName: displayName)
                                }
                                .padding(.horizontal)
                        }
                } header: {
                    Text("Change Password")
                        .foregroundStyle(Color.dlInkMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Section {
                    List {
                      RowView(image: "link", title: "Link email & Password", text: "")
                            .onTapGesture {
                                
                            }
                        RowView(image: "link", title: "Link facebook Account", text: "")
                            .onTapGesture {
                                
                            }
                        RowView(image: "link", title: "Link Google Account", text: "")
                            .onTapGesture {
                                
                            }
                    }.listStyle(.plain)
                        
                } header: {
                    Text("Link Your Accounts")
                        .foregroundStyle(Color.dlInkMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
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
