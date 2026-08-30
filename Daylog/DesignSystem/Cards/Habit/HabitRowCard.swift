//
//  HabitRowCard.swift
//  DayLog
//
//  Reads currentStreak directly off Habit — no separate streak lookup needed
//  since it's already stored on the model.
//

import SwiftUI

struct HabitRowCard: View {
    let habit: Habit
    let isCompletedToday: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(habit.emoji ?? "✨")
                .font(.system(size: 28))
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.dlAccent.opacity(0.1)))

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.dmSans(40, weight: .bold))
                    .foregroundStyle(Color.dlInk)
                if habit.longestStreak > 0 {
                    Text("Best: \(habit.longestStreak) days")
                        .font(.dmSans(40, weight: .bold))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            HabitStreakBadge(streak: habit.currentStreak)
            HabitCompletionToggle(isCompleted: isCompletedToday, action: onToggle)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.dlBackground)
                .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        )
    }
}


