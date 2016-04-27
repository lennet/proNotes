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


    //MARK - iCloud Handling

    class func iCloudActive() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(iCloudActiveKey)
    }

    class func setiCloudActive(active: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(active, forKey: iCloudActiveKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    class func iCloudWasActive() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(iCloudWasActiveKey)
    }

    class func setiCloudWasActive(active: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(active, forKey: iCloudWasActiveKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func AlreadyDownloadedDefaultNote() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(DownloadedDefaultNoteKey)
    }
    
    class func setAlreadyDownloadedDefaultNote(value: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(value, forKey: DownloadedDefaultNoteKey)
    }
    
    class func allowsNotification() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(allowsNotificationKey)
    }
    
    class func setAllowsNotification(value: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(value, forKey: allowsNotificationKey)
    }
    
    class func isFirstRun() -> Bool {
        if NSUserDefaults.standardUserDefaults().valueForKey(isFirstRunKey) != nil {
            return NSUserDefaults.standardUserDefaults().boolForKey(isFirstRunKey)
        }
        return true
    }
    
    class func setIsFirstRun(value: Bool) {
        return NSUserDefaults.standardUserDefaults().setBool(value, forKey: isFirstRunKey)
    }

}
