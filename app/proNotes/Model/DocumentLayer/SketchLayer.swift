//
//  SketchLayer.swift
//  proNotes
//
//  Created by Leo Thomas on 20/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class SketchLayer: DocumentLayer {
    var image: UIImage? {
        get {
            return ImageCache.sharedInstance[imageKey]
        }
        
        set {
            ImageCache.sharedInstance[imageKey] = newValue
        }
    }
    
    let imageKey = NSUUID().UUIDString
    
    init(index: Int, image: UIImage?, docPage: DocumentPage) {
        super.init(index: index, type: .Sketch, docPage: docPage)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if let imageData = aDecoder.decodeObjectForKey(imageDataKey) as? NSData {
            image = UIImage(data: imageData)
        }
    }

    private final let imageDataKey = "imageData"

    override func encodeWithCoder(aCoder: NSCoder) {
        if image != nil {
            if let imageData = UIImagePNGRepresentation(image!) {
                aCoder.encodeObject(imageData, forKey: imageDataKey)
            } else {
                print("Could not save drawing Image")
            }
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
        guard let layer = object as? SketchLayer else {
            return false
        }

        if !super.isEqual(object) {
            return false
        }

        guard layer.index == index else {
            return false
        }

//        guard layer.image == image else {
//            return false
//        }

        return true
    }

}
