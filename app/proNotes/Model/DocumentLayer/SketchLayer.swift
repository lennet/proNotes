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
    
    let imageKey = UUID().uuidString
    
    init(index: Int, image: UIImage?, docPage: DocumentPage) {
        super.init(index: index, type: .sketch, docPage: docPage)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, type: .sketch)
        if let imageData = aDecoder.decodeObject(forKey: imageDataKey) as? Data {
            image = UIImage(data: imageData)
        }
    }
    
    required init(coder aDecoder: NSCoder, type: DocumentLayerType) {
        fatalError("init(coder:type:) has not been implemented")
    }

    private final let imageDataKey = "imageData"

    override func encode(with aCoder: NSCoder) {
        if image != nil {
            if let imageData = UIImagePNGRepresentation(image!) {
                aCoder.encode(imageData, forKey: imageDataKey)
            } else {
                print("Could not save drawing Image")
            }
        }
        super.encode(with: aCoder)
    }

    override func undoAction(_ oldObject: Any?) {
        if let image = oldObject as? UIImage {
            self.image = image
        } else {
            super.undoAction(oldObject)
        }
    }

    override func isEqual(_ object: Any?) -> Bool {
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
