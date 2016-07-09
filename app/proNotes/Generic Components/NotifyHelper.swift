//
//  NotifyHelper.swift
//  proNotes
//
//  Created by Leo Thomas on 27/04/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class NotifyHelper {
    class func fireNotification(_ error: Bool = false, url: URL? = nil) {
        if Preferences.allowsNotification() {
            let localNotification = UILocalNotification()
            localNotification.fireDate = Date(timeIntervalSinceNow: 2)
            localNotification.alertBody = error ? NSLocalizedString("downloaddata.error", comment: "") : NSLocalizedString("downloaddata.success", comment: "")
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.applicationIconBadgeNumber = 1
            var userInfo : [NSObject: AnyObject] = ["error": error]
            if let fileUrl = url, let path = fileUrl.path {
                userInfo["url"] = path
            }
            localNotification.userInfo = userInfo
            UIApplication.shared().scheduleLocalNotification(localNotification)
        }
    }
}
