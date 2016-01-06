//
//  ArrayExtension.swift
//  Student
//
//  Created by Leo Thomas on 06/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

extension Array {

    func indexOfObject(object: Element) -> NSInteger {
        return self.indexOfObject(object)
    }

    func containsObject(object: Any) -> Bool {
        if let anObject: AnyObject = object as? AnyObject {
            for obj in self {
                if let anObj: AnyObject = obj as? AnyObject {
                    if anObj === anObject {
                        return true
                    }
                }
            }
        }
        return false
    }

    mutating func removeObject(object: Element) {
        for var index = self.indexOfObject(object); index != NSNotFound; index = self.indexOfObject(object) {
            self.removeAtIndex(index)
        }
    }
}
    