//
//  ImageLayer.swift
//  proNotes
//
//  Created by Leo Thomas on 20/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class ImageLayer: MovableLayer {
    
    var image: UIImage? {
        get {
            return ImageCache.sharedInstance[imageKey]
        }
        
        set {
            ImageCache.sharedInstance[imageKey] = newValue
        }
    }
    
    let imageKey = UUID().uuidString

    init(index: Int, docPage: DocumentPage, origin: CGPoint, size: CGSize?, image: UIImage) {
        super.init(index: index, type: .image, docPage: docPage, origin: origin, size: size ?? image.size)
        self.image = image
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, type: .image)
        type  = .image
        if let imageData = aDecoder.decodeObject(forKey: imageDataKey) as? Data {
            image = UIImage(data: imageData)!
        } else {
            image = UIImage()
        }
    }
    
    required init(coder aDecoder: NSCoder, type: DocumentLayerType) {
        fatalError("init(coder:type:) has not been implemented")
    }

    private final let imageDataKey = "imageData"

    override func encode(with aCoder: NSCoder) {
        guard let image = image else { return }
        
        if let imageData = UIImageJPEGRepresentation(image, 1.0) {
            aCoder.encode(imageData, forKey: imageDataKey)
        } else {
            print("Could not save drawing Image")
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
        guard object is ImageLayer else {
            return false
        }

        if !super.isEqual(object) {
            return false
        }

        return true
    }

}
