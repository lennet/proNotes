//
//  NSURLExtension.swift
//  proNotes
//
//  Created by Leo Thomas on 17/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

extension NSURL {

    func fileName(withExtensionName: Bool) -> String? {
        guard let lastPathComponent = URLByDeletingPathExtension?.lastPathComponent else {
            return nil
        }
        if withExtensionName {
            return lastPathComponent
        } else {
            var components = lastPathComponent.componentsSeparatedByString(".")
            if components.count > 1 {
                components.removeLast()
            }
            return components.joinWithSeparator(".")
        }
    }

}
