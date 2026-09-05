import SwiftUI
import CoreData
import FirebaseCore
import FirebaseAppCheck
import FacebookCore

class AppDelegate: NSObject, UIApplicationDelegate {
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
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // AppEvents.shared.activateApp() is disabled to prevent blocked API access log
    }
    
}
