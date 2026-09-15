//
//  DisplayNameNormalization.swift
//  Daylog
//

import Foundation

enum DisplayNameNormalization {
    /// Blank or whitespace-only names are stored as nil so profile UI can treat them as missing.
    static func normalized(_ raw: String?) -> String? {
        let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }
}
