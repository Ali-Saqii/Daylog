//
//  HabitStreakBadge.swift
//  Daylog
//
//  Created by Mac mini on 30/08/2026.
//

import SwiftUI

struct HabitStreakBadge: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.caption)
            Text("\(streak)")
                .font(.dmSans(20, weight: .bold))
        }
        .foregroundStyle(streak > 0 ? Color.dlAccent : .secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(streak > 0 ? Color.dlAccent.opacity(0.12) : Color.dlDivider.opacity(0.3))
        )
    }
}

#Preview {
    HStack {
        HabitStreakBadge(streak: 0)
        HabitStreakBadge(streak: 7)
        HabitStreakBadge(streak: 42)
    }
    .padding()
}
