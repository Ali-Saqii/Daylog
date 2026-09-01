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
    let onSave: (Habit) -> Void

    @State private var title: String
    @State private var emoji: String
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(habit: Habit?, onSave: @escaping (Habit) -> Void) {
        self.habit = habit
        self.onSave = onSave
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
                               addHabit()
                            }
                            .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                        }
                    }
            }
        }
    }

private func addHabit() {
    Task {
        do{
            isSaving = true
            try await habitViewModel.addHabit(title: title, emoji: emoji)
            isSaving = false
            dismiss()
        }catch let error {
            isSaving = false
            self.errorMessage = error.localizedDescription
        }
    }

}
}

#Preview {
    NavigationStack {
        AddEditHabitView(habit: nil) { _ in }
            .environmentObject(HabitViewModel())
    }
}
