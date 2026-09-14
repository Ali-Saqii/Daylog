//
//  PerformanceService.swift
//  Daylog
//
//  Services/Firebase/PerformanceService.swift
//  Provides an understandable, clean service wrapper around Firebase Performance Monitoring.
//  Supports custom traces, sync/async operation measurement, and custom metrics/attributes.
//

import Foundation
import FirebasePerformance

final class PerformanceService {
    
    // Shared singleton instance
    static let shared = PerformanceService()
    
    private init() {}
    
    // MARK: - Global Performance Control
    
    /// Enables or disables Firebase Performance data collection dynamically.
    var isDataCollectionEnabled: Bool {
        get {
            Performance.sharedInstance().isDataCollectionEnabled
        }
        set {
            Performance.sharedInstance().isDataCollectionEnabled = newValue
        }
    }

    /// Enables or disables instrumentation (automatic tracing for app launch, network, etc.).
    var isInstrumentationEnabled: Bool {
        get {
            Performance.sharedInstance().isInstrumentationEnabled
        }
        set {
            Performance.sharedInstance().isInstrumentationEnabled = newValue
        }
    }

    // MARK: - Custom Trace Management
    
    /// Starts a custom trace with the given identifier.
    /// - Parameter name: A unique string identifier for the trace (max 100 characters).
    /// - Returns: An active `Trace` instance, or `nil` if creation failed.
    @discardableResult
    func startTrace(name: String) -> Trace? {
        guard let trace = Performance.startTrace(name: name) else {
            print("⚠️ [PerformanceService] Unable to create trace with name: \(name)")
            return nil
        }
        return trace
    }
    
    /// Stops an active custom trace.
    /// - Parameter trace: The trace instance to stop.
    func stopTrace(_ trace: Trace?) {
        trace?.stop()
    }
    
    // MARK: - Convenient Closure Execution Measuring
    
    /// Measures the execution duration of a synchronous code block.
    /// - Parameters:
    ///   - name: Identifier for the custom performance trace.
    ///   - block: The synchronous code block to execute.
    /// - Returns: The return value of the executed block.
    func measure<T>(name: String, block: () throws -> T) rethrows -> T {
        let trace = startTrace(name: name)
        defer {
            stopTrace(trace)
        }
        return try block()
    }
    
    /// Measures the execution duration of an asynchronous Swift `async/await` code block.
    /// Automatically records success or failure status as a custom attribute.
    /// - Parameters:
    ///   - name: Identifier for the custom performance trace.
    ///   - block: The async code block to execute.
    /// - Returns: The return value of the executed async block.
    func measureAsync<T>(name: String, block: () async throws -> T) async rethrows -> T {
        let trace = startTrace(name: name)
        do {
            let result = try await block()
            trace?.setValue("success", forAttribute: "status")
            stopTrace(trace)
            return result
        } catch {
            trace?.setValue("failure", forAttribute: "status")
            trace?.setValue(error.localizedDescription, forAttribute: "error_message")
            stopTrace(trace)
            throw error
        }
    }
    
    // MARK: - Trace Metrics & Attributes
    
    /// Sets a numeric metric value for a specific trace (e.g. item count, byte size).
    /// - Parameters:
    ///   - name: Metric key identifier.
    ///   - value: Integer value to set.
    ///   - trace: Active trace instance.
    func setMetric(name: String, value: Int64, on trace: Trace?) {
        trace?.setValue(value, forMetric: name)
    }
    
    /// Increments a metric value on an active trace by a specified amount (default: 1).
    /// - Parameters:
    ///   - name: Metric key identifier.
    ///   - amount: Amount to increment by.
    ///   - trace: Active trace instance.
    func incrementMetric(name: String, by amount: Int64 = 1, on trace: Trace?) {
        trace?.incrementMetric(name, by: amount)
    }
    
    /// Adds custom string metadata attribute to an active trace.
    /// - Parameters:
    ///   - value: Attribute string value.
    ///   - attribute: Attribute key identifier.
    ///   - trace: Active trace instance.
    func setAttribute(value: String, forAttribute attribute: String, on trace: Trace?) {
        trace?.setValue(value, forAttribute: attribute)
    }
}
