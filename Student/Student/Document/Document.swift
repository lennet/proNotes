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
}


class DocumentLayer {
    var index: Int
    var type: DocumentLayerType
    
    init(index: Int, type: DocumentLayerType){
        self.index = index
        self.type = type
    }
    
}

class DocumentPDFLayer: DocumentLayer {
    var page: CGPDFPage
    init(index: Int, page: CGPDFPage){
        self.page = page
        super.init(index: index, type: .PDF)
    }
}

class DocumentDrawLayer: DocumentLayer {
    var image: UIImage?
    init(index: Int, image: UIImage?){
        super.init(index: index, type: .Drawing)
    }
}

class DocumentPage {
    var layer = [DocumentLayer]()

    init(){
        addDrawingLayer(nil)
    }
    
    init(PDF: CGPDFPage){
        addPDFLayer(PDF)
        addDrawingLayer(nil)
    }
    
    func addDrawingLayer(image: UIImage?) {
        let drawLayer = DocumentDrawLayer(index: layer.count,image: image)
        layer.append(drawLayer)
    }
    
    func addPDFLayer(PDF: CGPDFPage) {
        let pdfLayer = DocumentPDFLayer(index: layer.count, page: PDF)
        layer.append(pdfLayer)
    }
}

class Document {

    var name = ""
    var pages = [DocumentPage]()
    
    func addPDF(url: NSURL){
        let pdf = CGPDFDocumentCreateWithURL(url as CFURLRef)
        for var i = 1; i <= CGPDFDocumentGetNumberOfPages(pdf); i++ {
            if let page = CGPDFDocumentGetPage(pdf, i) {
                let page = DocumentPage(PDF: page)
                pages.append(page)
            }
        }
    }
    
    func addEmptyPage() {
        let page = DocumentPage()
        pages.append(page)
    }
    
    func getNumberOfPages() -> Int {
        return pages.count;
    }
    
}
