//
//  AddEditHabitView.swift
//  Daylog
//
//  Created by Mac mini on 30/08/2026.
//


import SwiftUI

struct AddEditHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var habitViewModel: HabitViewModel
    let habit: Habit?
    @State private var title: String
    @State private var emoji: String
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(habit: Habit?) {
        self.habit = habit
        _title = State(initialValue: habit?.title ?? "")
        _emoji = State(initialValue: habit?.emoji ?? "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.dlBackground.ignoresSafeArea(.all)
                Form {
                    Section("Habit") {
                        TextField("Title", text: $title)
                        
                        HStack {
                            Text("Emoji")
                            Spacer()
                            TextField("Optional", text: $emoji)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        }
                    }
                    
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.title)
                            .foregroundStyle(.red)
                    }
                }.scrollContentBackground(.hidden)
                    .background(Color.dlBackground)
                    .navigationTitle(habit == nil ? "New Habit" : "Edit Habit")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { dismiss() }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button(isSaving ? "Saving…" : "Save") {
                                addAndUpdateHabit()
                            }
                            .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                        }
                    }
            }
        }
    }
    func addAndUpdateHabit() {
        if habit == nil {
            addHabit()
        }else if habit != nil {
            updateHabit()
        }
    }
    func updateHabit() {
        guard let habit = habit else {
            return
        }
        let newTitle = !title.isEmpty ? title : habit.title
        let newEmoji = !emoji.isEmpty ? emoji : habit.emoji
        Task {
            do{
                isSaving = true
                try await habitViewModel.updateHabit(habit.id, newTitle, newEmoji ?? "")
                isSaving = false
                dismiss()
            } catch let error{
                habitViewModel.errorMessage = error.localizedDescription
                isSaving = false

            }
        }
    }
    func addHabit() {
        Task {
            do{
                isSaving = true
                try await habitViewModel.addHabit(title: title, emoji: emoji)
                isSaving = false
                dismiss()
            } catch let error{
                habitViewModel.errorMessage = error.localizedDescription
                isSaving = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddEditHabitView(habit: nil)
            .environmentObject(HabitViewModel())
    }
}
