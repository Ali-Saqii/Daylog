//
//  TodayView.swift
//  Daylog
//
//  Created by Mac mini on 17/08/2026.
//

import SwiftUI

struct TodayView: View {
    @StateObject private var viewModel = HabitViewModel()

    private var activeHabits: [Habit] {
        viewModel.habits.filter { !$0.isArchived }
    }

    var body: some View {
        ZStack {
            Color.dlBackground.ignoresSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    progressSection
                    habitsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .onAppear { viewModel.startListening() }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date(), format: .dateTime.weekday(.wide).month(.wide).day())
                .font(AppFont.caption(13))
                .foregroundStyle(Color.dlInkMuted)
                .textCase(.uppercase)
            Text("Today")
                .font(AppFont.serifTitle(28))
                .foregroundStyle(Color.dlInk)
        }
    }

    // MARK: - Progress ring

    private var progressSection: some View {
        let total = activeHabits.count
        let done  = viewModel.completedTodayCount
        let progress: Double = total > 0 ? Double(done) / Double(total) : 0

        return HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.dlDivider, lineWidth: 8)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.dlAccent, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.4), value: progress)
                VStack(spacing: 2) {
                    Text("\(done)")
                        .font(AppFont.serifHeadline(22))
                        .foregroundStyle(Color.dlAccent)
                    Text("/ \(total)")
                        .font(AppFont.caption(11))
                        .foregroundStyle(Color.dlInkMuted)
                }
            }
            .frame(width: 80, height: 80)

            VStack(alignment: .leading, spacing: 6) {
                Text(done == total && total > 0 ? "All done! 🎉" : "\(total - done) left for today")
                    .font(AppFont.serifHeadline(18))
                    .foregroundStyle(Color.dlInk)
                Text("Keep your streak alive")
                    .font(AppFont.caption(13))
                    .foregroundStyle(Color.dlInkMuted)
            }
            Spacer()
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.dlSurface))
    }

    // MARK: - Habits list

    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Habits")
                .font(AppFont.caption(13))
                .foregroundStyle(Color.dlInkMuted)
                .textCase(.uppercase)

            if activeHabits.isEmpty {
                EmptyStateView(
                    icon: "checkmark.seal",
                    title: "No habits yet",
                    message: "Add habits from the Habits tab."
                )
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(activeHabits.enumerated()), id: \.element.id) { index, habit in
                        TodayHabitRow(
                            habit: habit,
                            isCompleted: viewModel.isCompletedToday(habit),
                            onToggle: { viewModel.toggleCompletion(habit) }
                        )
                        if index < activeHabits.count - 1 {
                            Divider()
                                .background(Color.dlDivider)
                                .padding(.leading, 52)
                        }
                    }
                }
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.dlSurface))
            }
        }
    }
}

// MARK: - Today Habit Row

private struct TodayHabitRow: View {
    let habit: Habit
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .stroke(isCompleted ? Color.dlCalm : Color.dlDivider, lineWidth: 2)
                        .frame(width: 28, height: 28)
                    if isCompleted {
                        Circle()
                            .fill(Color.dlCalm)
                            .frame(width: 28, height: 28)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .animation(.easeInOut(duration: 0.2), value: isCompleted)

            Text("\(habit.emoji ?? "") \(habit.title)")
                .font(AppFont.body(16))
                .foregroundStyle(isCompleted ? Color.dlInkMuted : Color.dlInk)
                .strikethrough(isCompleted, color: Color.dlInkMuted)
                .animation(.easeInOut(duration: 0.2), value: isCompleted)

            Spacer()

            if habit.currentStreak > 0 {
                HabitStreakBadge(streak: habit.currentStreak)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    TodayView()
}
