//
//  CGSizeExtenstion.swift
//  Student
//
//  Created by Leo Thomas on 06/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

extension CGSize {

    mutating func increaseSize(float: CGFloat) -> CGSize{
        self.width += float
        self.height += float
        return self
    }
    
}