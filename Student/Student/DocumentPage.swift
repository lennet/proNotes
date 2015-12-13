//
//  DocumentPage.swift
//  Student
//
//  Created by Leo Thomas on 13/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

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
    
    init(fileWrapper: NSFileWrapper, index: Int) {
        self.index = index
        if let contents = fileWrapper.fileWrappers {

            for wrapper in contents {
                if let innerWrappers = wrapper.1.fileWrappers{
                    var propertiesWrapper: NSFileWrapper?
                    var contentWrapper: NSFileWrapper?
                    for innerWrapper in innerWrappers {
                        if innerWrapper.0 == "properties" {
                            propertiesWrapper = innerWrapper.1
                        } else if innerWrapper.0 == "content" {
                            contentWrapper = innerWrapper.1

                        }
                    }
                    if propertiesWrapper != nil {
                        if let propertiesData = propertiesWrapper!.regularFileContents {
                            let properties = NSKeyedUnarchiver.unarchiveObjectWithData(propertiesData) as? [String: AnyObject]
                            
                            switch DocumentLayerType(rawValue: properties!["type"] as! Int)!{
                            case .Drawing:
                                let layer = DocumentDrawLayer(docPage: self, properties: properties!)
                                if contentWrapper != nil {
                                    if let contentData = contentWrapper!.regularFileContents {
                                        layer.handleContentData(contentData)
                                    }

                                }
                                layers.append(layer)
                                break
                            case .Image:
                                let layer = ImageLayer(docPage: self, properties: properties!, type: .Image)
                                if contentWrapper != nil {
                                    if let contentData = contentWrapper!.regularFileContents {
                                        layer.handleContentData(contentData)
                                    }
                                }
                                layers.append(layer)
                            default:
                                break
                            }
                        }
                    }
                }
            }
        }
        updateLayerIndex()
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
        var fileWrappers: [String: NSFileWrapper] = [String: NSFileWrapper]()
        
        for layer in layers {
            fileWrappers[String(layer.index)] = layer.getFileWrapper()
        }
        let contents = NSFileWrapper(directoryWithFileWrappers: fileWrappers)
        return contents
    }
    
}
