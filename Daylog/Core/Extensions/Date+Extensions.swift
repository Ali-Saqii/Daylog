//
//  Date+Extensions.swift
//  DayLog
//
//  Core/Extensions/Date+Extensions.swift
//
//  All date formatting lives here so views and view models never
//  build DateFormatter instances inline.
//

import Foundation

enum DateFormat {
    /// "Tuesday, Aug 11" — used for the Today screen header
    static func weekdayMonthDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }

    /// "Aug 11" — used in journal list rows
    static func monthDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    /// "2026-08-11" — stable day key used for Firestore document IDs / queries
    static func dayKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter.string(from: date)
    }

    /// "3:45 PM" — used for entry timestamps
    static func time(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

extension Date {
    var dayKey: String { DateFormat.dayKey(self) }

    var isToday: Bool { Calendar.current.isDateInToday(self) }

    var startOfDay: Date { Calendar.current.startOfDay(for: self) }

    /// Number of consecutive calendar days between two dates (used for streak math)
    func daysSince(_ other: Date) -> Int {
        Calendar.current.dateComponents([.day], from: other.startOfDay, to: self.startOfDay).day ?? 0
    }
}
