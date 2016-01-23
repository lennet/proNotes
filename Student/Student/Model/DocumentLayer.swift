//
//  DocumentLayer.swift
//  Student
//
//  Created by Leo Thomas on 13/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

// TODO Error Handling for Decoding Problems

enum DocumentLayerType: Int {
    case PDF = 1
    case Drawing = 2
    case Image = 3
    case Text = 4
    case Plot = 5
}

class DocumentLayer: NSObject, NSCoding {
    var index: Int
    var type: DocumentLayerType
    var docPage: DocumentPage!
    var hidden = false

    init(index: Int, type: DocumentLayerType, docPage: DocumentPage) {
        self.index = index
        self.type = type
        self.docPage = docPage
    }

    init(fileWrapper: NSFileWrapper, index: Int, docPage: DocumentPage) {
        self.index = index
        self.type = .Drawing
        self.docPage = docPage
    }

    required init(coder aDecoder: NSCoder) {
        self.index = aDecoder.decodeIntegerForKey(indexKey)
        self.type = DocumentLayerType(rawValue: aDecoder.decodeIntegerForKey(typeRawValueKey))!
        self.hidden = aDecoder.decodeBoolForKey(hiddenKey)
        super.init()
    }
    
    private final let indexKey = "index"
    private final let typeRawValueKey = "type"
    private final let hiddenKey = "key"
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(index, forKey: indexKey)
        aCoder.encodeInteger(type.rawValue, forKey: typeRawValueKey)
        aCoder.encodeBool(hidden, forKey: hiddenKey)
    }
    
    func removeFromPage() {
        self.docPage.removeLayer(self, forceReload: false)
    }
}

class MovableLayer: DocumentLayer {
    var origin: CGPoint
    var size: CGSize

    init(index: Int, type: DocumentLayerType, docPage: DocumentPage, origin: CGPoint, size: CGSize) {
        self.origin = origin
        self.size = size

        super.init(index: index, type: type, docPage: docPage)
    }

    required init(coder aDecoder: NSCoder) {
        origin = aDecoder.decodeCGPointForKey(originKey)
        size = aDecoder.decodeCGSizeForKey(sizeKey)
        super.init(coder: aDecoder)
    }
    
    private final let sizeKey = "size"
    private final let originKey = "origin"
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeCGPoint(origin, forKey: originKey)
        aCoder.encodeCGSize(size, forKey: sizeKey)
        super.encodeWithCoder(aCoder)
    }
}

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
        if let imageData = UIImagePNGRepresentation(image) {
            aCoder.encodeObject(imageData, forKey: imageDataKey)
        } else {
            print("Could not save drawing Image")
        }
        super.encodeWithCoder(aCoder)
    }

}

class TextLayer: MovableLayer {
    var text: String

    init(index: Int, docPage: DocumentPage, origin: CGPoint, size: CGSize, text: String) {
        self.text = text
        super.init(index: index, type: .Text, docPage: docPage, origin: origin, size: size)
    }

    required init(coder aDecoder: NSCoder) {
        text = aDecoder.decodeObjectForKey(textKey) as! String
        super.init(coder: aDecoder)
    }
    
    private final let textKey = "text"
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(text, forKey: textKey)
        super.encodeWithCoder(aCoder)
    }
}

class PlotLayer: MovableLayer {
    var function: String
    init(index: Int, docPage: DocumentPage, origin: CGPoint, size: CGSize) {
        function = "cos($x)"
        super.init(index: index, type: .Plot, docPage: docPage, origin: origin, size: size)
    }

    required init(coder aDecoder: NSCoder) {
        self.function = ""
       super.init(coder: aDecoder)
    }

}

class DocumentPDFLayer: DocumentLayer {
    var page: CGPDFPage?
    init(index: Int, page: CGPDFPage, docPage: DocumentPage) {
        self.page = page
        super.init(index: index, type: .PDF, docPage: docPage)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // TODO!
    }
}

class DocumentDrawLayer: DocumentLayer {
    var image: UIImage?
    init(index: Int, image: UIImage?, docPage: DocumentPage) {
        super.init(index: index, type: .Drawing, docPage: docPage)
    }

    required init(coder aDecoder: NSCoder) {
        if let imageData = aDecoder.decodeObjectForKey(imageDataKey) as? NSData {
            image = UIImage(data: imageData)
        }
        super.init(coder: aDecoder)
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
}

