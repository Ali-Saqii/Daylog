//
//  PrimaryButton.swift
//  DayLog
//
//  DesignSystem/Buttons/PrimaryButton.swift
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(AppFont.body(16))
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isDisabled ? Color.dlInkMuted.opacity(0.4) : Color.dlAccent)
            )
        }
        .disabled(isDisabled || isLoading)
    }
}

#Preview {
    VStack(spacing: 12) {
        PrimaryButton(title: "Continue") {}
        PrimaryButton(title: "Loading", isLoading: true) {}
        PrimaryButton(title: "Disabled", isDisabled: true) {}
    }
    .padding()
    .background(Color.dlBackground)
}
