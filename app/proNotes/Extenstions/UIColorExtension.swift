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
    
    class func randomColorPattern() -> UIColor {
        return UIColor().colorWithPattern({ (i, k) -> UIColor in
            return UIColor.randomColor()
        })
    }
    
    class func clearColorPattern() -> UIColor {
        return UIColor().colorWithPattern({ (i, k) -> UIColor in
            if k % 2 + i % 2 == 1 {
                return lightGrayColor()
            } else {
                return whiteColor()
            }
        })
    }
    
    private func colorWithPattern(fillColorFoRect: (Int, Int) -> UIColor) -> UIColor {
        let size = CGSize(width: 100, height: 100)
        let rectSize = size.width/10
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        for i in 0...Int(rectSize) {
            for k in 0...Int(rectSize) {
                CGContextSetFillColorWithColor(context, fillColorFoRect(i, k).CGColor)
                let rect = CGRect(origin: CGPoint(x: CGFloat(k) * rectSize,y: CGFloat(i) * rectSize), size: CGSize(width: rectSize, height: rectSize))
                CGContextFillRect(context, rect)
            }
        }
        let patternImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIColor(patternImage: patternImage)
    }
    
    // MARK Custom Colors
    // from http://flatuicolors.com

    class func PNYellowColor() -> UIColor {
        return UIColor(red: 256/255, green: 205/255, blue: 0/255, alpha: 1)
    }
    
    class func PNRedColor() -> UIColor {
        return UIColor(red: 254/255, green: 56/255, blue: 36/255, alpha: 1)
    }
    
    class func PNLightBlueColor() -> UIColor {
        return UIColor(red: 84/255, green: 199/255, blue: 252/255, alpha: 1)
    }
    
    class func PNGreenColor() -> UIColor {
        return UIColor(red: 68/255, green: 219/255, blue: 94/255, alpha: 1)
    }
    
    class func PNTurqoiseColor() -> UIColor {
        return UIColor(red: 41/255, green: 187/255, blue: 156/255, alpha: 1)
    }
    
    class func PNEmeraldColor() -> UIColor {
        return UIColor(red: 57/255, green: 202/255, blue: 116/255, alpha: 1)
    }

    class func PNGreenSeaColor() -> UIColor {
        return UIColor(red: 35/255, green: 159/255, blue: 133/255, alpha: 1)
    }
    
    class func PNNephritisColor() -> UIColor {
        return UIColor(red: 48/255, green: 173/255, blue: 99/255, alpha: 1)
    }
    
    class func PNPeterRiverColor() -> UIColor {
        return UIColor(red: 58/255, green: 153/255, blue: 216/255, alpha: 1)
    }
    
    class func PNBelizeHoleColor() -> UIColor {
        return UIColor(red: 47/255, green: 129/255, blue: 183/255, alpha: 1)
    }
    
    class func PNAmethystColor() -> UIColor {
        return UIColor(red: 154/255, green: 92/255, blue: 180/255, alpha: 1)
    }
    
    class func PNWisteriaColor() -> UIColor {
        return UIColor(red: 141/255, green: 72/255, blue: 171/255, alpha: 1)
    }
    
    class func PNWetAsphaltColor() -> UIColor {
        return UIColor(red: 53/255, green:73/255, blue: 93/255, alpha: 1)
    }
    
    class func PNMidnightBlueColor() -> UIColor {
        return UIColor(red: 45/255, green: 62/255, blue: 79/255, alpha: 1)
    }
    
    class func SunFlowerColor() -> UIColor {
        return UIColor(red: 240/255, green: 195/255, blue: 48/255, alpha: 1)
    }
    
    class func PNCarrotColor() -> UIColor {
        return UIColor(red: 228/255, green: 126/255, blue: 48/255, alpha: 1)
    }
    
    class func PNOrangeColor() -> UIColor {
        return UIColor(red: 241/255, green: 155/255, blue: 44/255, alpha: 1)
    }
    
    class func PNPumpkinColor() -> UIColor {
        return UIColor(red: 209/255, green: 84/255, blue: 25/255, alpha: 1)
    }
    
    class func PNAlizarinColor() -> UIColor {
        return UIColor(red: 229/255, green: 77/255, blue: 66/255, alpha: 1)
    }
    
    class func PNPomegranateColor() -> UIColor {
        return UIColor(red: 190/255, green: 58/255, blue: 49/255, alpha: 1)
    }
    
    class func PNCloudsColor() -> UIColor {
        return UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1)
    }
    
    class func PNSilverColor() -> UIColor {
        return UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
    }
    
    class func PNConcreteColor() -> UIColor {
        return UIColor(red: 149/255, green: 165/255, blue: 166/255, alpha: 1)
    }
    
    class func PNAsbestonsColor() -> UIColor {
        return UIColor(red: 127/255, green: 140/255, blue: 141/255, alpha: 1)
    }
    
    class func PNIconBlueColor() -> UIColor {
        return UIColor(red: 28/255, green: 129/255, blue: 255/255, alpha: 1)
    }
    
}
