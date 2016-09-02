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
        self.draw(at: .zero)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage!
    }
    
    func cropedImage(_ rect: CGRect) -> UIImage? {
        if let croppedCGImage = self.cgImage?.cropping(to: rect) {
            return UIImage(cgImage: croppedCGImage)
        }
        return nil
    }

    func rotateImage(_ rotation: UIImageOrientation) -> UIImage? {
        guard let CGImage = self.cgImage else {
            return nil
        }

        let rotatedImage = UIImage(cgImage: CGImage, scale: self.scale, orientation: rotation)
        return rotatedImage.resetRoation()
    }
    
    func thumbImage() -> UIImage {
        let newSize = self.size.sizeToFit(CGSize(width: 100, height: 100))
        UIGraphicsBeginImageContextWithOptions( newSize, true, 1.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resultImage!
    }
    
}
