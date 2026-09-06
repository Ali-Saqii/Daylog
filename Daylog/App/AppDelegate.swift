import SwiftUI
import CoreData
import FirebaseCore
import FirebaseAppCheck
import FacebookCore
import NotificationCenter

class AppDelegate: NSObject, UIApplicationDelegate,UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
#if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
#endif
        FirebaseApp.configure()
        print("configured firebase")
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
   
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationManager.shared.clearBadgeCount()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
