//
//  HabitListView.swift
//  Daylog
//
//  Created by Mac mini on 17/08/2026.
//

//
//  HabitListView.swift
//  DayLog
//
//  ASSUMES an existing HabitListViewModel with:
//    @Published var habits: [Habit]
//    @Published var completedHabitIds: Set<String>
//    @Published var isLoading: Bool
//    func loadHabits() async
//    func toggleCompletion(for habit: Habit) async
//    func deleteHabit(_ habit: Habit) async
//  Adjust the call sites below if your actual ViewModel's API differs —
//  this file intentionally has no ViewModel logic of its own.
//
//  ASSUMPTION: EmptyStateView is (title:message:actionTitle:action:) — adjust
//  the call if yours differs.
//

import SwiftUI

struct HabitListView: View {
    @StateObject  private var viewModel = HabitViewModel()
    @State private var showingAddHabit = false
    @State private var selectedHabit: Habit?
    
    var body: some View {
        ZStack {
            Color.dlBackground.ignoresSafeArea()
        }
    }
}
#Preview {
    HabitListView()
}
