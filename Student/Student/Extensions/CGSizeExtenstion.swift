//
//  CGSizeExtenstion.swift
//  Student
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
    
}