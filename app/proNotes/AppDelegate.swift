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
        let args = ProcessInfo.processInfo.arguments
        if args.contains("UITEST") {
            Preferences.setShoudlShowWelcomeScreen(false)
            Preferences.setiCloudActive(false)
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
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        let overViewController = moveToOverViewIfNeeded(false)
        overViewController?.createNewDocument()
    }
    
    
    /// Pops all ViewControllers on the ViewControllers-Stack until the DocumentOverViewController is visible
    ///
    /// - parameter animated: defines whether poping the current ViewController should be animated or not
    ///
    /// - returns: the instance of the visible DocumentOverViewController
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

