//
//  CGRectExtension.swift
//  proNotes
//
//  Created by Leo Thomas on 04/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

extension CGRect {

    init(center: CGPoint, width: CGFloat, height: CGFloat) {
        size = CGSize(width: width, height: height)
        origin = CGPoint(x: center.x - width / 2, y: center.y - height / 2)
    }

    init(center: CGPoint, size: CGSize) {
        self.size = size
        origin = CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2)
    }

    func getCenter() -> CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}
