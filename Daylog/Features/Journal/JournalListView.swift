//
//  JournalListView.swift
//  Daylog
//
//  Created by Mac mini on 17/08/2026.
//

import SwiftUI

struct JournalListView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingCompose = false

    var body: some View {
        ZStack {
            Color.dlBackground.ignoresSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    entryList
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .onAppear { viewModel.startListening() }
        .safeAreaInset(edge: .bottom, alignment: .trailing, spacing: 60) {
            Button {
                viewModel.resetDraft()
                showingCompose = true
            } label: {
                Circle()
                    .fill(Color.dlAccent)
                    .frame(width: 45, height: 45)
                    .overlay {
                        Image(systemName: "pencil")
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
            }.padding(.trailing)
        }
        .sheet(isPresented: $showingCompose) {
            JournalComposeView()
                .environmentObject(viewModel)
                .presentationDetents([.large])
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Journal")
                .font(AppFont.serifTitle(28))
                .foregroundStyle(Color.dlInk)
            Text("\(viewModel.entries.count) entries")
                .font(AppFont.caption(13))
                .foregroundStyle(Color.dlInkMuted)
        }
    }

    // MARK: - Entry List

    private var entryList: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                ProgressView()
                    .padding(.vertical, 40)
                    .frame(maxWidth: .infinity)
            } else if viewModel.entries.isEmpty {
                EmptyStateView(
                    icon: "book.closed",
                    title: "No entries yet",
                    message: "Tap the pencil to write your first entry."
                )
                .padding(.vertical, 30)
            } else {
                ForEach(Array(viewModel.entries.enumerated()), id: \.element.id) { index, entry in
                    JournalRowView(entry: entry) {
                        viewModel.beginEditing(entry)
                        showingCompose = true
                    } onDelete: {
                        viewModel.deleteEntry(entry)
                    }
                    if index < viewModel.entries.count - 1 {
                        Divider().background(Color.dlDivider).padding(.leading, 20)
                    }
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.dlSurface))
    }
}

// MARK: - Journal Row

private struct JournalRowView: View {
    let entry: JournalEntry
    let onEdit: () -> Void
    let onDelete: () -> Void
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(formattedDate)
                        .font(AppFont.caption(12))
                        .foregroundStyle(Color.dlInkMuted)
                        .textCase(.uppercase)
                    if let mood = entry.mood {
                        Text(mood.emoji)
                            .font(.system(size: 18))
                    }
                }
                Spacer()
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundStyle(Color.dlInkMuted)
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
            }

            Text(entry.text)
                .font(AppFont.body(15))
                .foregroundStyle(Color.dlInk)
                .lineLimit(3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: entry.dayKey) {
            return DateFormat.weekdayMonthDay(date)
        }
        return entry.dayKey
    }
}

#Preview {
    JournalListView()
}
