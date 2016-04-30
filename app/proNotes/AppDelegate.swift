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
        guard let message = notification.alertBody else {
            return
        }
        let error = notification.userInfo?["error"] as? Bool ?? false
        let notifyView = NotificationView(message: message, error: error) {
            if error {
                UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
            } else {
                if let navViewController = self.window?.rootViewController as? UINavigationController {
                    if navViewController.visibleViewController is DocumentViewController {
                        navViewController.popViewControllerAnimated(true)
                    }
                }
            }
        }
        window?.addSubview(notifyView)
    }

}

