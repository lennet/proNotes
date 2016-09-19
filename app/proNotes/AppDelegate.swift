//
//  AppDelegate.swift
//  proNotes
//
//  Created by Leo Thomas on 26/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        if Preferences.isFirstRun {
            Preferences.setUpDefaults()
        }
        let args = ProcessInfo.processInfo.arguments
        if args.contains("UITEST") {
            Preferences.showWelcomeScreen = false
            Preferences.iCloudActive =  false
        }
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        DocumentInstance.sharedInstance.save {
            (success) -> Void in
            DocumentInstance.sharedInstance.document?.close(completionHandler: nil)
        }
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> ()) {
        let overViewController = moveToOverViewIfNeeded(false)
        overViewController?.createNewDocument()
        completionHandler(true)
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

