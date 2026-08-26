//
//  AppFonts.swift
//  DayLog
//
//  Core/Theme/AppFonts.swift
//
//  Serif for headers (journal feel), system font for body/UI text.
//

import SwiftUI

enum AppFont {
    static func serifTitle(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .semibold, design: .serif)
    }

    static func serifHeadline(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .medium, design: .serif)
    }

    static func body(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }

    static func caption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
}
