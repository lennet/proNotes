//
//  UIImageExtension.swift
//  proNotes
//
//  Created by Leo Thomas on 04/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

extension UIImage {

    func resetRoation() -> UIImage {
        UIGraphicsBeginImageContext(size)
        self.drawAtPoint(CGPointZero)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
    
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

        let rotatedImage = UIImage(CGImage: CGImage, scale: self.scale, orientation: rotation)
        return rotatedImage.resetRoation()
    }
    
    func thumbImage() -> UIImage {
        let newSize = self.size.sizeToFit(CGSize(width: 100, height: 100))
        UIGraphicsBeginImageContextWithOptions( newSize, true, 1.0)
        self.drawInRect(CGRect(origin: CGPoint.zero, size: newSize))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resultImage
    }
    
}
