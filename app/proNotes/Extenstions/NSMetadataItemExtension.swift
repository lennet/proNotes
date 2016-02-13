//
//  NSMetadataItemExtension.swift
//  proNotes
//
//  Created by Leo Thomas on 22/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

extension NSMetadataItem {

    var fileURL: NSURL? {
        get {
            return valueForAttribute(NSMetadataItemURLKey) as? NSURL
        }
    }

    func printAttributes() {
        for attribute in attributes {
            print("\(attribute): \(valueForAttribute(attribute))")
        }
    }

    func isLocalAvailable() -> Bool {
        guard let path = fileURL?.path else {
            return false
        }
        return NSFileManager.defaultManager().fileExistsAtPath(path)
    }
}
