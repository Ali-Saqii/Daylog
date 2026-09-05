//
//  JournalComposeView.swift
//  Daylog
//
//  Features/Journal/JournalComposeView.swift
//

import SwiftUI

struct JournalComposeView: View {
    @EnvironmentObject private var viewModel: JournalViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var textFieldFocused: Bool

    var isEditing: Bool { viewModel.editingEntry != nil }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.dlBackground.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 20) {
                    dateLine
                    moodPicker
                    textEditor
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        viewModel.resetDraft()
                        dismiss()
                    }
                    .foregroundStyle(Color.dlInkMuted)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        viewModel.saveEntry()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.dlCalm)
                    .disabled(viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear { textFieldFocused = true }
    }

    // MARK: - Date line

    private var dateLine: some View {
        Text(Date(), format: .dateTime.weekday(.wide).month(.wide).day().year())
            .font(AppFont.caption(13))
            .foregroundStyle(Color.dlInkMuted)
            .textCase(.uppercase)
    }

    // MARK: - Mood picker

    private var moodPicker: some View {
        HStack(spacing: 12) {
            Text("Mood")
                .font(AppFont.caption(13))
                .foregroundStyle(Color.dlInkMuted)
            ForEach(Mood.allCases, id: \.self) { mood in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        viewModel.draftMood = viewModel.draftMood == mood ? nil : mood
                    }
                } label: {
                    Text(mood.emoji)
                        .font(.system(size: 24))
                        .padding(6)
                        .background(
                            Circle()
                                .fill(viewModel.draftMood == mood
                                      ? Color.dlCalm.opacity(0.2)
                                      : Color.clear)
                        )
                        .overlay(
                            Circle()
                                .stroke(viewModel.draftMood == mood
                                        ? Color.dlCalm
                                        : Color.clear, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.15), value: viewModel.draftMood)
            }
        }
    }

    // MARK: - Text editor

    private var textEditor: some View {
        ZStack(alignment: .topLeading) {
            if viewModel.draftText.isEmpty {
                Text("What's on your mind?")
                    .font(AppFont.body(17))
                    .foregroundStyle(Color.dlInkMuted)
                    .padding(.top, 8)
                    .padding(.leading, 4)
            }
            TextEditor(text: $viewModel.draftText)
                .font(AppFont.body(17))
                .foregroundStyle(Color.dlInk)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .focused($textFieldFocused)
                .frame(minHeight: 200)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.dlSurface))
    }
}

#Preview {
    JournalComposeView()
        .environmentObject(JournalViewModel())
}
