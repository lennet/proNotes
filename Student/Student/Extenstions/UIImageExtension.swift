//
//  UIImageExtension.swift
//  Student
//
//  Created by Leo Thomas on 04/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

extension UIImage {

    func cropedImage(rect: CGRect) -> UIImage? {
        if let croppedCGImage = CGImageCreateWithImageInRect(self.CGImage, rect) {
            return UIImage(CGImage: croppedCGImage)
        }
        return nil
    }
    
    func rotateImage(rotation: UIImageOrientation) -> UIImage? {
        guard let CGImage = self.CGImage else {
            return nil
        }
        
        var newSize = size
        
        switch rotation {
        case .Left, .Right:
            newSize = CGSize(width: newSize.height, height: newSize.width)
            break
        default:
            // nothig to do
            break
        }

        let rotatedImage = UIImage(CGImage: CGImage, scale: self.scale, orientation: rotation)
        UIGraphicsBeginImageContext(rotatedImage.size)
        rotatedImage.drawAtPoint(CGPointZero)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resultImage
    }
    
    func sizeToFit(size: CGSize) -> CGSize {
        let widthRatio = self.size.width/size.width
        let heightRatio = self.size.height/size.height 

        let ratio = widthRatio > heightRatio ? widthRatio : heightRatio
        
        return CGSize(width: self.size.width/ratio, height: self.size.height/ratio)
    }
}
