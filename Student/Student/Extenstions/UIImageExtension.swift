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
}
