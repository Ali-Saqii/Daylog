//
// ProfileView.swift
// Daylog
//
// Created by Mac mini on 17/08/2026.
//
import SwiftUI
enum destination {
    case updatePassword
    case updateEmail
}
struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var profileVM = ProfileViewModel()
    @State var showAuthenticationView = false
    @State private var showUpdatePasswordView = false
    @State private var showUpdateEmailView = false
    @State private var selectedDestination: destination? = nil
    @State private var showAlert = false
    var body: some View {
        ZStack {
            Color.dlBackground.ignoresSafeArea(.all)
            VStack {
                
                ProfilePicView
                AccountSectionView
                
                if let errorMessage = profileVM.errorMessage {
                    Text(errorMessage)
                        .font(.dmSans(20, weight: .regular))
                        .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {profileVM.errorMessage = nil})

                    }
                }
            }
            
        }.onAppear(perform: {
            profileVM.getUser()
        })
        .navigationDestination(isPresented: $showUpdatePasswordView) {
            UpdatePasswordView()
                .environmentObject(profileVM)
        }
        .navigationDestination(isPresented: $showUpdateEmailView) {
            upDateEmailView()
                .environmentObject(profileVM)
        }
        .fullScreenCover(isPresented: $showAuthenticationView) {
            ReAuthenticationView(showAuthenticate: $showAuthenticationView, showUpdatePasswordView: $showUpdatePasswordView, showUpdateEmailView: $showUpdateEmailView, selectedDestination: $selectedDestination)
                .environmentObject(profileVM)
        }
    }
    func logOut() {
        profileVM.signOut()
        appState.isLoggedIn = !profileVM.isSingOut
    }
}
extension ProfileView {
    
    private var ProfilePicView: some View {
        VStack {
            if let user = profileVM.user,
               let photoUrl = user.photoUrl,
               let email = user.email,let displayName = user.displayName,
               let date = user.createdAt{
                HStack {
                    AsyncImage(url: URL(string:photoUrl), scale: 100) { phase in
                        switch phase {
                        case (let img):
                            img
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .clipped()
                        }
                    } placeholder: {
                        Text(displayName.initials ?? "")
                            .font(.dmSans(40, weight: .black))
                            .foregroundStyle(.orange)
                            .frame(width: 100, height: 100)
                            .background(
                                Circle()
                                    .fill(.orange.opacity(0.3))
                            )
                    }
                    .overlay {
                        Circle()
                            .stroke(.orange,lineWidth: 2)
                            .overlay(alignment: .bottomTrailing) {
                                Circle()
                                    .fill(.orange)
                                    .frame(width: 25, height: 25)
                                    .overlay {
                                        Text("+")
                                            .font(.dmSans(25, weight: .black))
                                            .foregroundStyle(.white)
                                        
                                    }
                            }
                            .onTapGesture {
                                print("Hii")
                            }
                    }
                    Spacer()
                    VStack(alignment:.leading) {
                        Text (displayName.capitalized)
                            .font(.dmSans(28, weight: .medium))
                        Text (email)
                            .font(.dmSans(20.5, weight: .black))
                            .tint(.black.opacity(0.7))
                        Text ("member since \((date).dayKey)".capitalized)
                            .font(.headline)
                            .foregroundStyle(.black.opacity(0.7))
                    }
                    Spacer()
                }
            }
            HStack(spacing:18) {
                    GridView(num: 3, title: "Habits")
                    GridView(num: 12, title: "Best Streak")
                    GridView(num: 8, title: "Entries")
            }
            }.padding(.horizontal)
    }
    private var AccountSectionView: some View {
        VStack(spacing: 0){
            List() {
                Section {
                    NavigationLink {
                        EditProfileView()
                            .environmentObject(profileVM)
                    } label: {
                        RowView(image: "person", title: "Edit profile", text: "")
                    }
                    if let provider = profileVM.authProvider,provider.contains(.email) {
                        RowView(image: "lock", title: "Change password", text: "")
                            .onTapGesture {
                                withAnimation{
                                    selectedDestination = .updatePassword
                                    showAuthenticationView.toggle()
                                }
                            }
                        RowView(image: "envelope", title: "Change email", text: "")
                            .onTapGesture {
                                withAnimation{
                                    selectedDestination = .updateEmail
                                    showAuthenticationView.toggle()
                                }
                            }
                    }
                } header: {
                    Text("Account".capitalized)
                }
                
                
                Section {
                    RowView(image: "bell", title: "Daily Reminder", text: "on")
                    RowView(image: "moon", title: "Appearance", text: "system")
                    
                } header: {
                    Text("Preferences".capitalized)
                }
                Section {
                    Text("logOut")
                        .font(.dmSans(20, weight: .regular))
                        .foregroundStyle(.green)
                        .onTapGesture {
                          logOut()
                        }

                    Text("Delete Account")
                        .font(.dmSans(20, weight: .regular))
                        .foregroundStyle(.red)
                        .onTapGesture {
                            withAnimation {
                                showAuthenticationView.toggle()
                            }
                            
                        }
                }header: {
                    Text("".capitalized)
                }
                
            }.scrollContentBackground(.hidden)
                .background(Color(red: 0.98, green: 0.96, blue: 0.93))
                .listStyle(.insetGrouped)
                .scrollDisabled(true)
                .listSectionSpacing(0)
            
        }
    }
 
}

#Preview {
        ProfileView()
            .environmentObject(AppState())
}
