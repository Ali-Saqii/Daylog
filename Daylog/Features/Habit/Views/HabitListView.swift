//
//  HabitListView.swift
//  Daylog
//
//  Created by Mac mini on 17/08/2026.
//

import SwiftUI

struct HabitListView: View {
    @StateObject private var viewModel = HabitViewModel()
    @State private var showingAddHabit = false

    private var activeHabits: [Habit] {
        viewModel.habits.filter { !$0.isArchived }
    }

    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    statsRow
                    habitsCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }.onAppear(perform: {
                viewModel.startListening()
            })
            .safeAreaInset(edge: .bottom, alignment: .listRowSeparatorTrailing, spacing: 60, content: {
                Button {
                    showingAddHabit = true
                } label: {
                    Circle()
                        .fill(Color.dlAccent)
                        .frame(width: 45, height: 45)
                        .overlay {
                            Image(systemName: "plus")
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }.padding(.trailing)
                }
            })
            .background(Color.dlBackground.ignoresSafeArea())
            .task {}
            .sheet(isPresented: $showingAddHabit) {
                AddEditHabitView(habit: nil)
                    .environmentObject(viewModel)
                .presentationDetents([.large])
            }
    }
    
    // MARK: - Stats
    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(value: "\(viewModel.completedTodayCount)", label: "Done Today")
            statCard(value: "\(viewModel.bestStreak)", label: "Best Streak", accent: true)
        }
    }
    
    private func statCard(value: String, label: String, accent: Bool = false) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppFont.serifHeadline(18))
                .foregroundStyle(accent ? Color.dlAccent : Color.dlInk)
            Text(label)
                .font(AppFont.caption(11))
                .foregroundStyle(Color.dlInkMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.dlSurface))
    }
    
    // MARK: - Habits list
    private var habitsCard: some View {
        VStack(spacing: 0) {
            if activeHabits.isEmpty {
                EmptyStateView(
                    icon: "list.bullet", title: "No habits yet",
                    message: "Tap + to add your first habit."
                )
                .padding(.vertical, 30)
            } else {
                ForEach(Array(activeHabits.enumerated()), id: \.element.id) { index, habit in
                    NavigationLink {
                        HabitDetailView(habit: habit, viewModel: viewModel)
                    } label: {
                        HabitRowCard(
                            habit: habit,
                            isCompletedToday: viewModel.isCompletedToday(habit),
                            onToggle: { viewModel.toggleCompletion(habit) }
                        )
                    }
                    .buttonStyle(.plain)
                    
                    if index < activeHabits.count - 1 {
                        Divider().background(Color.dlDivider).padding(.leading, 50)
                    }
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.dlSurface))
    }

}

#Preview {
    NavigationStack {
        HabitListView()
    }
}
