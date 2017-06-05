//
//  ColorPickerCollectionViewCell.swift
//  proNotes
//
//  Created by Leo Thomas on 17/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class ColorPickerCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ColorPickerCollectionViewCellIdentifier"

    var isSelectedColor = false {
        didSet {
            if isSelectedColor {
                layer.setUpHighlitedShadow()
            } else {
                layer.setUpDefaultShaddow()
            }
        }
    }

}
