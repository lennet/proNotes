//
//  NSURLExtension.swift
//  proNotes
//
//  Created by Leo Thomas on 17/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

extension URL {

    func fileName(_ withExtensionName: Bool) -> String? {
        let lastPathComponent = deletingPathExtension().lastPathComponent
        
        if withExtensionName {
            return lastPathComponent
        } else {
            var components = lastPathComponent.components(separatedBy: ".")
            if components.count > 1 {
                components.removeLast()
            }
            return components.joined(separator: ".")
        }
    }

}
