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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
        application.applicationIconBadgeNumber = 0
        if Preferences.isFirstRun() {
            Preferences.setUpDefaults()
        }
        let args = ProcessInfo.processInfo().arguments
        if args.contains("UITEST") {
            Preferences.setShoudlShowWelcomeScreen(false)
            Preferences.setAlreadyDownloadedDefaultNote(true)
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        DocumentInstance.sharedInstance.save {
            (success) -> Void in
            DocumentInstance.sharedInstance.document?.close(completionHandler: nil)
        }
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if application.applicationState == .inactive {
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
    
    func handleTapOnNotification(_ userInfo: [NSObject : AnyObject]?) {
        let error = userInfo?["error"] as? Bool ?? false
        if error {
            UIApplication.shared().openURL(URL(string:UIApplicationOpenSettingsURLString)!)
        } else {
            let overViewController = self.moveToOverViewIfNeeded(true)
            if let path = userInfo?["url"] as? String {
                let url = URL(fileURLWithPath: path)
                overViewController?.openDocument(url)
            }
        }
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        let overViewController = moveToOverViewIfNeeded(false)
        overViewController?.createNewDocument()
    }
    
    private func moveToOverViewIfNeeded(_ animated: Bool) -> DocumentOverviewViewController? {
        if let navViewController = self.window?.rootViewController as? UINavigationController {
            if navViewController.visibleViewController is DocumentViewController {
                navViewController.popViewController(animated: animated)
                DocumentInstance.sharedInstance.removeAllDelegates()
            }
            return navViewController.viewControllers.first as? DocumentOverviewViewController
        }
        return nil 
    }

}

