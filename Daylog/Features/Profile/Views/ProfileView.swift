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
            
        }.onAppear {
            profileVM.getUser()
            profileVM.loadStats()
        }
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
            if let user = profileVM.user{
                HStack {
                    if let photoUrl = user.photoUrl {
                        AsyncImage(url: URL(string: photoUrl)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .clipped()
                            case .failure:
                                DylogPlaceholderView()
                            case .empty:
                                DylogPlaceholderView()
                            @unknown default:
                                DylogPlaceholderView()
                                
                            }
                        }
                        .overlay {
                          overlayCntentView()
                                .onTapGesture {
                                    
                                }
                        }
                       
                    }else {
                        DylogPlaceholderView()
                            .overlay {
                              overlayCntentView()
                                    .onTapGesture {
                                        
                                    }
                            }

                    }
                    Spacer()
                    VStack(alignment:.leading) {
                        if let displayName = user.displayName {
                            Text (displayName.capitalized)
                                .font(.dmSans(28, weight: .medium))
                        }
                        if let email = user.email {
                            Text(email)
                                .font(.dmSans(20.5, weight: .black))
                                .tint(.black.opacity(0.7))
                                .lineLimit(1)
                        }
                        if  let date = user.createdAt {
                            Text ("member since \((date).dayKey)".capitalized)
                                .font(.headline)
                                .foregroundStyle(.black.opacity(0.7))
                        }
                    }
                    Spacer()
                }
            }
            if profileVM.isLoadingStats {
                HStack(spacing: 18) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.dlSurface)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .redacted(reason: .placeholder)
                    }
                }
            } else {
                HStack(spacing: 18) {
                    GridView(num: profileVM.stats.habitCount, title: "Habits")
                    GridView(num: profileVM.stats.bestStreak, title: "Best Streak")
                    GridView(num: profileVM.stats.journalEntries, title: "Entries")
                }
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
//                    RowView(image: "moon", title: "Appearance", text: "system")
                    
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
