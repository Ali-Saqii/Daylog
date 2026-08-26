//
//  MainTabView.swift
//  Daylog
//
//  Created by Mac mini on 17/08/2026.
//
import SwiftUI

enum AppTab: Int, CaseIterable, Hashable {
    case today, habits, journal, profile

    var title: String {
        switch self {
        case .today: return "Today"
        case .habits: return "Habits"
        case .journal: return "Journal"
        case .profile: return "Profile"
        }
    }
}

struct MainTabView: View {
    @State private var selection: AppTab = .today
    @Namespace private var underlineAnimation
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack{
            Color.dlBackground.ignoresSafeArea(.all)
            VStack(spacing: 0) {
                tabSelector
                pagedContent
            }
        }
    }
    private var tabSelector: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 28) {
                    ForEach(AppTab.allCases, id: \.self) { tab in
                        tabLabel(for: tab)
                            .id(tab)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    selection = tab
                                }
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .onChange(of: selection) { _, newValue in
                withAnimation { proxy.scrollTo(newValue, anchor: .center) }
            }
        }
        .padding(.bottom, 10)
        .background(Color.dlBackground)
    }

    private func tabLabel(for tab: AppTab) -> some View {
        VStack(spacing: 6) {
            Text(tab.title)
                .font(.dmSans(selection == tab ? 20 : 15 , weight: .bold))
                .foregroundStyle(selection == tab ? Color.dlAccent : Color.dlInkMuted)

            ZStack {
                if selection == tab {
                    Capsule()
                        .fill(Color.dlAccent)
                        .frame(height: 3)
                        .matchedGeometryEffect(id: "underline", in: underlineAnimation)
                } else {
                    Capsule().fill(.clear).frame(height: 3)
                }
            }
        }
    }

    private var pagedContent: some View {
        TabView(selection: $selection) {
            TodayView()
                .tag(AppTab.today)
//
            HabitListView()
                .tag(AppTab.habits)
//
            JournalListView()
                .tag(AppTab.journal)

            ProfileView()
                .environmentObject(appState)
                .tag(AppTab.profile)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .indexViewStyle(.page(backgroundDisplayMode: .never))
        .animation(.easeInOut, value: selection)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
}
