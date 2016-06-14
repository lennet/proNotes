//
//  NSDateExtension.swift
//  proNotes
//
//  Created by Leo Thomas on 01/04/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

extension Date {

    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.shortStyle
        formatter.timeStyle = .noStyle
        return formatter.string(from: self)
    }
}
