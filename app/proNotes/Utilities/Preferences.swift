//
//  Preferences.swift
//  Student
//
//  Created by Leo Thomas on 17/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class Preferences {

    static private let iCloudActiveKey = "iCloudActive"
    static private let iCloudWasActiveKey = "iCloudWasActive"
    static private let DownloadedDefaultNoteKey = "DownloadedDefaultNote"
    static private let allowsNotificationKey = "allowsNotification"
    static private let isFirstRunKey = "isFirstRun"
    static private let shouldShowWelcomeScreenKey = "shouldShowWelcomeScreen"

    //MARK - iCloud Handling
    
    class func setUpDefaults() {
        setShoudlShowWelcomeScreen(true)
        setIsFirstRun(false)
    }

    class func iCloudActive() -> Bool {
        return UserDefaults.standard.bool(forKey: iCloudActiveKey)
    }

    class func setiCloudActive(_ active: Bool) {
        UserDefaults.standard.set(active, forKey: iCloudActiveKey)
        UserDefaults.standard.synchronize()
    }

    class func iCloudWasActive() -> Bool {
        return UserDefaults.standard.bool(forKey: iCloudWasActiveKey)
    }

    class func setiCloudWasActive(_ active: Bool) {
        UserDefaults.standard.set(active, forKey: iCloudWasActiveKey)
        UserDefaults.standard.synchronize()
    }
        
    class func allowsNotification() -> Bool {
        return UserDefaults.standard.bool(forKey: allowsNotificationKey)
    }
    
    class func setAllowsNotification(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: allowsNotificationKey)
    }
    
    class func isFirstRun() -> Bool {
        if UserDefaults.standard.value(forKey: isFirstRunKey) != nil {
            return UserDefaults.standard.bool(forKey: isFirstRunKey)
        }
        return true
    }
    
    class func setIsFirstRun(_ value: Bool) {
        return UserDefaults.standard.set(value, forKey: isFirstRunKey)
    }
    
    class func setShoudlShowWelcomeScreen(_ value: Bool) {
        return UserDefaults.standard.set(value, forKey: shouldShowWelcomeScreenKey)
    }
    
    class func shouldShowWelcomeScreen() -> Bool {
        return UserDefaults.standard.bool(forKey: shouldShowWelcomeScreenKey)
    }

}
