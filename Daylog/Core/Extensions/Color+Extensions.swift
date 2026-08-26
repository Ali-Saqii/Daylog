//
//  Color+Extensions.swift
//  DayLog
//
//  Core/Extensions/Color+Extensions.swift
//
//  Hex initializer + semantic color tokens for the app's warm,
//  paper-journal visual identity. Centralizing colors here means
//  no view ever hardcodes a hex value directly.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: ""))
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255

        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Semantic tokens
extension Color {
    // Backgrounds
    static let dlBackground = Color(light: "#FBF7F0", dark: "#1C1A17")
    static let dlSurface = Color(light: "#FFFFFF", dark: "#252220")

    // Text
    static let dlInk = Color(light: "#2B2620", dark: "#EDE7DD")
    static let dlInkMuted = Color(light: "#8A8074", dark: "#A79E90")

    // Accents
    static let dlAccent = Color(light: "#C1622D", dark: "#D97D46")   // habits / streaks / primary actions
    static let dlCalm = Color(light: "#5B7065", dark: "#7A9184")      // journal / completed states
    static let dlDanger = Color(light: "#B3432D", dark: "#D9634A")    // destructive actions

    // Structure
    static let dlDivider = Color(light: "#D8CFC0", dark: "#3A3631")
}

private extension Color {
    /// Convenience initializer that resolves to a different hex value depending on light/dark mode.
    init(light: String, dark: String) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(Color(hex: dark)) : UIColor(Color(hex: light))
        })
    }
}
