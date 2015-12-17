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
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let rectPath = UIBezierPath(rect: self.bounds)
        rectPath.lineWidth = 2
        UIColor.darkGrayColor().setStroke()

        rectPath.stroke()
    }
}
