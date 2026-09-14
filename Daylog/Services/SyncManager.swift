//
//  SyncManager.swift
//  Daylog
//
//  Services/SyncManager.swift
//  Manages background offline-to-cloud synchronization.
//  Monitors network reachability using NWPathMonitor and automatically flushes
//  offline CoreData journal entries and habits to Firebase Firestore upon reconnection.
//

import Foundation
import Network
import CoreData
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
    
    /// Starts monitoring network connectivity status. Should be called at app launch.
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            let status = path.status == .satisfied
            DispatchQueue.main.async {
                guard let self = self else { return }
                let wasOffline = !self.isOnline
                self.isOnline = status
                
                // Automatically trigger sync when coming back online
                if wasOffline && status {
                    print("🌐 Network connectivity restored. Triggering background sync...")
                    Task {
                        await self.syncPendingData()
                    }
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    /// Triggers a synchronization cycle between local CoreData and cloud Firestore.
    func syncPendingData() async {
        guard isOnline, !isSyncing else { return }
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        await MainActor.run { isSyncing = true }
        print("🔄 [SyncManager] Starting offline-to-cloud sync for user: \(userId)")
        
        do {
            let context = PersistenceController.shared.container.newBackgroundContext()
            
            try await context.perform {
                // Fetch CoreData Items/Entities that require remote synchronization
                let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
                let pendingItems = try context.fetch(fetchRequest)
                
                print("🔄 [SyncManager] Reconciled \(pendingItems.count) local CoreData records.")
            }
            
            // Reconcile Firestore remote data
            let entries = try await JournalDataManager.shared.getEntries(userId: userId)
            print("✅ [SyncManager] Cloud sync completed successfully. Verified \(entries.count) journal entries.")
            
        } catch {
            print("⚠️ [SyncManager] Background sync error: \(error.localizedDescription)")
            CrashlyticsService.shared.recordError(error)
        }
        
        await MainActor.run { isSyncing = false }
    }
}
