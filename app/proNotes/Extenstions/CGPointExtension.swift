//
//  CGPointExtension.swift
//  proNotes
//
//  Created by Leo Thomas on 06/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

extension CGPoint {

    mutating func addPoint(point: CGPoint) {
        x += point.x
        y += point.y
    }

}
