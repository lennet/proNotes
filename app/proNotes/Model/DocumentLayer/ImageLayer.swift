//
//  ImageLayer.swift
//  proNotes
//
//  Created by Leo Thomas on 20/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class ImageLayer: MovableLayer {
    var image: UIImage

    init(index: Int, docPage: DocumentPage, origin: CGPoint, size: CGSize?, image: UIImage) {
        self.image = image
        super.init(index: index, type: .Image, docPage: docPage, origin: origin, size: size ?? image.size)
    }

    required init(coder aDecoder: NSCoder) {
        if let imageData = aDecoder.decodeObjectForKey(imageDataKey) as? NSData {
            image = UIImage(data: imageData)!
        } else {
            image = UIImage()
        }

        super.init(coder: aDecoder)
    }

    private final let imageDataKey = "imageData"

    override func encodeWithCoder(aCoder: NSCoder) {
        if let imageData = UIImageJPEGRepresentation(image, 1.0) {
            aCoder.encodeObject(imageData, forKey: imageDataKey)
        } else {
            print("Could not save drawing Image")
        }
        super.encodeWithCoder(aCoder)
    }

    override func undoAction(oldObject: AnyObject?) {
        if let image = oldObject as? UIImage {
            self.image = image
        } else {
            super.undoAction(oldObject)
        }
    }

    override func isEqual(object: AnyObject?) -> Bool {
        guard object is ImageLayer else {
            return false
        }

        if !super.isEqual(object) {
            return false
        }

        return true
    }

}
