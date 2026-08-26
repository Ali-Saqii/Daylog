//
//  fontsExtension.swift
//  Bandmates
//
//  Created by Mac mini on 24/03/2026.
//

import Foundation
import SwiftUI

//
//extension Font {
//    static func dmSansBold(_ size: CGFloat) -> Font {
//        .custom("DMSans-Bold", size: size)
//    }
//    static func dmSansBlight(_ size: CGFloat) -> Font {
//        .custom("DMSans-Light", size: size)
//    }
//    static func dmSansBolMedium(_ size: CGFloat) -> Font {
//        .custom("DMSans-Medium", size: size)
//    }
//    static func dmSansregular(_ size: CGFloat) -> Font {
//        .custom("DMSans-Regular", size: size)
//    }
//    static func dmSansSemiBold(_ size: CGFloat) -> Font {
//        .custom("DMSans-SemiBold", size: size)
//    }
//
//}
extension Font {
    static func dmSans(_ size: CGFloat, weight: DMSansWeight = .regular) -> Font {
        .custom(weight.fontName, size: size)

    }

    enum DMSansWeight {
        case regular, medium, semiBold, bold, black

        var fontName: String {
            switch self {
            case .regular:    return "DMSans-Regular"
            case .medium:     return "DMSans-Medium"
            case .semiBold:   return "DMSans-SemiBold"
            case .bold:       return "DMSans-Bold"
            case .black:  return "DMSans-Black"
            }
        }
    }
}
