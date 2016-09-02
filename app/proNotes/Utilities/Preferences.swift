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
    static private let isFirstRunKey = "isFirstRun"
    static private let shouldShowWelcomeScreenKey = "shouldShowWelcomeScreen"

    //MARK - iCloud Handling
    
    class func setUpDefaults() {
        showWelcomeScreen = true
        isFirstRun = false
        iCloudActive = true
    }

    class var iCloudActive: Bool {
        
        get {
            return UserDefaults.standard.bool(forKey: iCloudActiveKey)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: iCloudActiveKey)
        }
        
    }
    
    
    class var isFirstRun: Bool {
        
        get {
            if UserDefaults.standard.value(forKey: isFirstRunKey) != nil {
                return UserDefaults.standard.bool(forKey: isFirstRunKey)
            }
            return true
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: isFirstRunKey)
        }
        
    }
    
    class var showWelcomeScreen: Bool {
        
        get {
            return UserDefaults.standard.bool(forKey: shouldShowWelcomeScreenKey)
        }
        
        set {
            return UserDefaults.standard.set(newValue, forKey: shouldShowWelcomeScreenKey)
        }
        
    }

}
