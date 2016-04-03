//
//  CircleView.swift
//  proNotes
//
//  Created by Leo Thomas on 24/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

@IBDesignable
class CircleView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
    }


    override func prepareForInterfaceBuilder() {
        backgroundColor = UIColor.clearColor()
    }

    @IBInspectable
    var radius: CGFloat = 10 {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable
    var strokeColor: UIColor = UIColor.blackColor() {
        didSet {
            setNeedsDisplay()
        }
    }

    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        let circleRect = CGRect(center: bounds.getCenter(), size: CGSize(width: radius * 2, height: radius * 2))

        strokeColor.setStroke()
        CGContextStrokeEllipseInRect(context, circleRect)

    }


}
