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
        guard let lastPathComponent = try! deletingPathExtension().lastPathComponent else {
            return nil
        }
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
