//
//  ReminderSettingsView.swift
//  Daylog
//
//  Features/Profile/Views/subViews/ReminderSettingsView.swift
//
//  Sheet that lets the user pick a daily reminder time.
//  Saves hour/minute to UserDefaults and schedules via
//  the existing local NotificationManager.
//

import SwiftUI

struct ReminderSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    /// Restore the previously saved time (default: 08:00).
    @State private var reminderTime: Date = {
        let cal = Calendar.current
        let hour   = UserDefaults.standard.object(forKey: "reminderHour") != nil
                     ? UserDefaults.standard.integer(forKey: "reminderHour")
                     : 8
        let minute = UserDefaults.standard.integer(forKey: "reminderMinute")
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        return cal.date(from: comps) ?? Date()
    }()

    @State private var errorMessage: String? = nil
    @State private var isSaving = false

    // Formatted string for subtitle
    private var savedTimeLabel: String {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let h = comps.hour ?? 8
        let m = comps.minute ?? 0
        let ampm = h < 12 ? "AM" : "PM"
        let hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h)
        return String(format: "%d:%02d %@", hour12, m, ampm)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.dlBackground.ignoresSafeArea()

                VStack(spacing: 28) {

                    // Header card
                    VStack(spacing: 6) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(Color.dlAccent)
                        Text("Every day at \(savedTimeLabel)")
                            .font(AppFont.body(15))
                            .foregroundStyle(Color.dlInkMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.dlSurface))

                    // Time picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pick a time")
                            .font(AppFont.caption(12))
                            .foregroundStyle(Color.dlInkMuted)
                            .textCase(.uppercase)

                        DatePicker(
                            "Reminder time",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.dlSurface))
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppFont.caption(13))
                            .foregroundStyle(Color.dlDanger)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }

                    PrimaryButton(title: isSaving ? "Saving…" : "Save Reminder", action: scheduleReminder)
                        .disabled(isSaving)

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Daily Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.dlInkMuted)
                }
            }
        }
    }

    // MARK: - Schedule

    private func scheduleReminder() {
        Task {
            isSaving = true
            defer { isSaving = false }
            do {
                let granted = try await NotificationManager.shared.requestAuthorization()
                guard granted else {
                    errorMessage = "Enable notifications in Settings to use reminders."
                    return
                }
                let comps  = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
                let hour   = comps.hour   ?? 8
                let minute = comps.minute ?? 0
                UserDefaults.standard.set(hour,   forKey: "reminderHour")
                UserDefaults.standard.set(minute, forKey: "reminderMinute")
                NotificationManager.shared.scheduleDailyReminder(at: hour, minute: minute)
                dismiss()
            } catch {
                errorMessage = "Could not request notification permission. Try again."
            }
        }
    }
}

#Preview {
    ReminderSettingsView()
}
