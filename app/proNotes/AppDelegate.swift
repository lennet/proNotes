//
//  AppDelegate.swift
//  proNotes
//
//  Created by Leo Thomas on 26/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
        application.applicationIconBadgeNumber = 0
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        application.applicationIconBadgeNumber = 0    }

    func applicationDidEnterBackground(application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillEnterForeground(application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        DocumentInstance.sharedInstance.save {
            (success) -> Void in
            DocumentInstance.sharedInstance.document?.closeWithCompletionHandler(nil)
        }
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if application.applicationState == .Inactive {
            handleTapOnNotification(notification.userInfo)
        } else {
            guard let message = notification.alertBody else {
                return
            }
            let error = notification.userInfo?["error"] as? Bool ?? false
            let notifyView = NotificationView(message: message, error: error) {
                self.handleTapOnNotification(notification.userInfo)
            }
            window?.addSubview(notifyView)
        }
    }
    
    func handleTapOnNotification(userInfo: [NSObject : AnyObject]?) {
        let error = userInfo?["error"] as? Bool ?? false
        if error {
            UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
        } else {
            let overViewController = self.moveToOverViewIfNeeded(true)
            if let path = userInfo?["url"] as? String {
                let url = NSURL.fileURLWithPath(path)
                overViewController?.openDocument(url)
            }
        }
    }
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        let overViewController = moveToOverViewIfNeeded(false)
        overViewController?.createNewDocument()
    }
    
    private func moveToOverViewIfNeeded(animated: Bool) -> DocumentOverviewViewController? {
        if let navViewController = self.window?.rootViewController as? UINavigationController {
            if navViewController.visibleViewController is DocumentViewController {
                navViewController.popViewControllerAnimated(animated)
                DocumentInstance.sharedInstance.removeAllDelegates()
            }
            return navViewController.viewControllers.first as? DocumentOverviewViewController
        }
        return nil 
    }

}

