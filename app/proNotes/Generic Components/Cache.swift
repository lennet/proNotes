//
//  Cache.swift
//  proNotes
//
//  Created by Leo Thomas on 31/05/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import Foundation

class Cache<T: AnyObject>: NSCache {
    
    subscript(key: AnyObject) -> T? {
        get {
            return objectForKey(key)
        }
        set {
            if let value = newValue {
                setObject(value, forKey: key)
            }
        }
    }
    
    func objectForKey(key: AnyObject) -> T? {
        return super.objectForKey(key) as? T
    }
    
}
