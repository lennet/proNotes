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
    
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let rectPath = UIBezierPath(rect: self.bounds)

        if isSelectedColor {
            UIColor.blackColor().setStroke()
            rectPath.lineWidth = 8
        } else {
            UIColor.darkGrayColor().setStroke()
            rectPath.lineWidth = 2
        }

        rectPath.stroke()
    }
}
