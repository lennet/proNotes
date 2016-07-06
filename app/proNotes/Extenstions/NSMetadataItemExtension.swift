//
//  NSMetadataItemExtension.swift
//  proNotes
//
//  Created by Leo Thomas on 22/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

extension NSMetadataItem {

    var fileURL: URL? {
        get {
            return value(forAttribute: NSMetadataItemURLKey) as? URL
        }
    }

    func printAttributes() {
        for attribute in attributes {
            print("\(attribute): \(value(forAttribute: attribute))")
        }
    }

    func isLocalAvailable() -> Bool {
        guard let path = fileURL?.path else {
            return false
        }
        return Foundation.FileManager.default.fileExists(atPath: path)
    }
}
