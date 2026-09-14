//
//  SyncManager.swift
//  Daylog
//
//  Services/SyncManager.swift
//  Manages background offline-to-cloud synchronisation.
//  Monitors network reachability via NWPathMonitor and automatically
//  reconciles Firestore data upon reconnection.
//
//  Note: Firestore's own offline persistence handles writes made while
//  offline — they are flushed automatically once connectivity is restored.
//  This manager provides an explicit post-reconnection reconcile so that
//  in-memory ViewModels get a fresh snapshot as soon as the device is back.
//

import Foundation
import Network
import FirebaseFirestore
import FirebaseAuth
import Combine

final class SyncManager: ObservableObject {

    static let shared = SyncManager()

    @Published private(set) var isOnline: Bool = true
    @Published private(set) var isSyncing: Bool = false

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.daylog.networkmonitor")

    private init() {}

    /// Starts monitoring network connectivity. Call once at app launch.
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            DispatchQueue.main.async {
                guard let self else { return }
                let wasOffline = !self.isOnline
                self.isOnline = connected

                // Trigger a reconcile when we come back online
                if wasOffline && connected {
                    print("🌐 [SyncManager] Network restored — triggering reconcile...")
                    Task { await self.syncPendingData() }
                }
            }
        }
        monitor.start(queue: queue)
    }

    /// Reconciles cloud state after reconnection.
    ///
    /// Firestore's offline persistence automatically replays any writes
    /// queued while offline, so we only need to force-refresh the
    /// in-memory caches here.
    func syncPendingData() async {
        guard isOnline, !isSyncing else { return }
        guard let userId = Auth.auth().currentUser?.uid else { return }

        await MainActor.run { isSyncing = true }
        print("🔄 [SyncManager] Starting post-reconnect reconcile for user: \(userId)")

        do {
            // Re-fetch habits and journal entries so ViewModels are up to date.
            // Firestore will have already flushed any queued offline writes by now.
            async let habits  = HabitDataManager.shared.getHabits(userId: userId)
            async let entries = JournalDataManager.shared.getEntries(userId: userId)

            let (h, e) = try await (habits, entries)
            print("✅ [SyncManager] Reconcile complete — \(h.count) habits, \(e.count) journal entries.")

        } catch {
            print("⚠️ [SyncManager] Reconcile error: \(error.localizedDescription)")
            CrashlyticsService.shared.recordError(error)
        }

        await MainActor.run { isSyncing = false }
    }
}
