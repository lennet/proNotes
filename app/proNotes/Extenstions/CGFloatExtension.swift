//
//  CGFloatExtension.swift
//  proNotes
//
//  Created by Leo Thomas on 01/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

extension CGFloat {

    func toDregees() -> CGFloat {
        return self * 180 / π;
    }

    func toRadians() -> CGFloat {
        return self * π / 180
    }

    func normalized(_ min: CGFloat, max: CGFloat) -> CGFloat {
        return (self - min) / (max - min)
    }

}
