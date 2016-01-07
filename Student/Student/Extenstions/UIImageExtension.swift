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
    
    func sizeToFit(size: CGSize) -> CGSize {
        let widthRatio = self.size.width/size.width
        let heightRatio = self.size.height/size.height 

        let ratio = widthRatio > heightRatio ? widthRatio : heightRatio
        
        return CGSize(width: self.size.width/ratio, height: self.size.height/ratio)
    }
}
