//
//  AuthTextField.swift
//  DayLog
//
//  DesignSystem/Inputs/AuthTextField.swift
//

//
//  AuthTextField.swift
//  DayLog
//
//  DesignSystem/Inputs/AuthTextField.swift
//

import SwiftUI

struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
        }
        .font(AppFont.body())
        .foregroundStyle(Color.dlInk)
        .padding(.horizontal, 16)
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.dlSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.dlDivider, lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        AuthTextField(placeholder: "Email", text: .constant(""))
        AuthTextField(placeholder: "Password", text: .constant(""), isSecure: true)
    }
    .padding()
    .background(Color.dlBackground)
}
