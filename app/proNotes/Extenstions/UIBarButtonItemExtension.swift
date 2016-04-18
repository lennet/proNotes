//
//  UIBarButtonItemExtension.swift
//  proNotes
//
//  Created by Leo Thomas on 04/04/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

extension UIBarButtonItem {

    func setHidden(hidden: Bool) {
        enabled = !hidden
        tintColor = !hidden ? nil : .clearColor()
    }
    
}
