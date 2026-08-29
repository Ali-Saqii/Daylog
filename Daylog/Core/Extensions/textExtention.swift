//
//  textExtention.swift
//  Daylog
//
//  Created by Mac mini on 29/08/2026.
//


import Foundation
import SwiftUI
extension String {
    var initials: String? {
        let formatter = PersonNameComponentsFormatter()
        guard let components = formatter.personNameComponents(from: self) else {
            return nil
        }
        formatter.style = .abbreviated
        return formatter.string(from: components)
    }
}
