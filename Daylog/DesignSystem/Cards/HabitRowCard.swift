//
//  HabitRowCard.swift
//  DayLog
//
//  DesignSystem/Cards/HabitRowCard.swift
//
//  Reusable habit row — used in TodayView (today's habits) and
//  HabitListView (full habit management list).
//

import SwiftUI

struct HabitRowCard: View {
    let habit: Habit
    let isCompletedToday: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Text(habit.emoji)
                    .font(.system(size: 20))

                Image(systemName: isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isCompletedToday ? Color.dlCalm : Color.dlInkMuted)

                Text(habit.title)
                    .font(AppFont.body())
                    .foregroundStyle(Color.dlInk)
                    .strikethrough(isCompletedToday, color: Color.dlInkMuted)

                Spacer()

                if habit.currentStreak > 0 {
                    HStack(spacing: 3) {
                        Text("\(habit.currentStreak)")
                            .font(AppFont.caption())
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                    }
                    .foregroundStyle(isCompletedToday ? Color.dlAccent : Color.dlInkMuted)
                } else {
                    Text("—")
                        .font(AppFont.caption())
                        .foregroundStyle(Color.dlInkMuted.opacity(0.5))
                }
            }
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 0) {
        HabitRowCard(
            habit: Habit(id: "1", title: "Drink water", emoji: "💧", createdAt: .now, currentStreak: 3, longestStreak: 5, isArchived: false),
            isCompletedToday: false,
            onToggle: {}
        )
        Divider()
        HabitRowCard(
            habit: Habit(id: "2", title: "Read 20 minutes", emoji: "📖", createdAt: .now, currentStreak: 7, longestStreak: 10, isArchived: false),
            isCompletedToday: true,
            onToggle: {}
        )
    }
    .padding(.horizontal, 16)
    .background(Color.dlSurface)
}
