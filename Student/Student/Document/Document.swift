//
//  Document.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

enum DocumentLayerType {
    case PDF
    case Drawing
    case Image
}


class DocumentLayer {
    var index: Int
    var type: DocumentLayerType
    var docPage: DocumentPage
    
    init(index: Int, type: DocumentLayerType, docPage: DocumentPage){
        self.index = index
        self.type = type
        self.docPage = docPage
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
}

class ImageLayer: MovableLayer {
    var image: UIImage
    
    init(index: Int, docPage: DocumentPage, origin: CGPoint, size: CGSize?, image: UIImage) {
        self.image = image
        super.init(index: index, type: .Image, docPage: docPage, origin: origin, size: size ?? image.size)
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
}

class DocumentPage {
    var layer = [DocumentLayer]()
    var index = 0

    init(index: Int){
        addDrawingLayer(nil)
        self.index = index
    }
    
    init(PDF: CGPDFPage, index: Int){
        addPDFLayer(PDF)
        addDrawingLayer(nil)
        self.index = index
    }
    
    func addDrawingLayer(image: UIImage?) {
        let drawLayer = DocumentDrawLayer(index: layer.count,image: image, docPage: self)
        layer.append(drawLayer)
    }
    
    func addPDFLayer(PDF: CGPDFPage) {
        let pdfLayer = DocumentPDFLayer(index: layer.count, page: PDF, docPage: self)
        layer.append(pdfLayer)
    }
    
    func addImageLayer(image: UIImage){
        let imageLayer = ImageLayer(index: layer.count, docPage: self, origin: CGPointZero, size: image.size, image: image)
        layer.append(imageLayer)
    }
}

class Document {

    var name = ""
    var pages = [DocumentPage]()
    
    func addPDF(url: NSURL){
        let pdf = CGPDFDocumentCreateWithURL(url as CFURLRef)
        for var i = 1; i <= CGPDFDocumentGetNumberOfPages(pdf); i++ {
            if let page = CGPDFDocumentGetPage(pdf, i) {
                let page = DocumentPage(PDF: page, index: pages.count)
                pages.append(page)
            }
        }
    }
    
    func addEmptyPage() {
        let page = DocumentPage(index: pages.count)
        pages.append(page)
    }
    
    func addImageToPage(image: UIImage, pageIndex: Int){
        if pages.count > pageIndex{
            pages[pageIndex].addImageLayer(image)
            DocumentSynchronizer.sharedInstance.document = self
        }
    }
    
    func getNumberOfPages() -> Int {
        return pages.count;
    }
    
}
