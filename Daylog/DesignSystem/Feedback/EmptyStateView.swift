//
//  EmptyStateView.swift
//  DayLog
//
//  DesignSystem/Feedback/EmptyStateView.swift
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 34))
                .foregroundStyle(Color.dlInkMuted)

            Text(title)
                .font(AppFont.serifHeadline(18))
                .foregroundStyle(Color.dlInk)

            Text(message)
                .font(AppFont.body(14))
                .foregroundStyle(Color.dlInkMuted)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyStateView(icon: "book.closed", title: "No entries yet", message: "Your journal entries will show up here once you write your first one.")
        .background(Color.dlBackground)
}
