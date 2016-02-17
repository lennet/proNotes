//
//  DocumentLayer.swift
//  proNotes
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
}

class DocumentLayer: NSObject, NSCoding {
    private final let indexKey = "index"
    private final let typeRawValueKey = "type"
    private final let hiddenKey = "key"
    
    var index: Int
    var type: DocumentLayerType
    weak var docPage: DocumentPage!
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
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(index, forKey: indexKey)
        aCoder.encodeInteger(type.rawValue, forKey: typeRawValueKey)
        aCoder.encodeBool(hidden, forKey: hiddenKey)
    }

    func removeFromPage() {
        self.docPage.removeLayer(self)
    }
    
    func undoAction(oldObject: AnyObject?) {
        // empty Base Implementation
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        guard let layer = object as? DocumentLayer else {
            return false
        }
        
        guard layer.type == type else {
            return false
        }
        
        guard layer.index == index else {
            return false
        }
        
        return layer.hidden == hidden
    }
}

class MovableLayer: DocumentLayer {
    private final let sizeKey = "size"
    private final let originKey = "origin"
    
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

    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeCGPoint(origin, forKey: originKey)
        aCoder.encodeCGSize(size, forKey: sizeKey)
        super.encodeWithCoder(aCoder)
    }
    
    override func undoAction(oldObject: AnyObject?) {
        if let value = oldObject as? NSValue {
            let frame = value.CGRectValue()
            origin = frame.origin
            size = frame.size
        } else {
            super.undoAction(oldObject)
        }
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        guard let layer = object as? MovableLayer else {
            return false
        }
        
        if !super.isEqual(object) {
            return false
        }
        
        guard layer.origin == origin else {
            return false
        }
        
        guard layer.size == size else {
            return false
        }
        
        return true
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
    
    override func undoAction(oldObject: AnyObject?) {
        if let image = oldObject as? UIImage {
            self.image = image
        } else {
            super.undoAction(oldObject)
        }
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        guard let layer = object as? ImageLayer else {
            return false
        }
        
        if !super.isEqual(object) {
            return false
        }
        
        return layer.image == image
    }

}

class TextLayer: MovableLayer {
    private final let textKey = "text"
    var text: String

    init(index: Int, docPage: DocumentPage, origin: CGPoint, size: CGSize, text: String) {
        self.text = text
        super.init(index: index, type: .Text, docPage: docPage, origin: origin, size: size)
    }

    required init(coder aDecoder: NSCoder) {
        text = aDecoder.decodeObjectForKey(textKey) as! String
        super.init(coder: aDecoder)
    }

    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(text, forKey: textKey)
        super.encodeWithCoder(aCoder)
    }
    
    override func undoAction(oldObject: AnyObject?) {
        if let text = oldObject as? String {
            self.text = text
        } else {
            super.undoAction(oldObject)
        }
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        guard let layer = object as? TextLayer else {
            return false
        }
        
        if !super.isEqual(object) {
            return false
        }
        
        return layer.text == self.text
    }
    
}

class DocumentPDFLayer: DocumentLayer {
    private final let pdfKey = "pdf"
    
    var pdfPage: CGPDFDocument?

    init(index: Int, page: CGPDFDocument, docPage: DocumentPage) {
        self.pdfPage = page
        super.init(index: index, type: .PDF, docPage: docPage)
    }

    required init(coder aDecoder: NSCoder) {
        if let pdfData = aDecoder.decodeObjectForKey(pdfKey) as? NSData {
            pdfPage = PDFUtility.createPDFFromData(pdfData as CFDataRef)
        }
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
       
        if pdfPage != nil {
            aCoder.encodeObject(PDFUtility.getPageAsData(1, document: pdfPage!), forKey: pdfKey)
        }
        
        super.encodeWithCoder(aCoder)
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        guard let layer = object as? DocumentPDFLayer else {
            return false
        }
        
        if !super.isEqual(object) {
            return false
        }
        
        if layer.pdfPage == nil && pdfPage == nil {
            return true
        }
        
        if layer.pdfPage != nil && pdfPage != nil {
            return true
        } else {
            return false
        }
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
    
    override func undoAction(oldObject: AnyObject?) {
        if let image = oldObject as? UIImage {
            self.image = image
        } else {
            super.undoAction(oldObject)
        }
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        guard let layer = object as? DocumentDrawLayer else {
            return false
        }
        
        if !super.isEqual(object) {
            return false
        }
        
        guard layer.index == index else {
            return false
        }
        
        guard layer.image == image else {
            return false
        }
        
        return true
    }
    
}

