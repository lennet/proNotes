//
//  ColorPickerCollectionViewCell.swift
//  Student
//
//  Created by Leo Thomas on 17/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class ColorPickerCollectionViewCell: UICollectionViewCell {
    static let identifier = "ColorPickerCollectionViewCellIdentifier"
    
    var isSelectedColor = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.setUpDefaultShaddow()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let context = UIGraphicsGetCurrentContext()

        if isSelectedColor {
            CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
            CGContextSetLineWidth(context, 4)
        }
        CGContextStrokeRect(context, self.bounds)
    }
}
