//
//  CGSizeExtenstion.swift
//  proNotes
//
//  Created by Leo Thomas on 06/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

extension CGSize {

    mutating func increaseSize(float: CGFloat) -> CGSize {
        self.width += float
        self.height += float
        return self
    }

    mutating func increaseSize(size: CGSize) -> CGSize {
        self.width += size.width
        self.height += size.height
        return self
    }

    mutating func multiplySize(factor: CGFloat) {
        self.width *= factor
        self.height *= factor
    }

    func sizeToFit(size: CGSize) -> CGSize {
        let widthRatio = self.width / size.width
        let heightRatio = self.height / size.height
        
        let ratio = max(widthRatio, heightRatio)
        
        return CGSize(width: self.width / ratio, height: self.height / ratio)
    }
    
    static func dinA4() -> CGSize {
        return CGSize(width: 2384 / 3, height: 3370 / 3)
    }

    static func dinA4LandScape() -> CGSize {
        let size = dinA4()
        return CGSize(width: size.height, height: size.width)
    }

    static func quadratic() -> CGSize {
        return CGSize(width: 2384 / 3, height: 2384 / 3)
    }

    static func paperSizes() -> [CGSize] {
        return [dinA4(), quadratic(), dinA4LandScape()]
    }

}