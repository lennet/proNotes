//
//  NSDateExtension.swift
//  proNotes
//
//  Created by Leo Thomas on 01/04/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

extension NSDate {

    func toString() -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = .NoStyle
        return formatter.stringFromDate(self)
    }
}