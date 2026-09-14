import SwiftUI
import CoreData
import FirebaseCore
import FirebaseCrashlytics
import FirebasePerformance
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
        FCMService.shared.setup()
        print("configured firebase (including Performance Monitoring)")
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        UNUserNotificationCenter.current().delegate = self
        // Register for remote (APNs) notifications so FCM can receive push tokens
        application.registerForRemoteNotifications()
        return true
    }

    // Forward APNs device token to FCM
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        FCMService.shared.setAPNSToken(deviceToken)
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
