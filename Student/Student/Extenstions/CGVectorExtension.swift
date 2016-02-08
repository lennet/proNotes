//
//  CGVectorExtension.swift
//  Student
//
//  Created by Leo Thomas on 01/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

extension CGVector {

    static func angleBetween(firstVector: CGVector, secondVector: CGVector) -> CGFloat {
        return abs(atan2(secondVector.dy, secondVector.dx)
                - atan2(firstVector.dy, firstVector.dx))
    }

}
