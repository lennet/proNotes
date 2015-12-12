//
//  Document.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
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
    
    func removeFromPage() {
        self.docPage.removeLayer(self)
    }
    
    func getFileWrapper() -> NSFileWrapper {
        let properties = getPropertiesDict()
        let data = NSKeyedArchiver.archivedDataWithRootObject(properties)
        let fileWrapper = NSFileWrapper(regularFileWithContents: data)
        return fileWrapper
    }
    
    func getPropertiesDict() -> [String: AnyObject]{
        return ["index": index,
                "type": type.rawValue]
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

class TextLayer: MovableLayer {
    var text: String
    
    init(index: Int, docPage: DocumentPage, origin: CGPoint, size: CGSize, text: String) {
        self.text = text
        super.init(index: index, type: .Text, docPage: docPage, origin: origin, size: size)
    }
}

class PlotLayer: MovableLayer {
    init(index: Int, docPage: DocumentPage, origin: CGPoint, size: CGSize) {
        super.init(index: index, type: .Plot, docPage: docPage, origin: origin, size: size)
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
    var layers = [DocumentLayer]()
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
        let drawLayer = DocumentDrawLayer(index: layers.count,image: image, docPage: self)
        layers.append(drawLayer)
    }
    
    func addPDFLayer(PDF: CGPDFPage) {
        let pdfLayer = DocumentPDFLayer(index: layers.count, page: PDF, docPage: self)
        layers.append(pdfLayer)
    }
    
    func addImageLayer(image: UIImage) {
        let imageLayer = ImageLayer(index: layers.count, docPage: self, origin: CGPointZero, size: image.size, image: image)
        layers.append(imageLayer)
    }
    
    func addTextLayer(text: String) {
        let textLayer = TextLayer(index: layers.count, docPage: self, origin: CGPointZero, size: CGSize(width: 200, height: 200), text: "")
        layers.append(textLayer)
    }
    
    func addPlotLayer() {
        let plotLayer = PlotLayer(index: layers.count, docPage: self , origin: CGPointZero, size: CGSize(width: 500, height: 300))
        layers.append(plotLayer)
    }
    
    func changeLayerVisibility(hidden: Bool, layer: DocumentLayer){
        layer.hidden = hidden
        self.layers[layer.index] = layer
        DocumentSynchronizer.sharedInstance.updatePage(self, forceReload: true)
    }
    
    func removeLayer(layer: DocumentLayer){
        self.layers.removeAtIndex(layer.index)
        updateLayerIndex()
        DocumentSynchronizer.sharedInstance.updatePage(self, forceReload: false)
    }
    
    func swapLayerPositions(firstIndex: Int, secondIndex: Int){
        if firstIndex != secondIndex && firstIndex >= 0 && secondIndex >= 0 && firstIndex < self.layers.count && secondIndex < self.layers.count {
            swap(&self.layers[firstIndex], &self.layers[secondIndex])
            updateLayerIndex()
            DocumentSynchronizer.sharedInstance.updatePage(self, forceReload: true)
        }
    }
    
    func updateLayerIndex() {
        for (index, currentLayer) in layers.enumerate() {
            currentLayer.index = index
        }
    }
    
    func getFileWrapper() -> NSFileWrapper {
        let contents = NSFileWrapper()
        for layer in layers {
            contents.addFileWrapper(layer.getFileWrapper())
        }
        return contents
    }
}

class Document: UIDocument {

    var name = ""
    var pages = [DocumentPage]()
    
    override func contentsForType(typeName: String) throws -> AnyObject {
        let contents = NSFileWrapper()
        for page in pages {
            contents.addFileWrapper(page.getFileWrapper())
        }
        return contents
    }
    
    override func loadFromContents(contents: AnyObject, ofType typeName: String?) throws {
        // todo
    }
    
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
    
    func addTextToPage(text: String, pageIndex: Int) {
        if pages.count > pageIndex{
            pages[pageIndex].addTextLayer(text)
            DocumentSynchronizer.sharedInstance.document = self
        }
    }
    
    func addPlotToPage(pageIndex: Int) {
        if pages.count > pageIndex{
            pages[pageIndex].addPlotLayer()
            DocumentSynchronizer.sharedInstance.document = self
        }
    }
    
    func getNumberOfPages() -> Int {
        return pages.count;
    }
    
}
