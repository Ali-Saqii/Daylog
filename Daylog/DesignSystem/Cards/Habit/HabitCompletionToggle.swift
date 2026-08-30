//
//  HabitCompletionToggle.swift
//  Daylog
//
//  Created by Mac mini on 30/08/2026.
//

import SwiftUI

struct HabitCompletionToggle: View {
    let isCompleted: Bool
    let action: () -> Void

    @State private var isPulsing = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isPulsing = true
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPulsing = false
                }
            }
        } label: {
            ZStack {
                Circle()
                    .strokeBorder(isCompleted ? Color.dlCalm : Color.dlDivider, lineWidth: 2)
                Circle()
                    .fill(isCompleted ? Color.dlCalm : Color.clear)
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 32, height: 32)
            .scaleEffect(isPulsing ? 1.2 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: 20) {
        HabitCompletionToggle(isCompleted: false) {}
        HabitCompletionToggle(isCompleted: true) {}
    }
    .padding()
}
