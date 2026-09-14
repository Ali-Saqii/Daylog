//
//  PerformanceViewModifier.swift
//  Daylog
//
//  Utilities/PerformanceViewModifier.swift
//  Provides SwiftUI View extension and modifier for measuring view appearance and rendering performance.
//

import SwiftUI
import FirebasePerformance

/// ViewModifier that automatically starts a Firebase Performance trace when a view appears
/// and stops it when the view disappears.
struct PerformanceTraceModifier: ViewModifier {
    let traceName: String
    @State private var trace: Trace?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                trace = PerformanceService.shared.startTrace(name: traceName)
            }
            .onDisappear {
                PerformanceService.shared.stopTrace(trace)
                trace = nil
            }
    }
}

extension View {
    /// Tracks the appearance duration of this view in Firebase Performance Monitoring.
    /// - Parameter name: Identifier for the custom trace.
    func onPerformanceTrace(_ name: String) -> some View {
        self.modifier(PerformanceTraceModifier(traceName: name))
    }
}
