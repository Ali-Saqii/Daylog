//
//  HabitDetailView.swift
//  Daylog
//
//  Created by Mac mini on 30/08/2026.
//
//

import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                streakStats
                toggleTodayButton
                deleteButton
            }
            .padding(20)
        }
        .background(Color.dlBackground.ignoresSafeArea())
        .navigationTitle("Habit")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(habit.title) \(habit.emoji ?? "")")
                .font(AppFont.serifTitle(24))
                .foregroundStyle(Color.dlInk)
            Text("Started \(DateFormat.monthDay(habit.createdAt))")
                .font(AppFont.body(13))
                .foregroundStyle(Color.dlInkMuted)
        }
    }

    private var streakStats: some View {
        HStack(spacing: 12) {
            statCard(value: "\(habit.currentStreak)", label: "current streak")
            statCard(value: "\(habit.longestStreak)", label: "longest streak", accent: true)
        }
    }

    private func statCard(value: String, label: String, accent: Bool = false) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(AppFont.serifTitle(28))
                .foregroundStyle(accent ? Color.dlAccent : Color.dlInk)
            Text(label)
                .font(AppFont.caption())
                .foregroundStyle(Color.dlInkMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.dlSurface))
    }

    private var toggleTodayButton: some View {
        let isDone = viewModel.isCompletedToday(habit)
        return PrimaryButton(title: isDone ? "Mark as not done today" : "Mark as done today") {
            viewModel.toggleCompletion(habit)
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showingDeleteConfirmation = true
        } label: {
            Text("Delete Habit")
                .font(AppFont.body(16))
                .fontWeight(.semibold)
                .foregroundStyle(Color.dlDanger)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(RoundedRectangle(cornerRadius: 14).stroke(Color.dlDanger, lineWidth: 1))
        }
        .confirmationDialog(
            "Delete this habit?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                viewModel.deleteHabit(habit)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
