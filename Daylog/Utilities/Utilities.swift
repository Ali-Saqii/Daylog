//
//  Utilities.swift
//  Firbase
//
//  Created by Mac mini on 21/07/2026.
//

import Foundation
import UIKit

final class Utilities {
    
    static let shared = Utilities()
    private init () {}
    // Source - https://stackoverflow.com/a/30858591
    // Posted by DLende, modified by community. See post 'Timeline' for change history
    // Retrieved 2026-07-21, License - CC BY-SA 4.0
        @MainActor
         func topViewController(controller: UIViewController? = nil ) -> UIViewController? {
             
             let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
            if let navigationController = controller as? UINavigationController {
                return topViewController(controller: navigationController.visibleViewController)
            }
            if let tabController = controller as? UITabBarController {
                if let selected = tabController.selectedViewController {
                    return topViewController(controller: selected)
                }
            }
            if let presented = controller?.presentedViewController {
                return topViewController(controller: presented)
            }
            return controller
        }
}
