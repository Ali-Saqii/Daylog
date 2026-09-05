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
            // Emoji circle
            Text(habit.emoji ?? "✨")
                .font(.system(size: 20))
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.dlAccent.opacity(0.1)))

            // Title + streak badge
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.title)
                    .font(.dmSans(16, weight: .semiBold))
                    .foregroundStyle(isCompletedToday ? Color.dlInkMuted : Color.dlInk)
                    .strikethrough(isCompletedToday, color: Color.dlInkMuted)
                if habit.currentStreak > 0 {
                    HabitStreakBadge(streak: habit.currentStreak)
                }
            }

            Spacer()

            // Completion toggle on the right
            HabitCompletionToggle(isCompleted: isCompletedToday, action: onToggle)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}


