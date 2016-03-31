//
//  UIColorExtension.swift
//  proNotes
//
//  Created by Leo Thomas on 07/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

extension UIColor {

    class func randomColor() -> UIColor {
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
    }
    
    class func clearColorPattern() -> UIColor{
        let size = CGSize(width: 100, height: 100)
        let rectSize = size.width/10
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        for i in 0...Int(rectSize) {
            for k in 0...Int(rectSize) {
                if k % 2 + i % 2 == 1 {
                    CGContextSetFillColorWithColor(context, lightGrayColor().CGColor)
                } else {
                    CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
                }
                let rect = CGRect(origin: CGPoint(x: CGFloat(k) * rectSize,y: CGFloat(i) * rectSize), size: CGSize(width: rectSize, height: rectSize))
                CGContextFillRect(context, rect)
            }
        }
        let patternImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIColor(patternImage: patternImage)
    }

}
