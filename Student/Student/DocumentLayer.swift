//
//  DocumentLayer.swift
//  Student
//
//  Created by Leo Thomas on 13/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

enum DocumentLayerType: Int {
    case PDF = 1
    case Drawing = 2
    case Image = 3
    case Text = 4
    case Plot = 5
}


class DocumentLayer {
    var index: Int
    var type: DocumentLayerType
    var docPage: DocumentPage
    var hidden = false
    
    init(index: Int, type: DocumentLayerType, docPage: DocumentPage){
        self.index = index
        self.type = type
        self.docPage = docPage
    }
    
    init(fileWrapper: NSFileWrapper, index: Int, docPage: DocumentPage)  {
        self.index = index
        self.type = .Drawing
        self.docPage = docPage
    }
    
    init(page: DocumentPage, properties: [String: AnyObject], type: DocumentLayerType){
        self.docPage = page
        self.index = properties["index"] as? Int ?? page.layers.count
        self.hidden = properties["hidden"] as? Bool ?? false
        self.type = type
    }
    
    func removeFromPage() {
        self.docPage.removeLayer(self, forceReload: false)
    }
    
    func getFileWrapper() -> NSFileWrapper {
        let properties = getPropertiesDict()
        let data = NSKeyedArchiver.archivedDataWithRootObject(properties)
        let propertiesFileWrapper = NSFileWrapper(regularFileWithContents: data)
        var fileWrappers = ["properties": propertiesFileWrapper]
        
        if let contentFileWrapper = getContentFileWrapper() {
            fileWrappers["content"] = contentFileWrapper
        }
        
        return NSFileWrapper(directoryWithFileWrappers: fileWrappers)
    }
    
    func getPropertiesDict() -> [String: AnyObject]{
        return ["index": index,
            "type": type.rawValue,
            "hidden": hidden]
    }
    
    func getContentFileWrapper() -> NSFileWrapper? {
        return nil
    }
    
    func handleContentData(data: NSData){
        // Empty base implementation
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
    
    init(docPage: DocumentPage, properties: [String: AnyObject], type: DocumentLayerType){
       
        if let originValue = properties["origin"] as? NSValue {
            origin =  originValue.CGPointValue()
        } else {
            origin = CGPointZero
        }
        
        if let sizeValue = properties["size"] as? NSValue {
            size =  sizeValue.CGSizeValue()
        } else {
            size = CGSizeZero
        }

        super.init(page: docPage, properties: properties, type: type)
    }
    
    override func getPropertiesDict() -> [String : AnyObject] {
        var properties = super.getPropertiesDict()
        properties["origin"] = NSValue(CGPoint: origin)
        properties["size"] = NSValue(CGSize: size)
        return properties
    }
}

class ImageLayer: MovableLayer {
    var image: UIImage
    
    init(index: Int, docPage: DocumentPage, origin: CGPoint, size: CGSize?, image: UIImage) {
        self.image = image
        super.init(index: index, type: .Image, docPage: docPage, origin: origin, size: size ?? image.size)
    }
    
    init(docPage: DocumentPage, properties: [String: AnyObject]){
        self.image = UIImage()
        super.init(docPage: docPage, properties: properties, type: .Image)
    }
    
    override func getContentFileWrapper() -> NSFileWrapper? {
        if let imageData = UIImagePNGRepresentation(image) {
            return NSFileWrapper(regularFileWithContents: imageData)
        }
        return nil
    }
    
    override func handleContentData(data: NSData) {
        if let image = UIImage(data: data){
            self.image = image
        }
    }
}

class TextLayer: MovableLayer {
    var text: String
    
    init(index: Int, docPage: DocumentPage, origin: CGPoint, size: CGSize, text: String) {
        self.text = text
        super.init(index: index, type: .Text, docPage: docPage, origin: origin, size: size)
    }
    
    init(docPage: DocumentPage, properties: [String: AnyObject]){
        if let text = properties["text"] as? String {
            self.text = text
        } else {
            text = ""
        }
        super.init(docPage: docPage, properties: properties, type: .Text)
    }
    
    override func getPropertiesDict() -> [String : AnyObject] {
        var properties = super.getPropertiesDict()
        properties["text"] = text
        return properties
    }
}

class PlotLayer: MovableLayer {
    var function: String
    init(index: Int, docPage: DocumentPage, origin: CGPoint, size: CGSize) {
        function = "cos($x)"
        super.init(index: index, type: .Plot, docPage: docPage, origin: origin, size: size)
    }
    
    init(docPage: DocumentPage, properties: [String: AnyObject]){
        if let function = properties["function"] as? String {
            self.function = function
        } else {
            self.function = "cos($x)"
        }
        super.init(docPage: docPage, properties: properties, type: .Plot)
    }
    
    override func getPropertiesDict() -> [String : AnyObject] {
        var properties = super.getPropertiesDict()
        properties["function"] = function
        return properties
    }

}

class DocumentPDFLayer: DocumentLayer {
    var page: CGPDFPage
    init(index: Int, page: CGPDFPage, docPage: DocumentPage){
        self.page = page
        super.init(index: index, type: .PDF, docPage: docPage)
    }
}

class DocumentDrawLayer: DocumentLayer {
    var image: UIImage?
    init(index: Int, image: UIImage?, docPage: DocumentPage){
        super.init(index: index, type: .Drawing, docPage: docPage)
    }
    
    init(docPage: DocumentPage, properties: [String: AnyObject]){
        super.init(page: docPage, properties: properties, type: .Drawing)
    }
    
    override func getContentFileWrapper() -> NSFileWrapper? {
        if image != nil {
            if let imageData = UIImagePNGRepresentation(image!) {
                return NSFileWrapper(regularFileWithContents: imageData)
            }
        }
        return nil
    }
    
    override func handleContentData(data: NSData) {
        if let image = UIImage(data: data){
            self.image = image  
        }
    }
}

