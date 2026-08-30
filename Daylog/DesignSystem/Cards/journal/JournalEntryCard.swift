//
//  JournalEntryCard.swift
//  DayLog
//
//  DesignSystem/Cards/JournalEntryCard.swift
//

import SwiftUI

struct JournalEntryCard: View {
    let entry: JournalEntry

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(DateFormat.monthDay(entry.createdAt))
                        .font(AppFont.caption())
                        .foregroundStyle(Color.dlInkMuted)

                    if let mood = entry.mood {
                        Text(mood.emoji)
                            .font(.system(size: 13))
                    }
                }

                Text(entry.text)
                    .font(AppFont.body())
                    .foregroundStyle(Color.dlInk)
                    .lineLimit(3)
            }

            Spacer()

            if entry.photoURL != nil {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.dlDivider)
                    .frame(width: 52, height: 52)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundStyle(Color.dlInkMuted)
                    )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.dlSurface)
        )
    }
}

/// Empty/prompt state shown on Today screen when no entry exists yet for the day.
struct JournalPromptCard: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text("Tap to write about your day…")
                    .font(AppFont.body())
                    .foregroundStyle(Color.dlInkMuted)
                Spacer()
                Image(systemName: "square.and.pencil")
                    .foregroundStyle(Color.dlCalm)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.dlSurface)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        JournalEntryCard(entry: JournalEntry(id: "1", dayKey: "2026-08-11", text: "Had a really productive day, finished the SwiftUI views for the app.", photoURL: "x", mood: .great, createdAt: .now))
        JournalPromptCard(onTap: {})
    }
    .padding()
    .background(Color.dlBackground)
}
