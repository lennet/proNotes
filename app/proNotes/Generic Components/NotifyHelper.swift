//
//  NotifyHelper.swift
//  proNotes
//
//  Created by Leo Thomas on 27/04/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class NotifyHelper {
    class func fireNotification(error: Bool = false) {
        if Preferences.allowsNotification() {
            let localNotification = UILocalNotification()
            localNotification.fireDate = NSDate(timeIntervalSinceNow: 1)
            localNotification.alertBody = error ? NSLocalizedString("downloaddata.error", comment: "") : NSLocalizedString("downloaddata.success", comment: "")
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.applicationIconBadgeNumber = 1
            localNotification.userInfo = ["error": error]
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }
    }
}
