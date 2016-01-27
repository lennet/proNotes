//
//  DocumentPage.swift
//  Student
//
//  Created by Leo Thomas on 13/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class DocumentPage: NSObject, NSCoding {
    var layers = [DocumentLayer]()
    var index = 0
    var size = CGSize.dinA4()

    init(index: Int) {
        self.index = index
    }

    init(PDF: CGPDFPage, index: Int) {
        super.init()
        self.index = index
        addPDFLayer(PDF)
    }

    required init(coder aDecoder: NSCoder) {
        size = aDecoder.decodeCGSizeForKey(sizeKey)
        index = aDecoder.decodeIntegerForKey(indexKey)
        layers = aDecoder.decodeObjectForKey(layersKey) as! [DocumentLayer]
        super.init()
        for layer in layers {
            layer.docPage = self
        }
    }

    private final let indexKey = "index"
    private final let sizeKey = "size"
    private final let layersKey = "layers"

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(index, forKey: indexKey)
        aCoder.encodeObject(layers, forKey: layersKey)
        aCoder.encodeCGSize(size, forKey: sizeKey)
    }

    func addDrawingLayer(image: UIImage?) -> DocumentDrawLayer {
        let drawLayer = DocumentDrawLayer(index: layers.count, image: image, docPage: self)
        layers.append(drawLayer)
        return drawLayer
    }

    func addPDFLayer(PDF: CGPDFPage) {
        let pdfLayer = DocumentPDFLayer(index: layers.count, page: PDF, docPage: self)
        layers.append(pdfLayer)
        DocumentSynchronizer.sharedInstance.updatePage(self, forceReload: false)
    }

    func addImageLayer(image: UIImage) {
        let layerSize = image.sizeToFit(size)
        let imageLayer = ImageLayer(index: layers.count, docPage: self, origin: CGPointZero, size: layerSize, image: image)
        layers.append(imageLayer)
        DocumentSynchronizer.sharedInstance.updatePage(self, forceReload: false)
    }

    func addTextLayer(text: String) -> TextLayer {
        let textLayer = TextLayer(index: layers.count, docPage: self, origin: CGPointZero, size: CGSize(width: 200, height: 200), text: "")
        layers.append(textLayer)
        DocumentSynchronizer.sharedInstance.updatePage(self, forceReload: false)
        return textLayer
    }

    func addPlotLayer() {
        let plotLayer = PlotLayer(index: layers.count, docPage: self, origin: CGPointZero, size: CGSize(width: 500, height: 300))
        layers.append(plotLayer)
        DocumentSynchronizer.sharedInstance.updatePage(self, forceReload: false)
    }

    func changeLayerVisibility(hidden: Bool, layer: DocumentLayer) {
        if layer.index < layers.count {
            layer.hidden = hidden
            layers[layer.index] = layer
            DocumentSynchronizer.sharedInstance.updatePage(self, forceReload: false)
        }
    }

    func removeLayer(layer: DocumentLayer, forceReload: Bool) {
        if layer.index < layers.count {
            layers.removeAtIndex(layer.index)
            updateLayerIndex()
            DocumentSynchronizer.sharedInstance.updatePage(self, forceReload: forceReload)
        }
    }

    func swapLayerPositions(firstIndex: Int, secondIndex: Int) {
        if firstIndex != secondIndex && firstIndex >= 0 && secondIndex >= 0 && firstIndex < layers.count && secondIndex < layers.count {
            let tmp = firstIndex
            layers[firstIndex].index = secondIndex
            layers[secondIndex].index = tmp
            swap(&layers[firstIndex], &layers[secondIndex])
            DocumentSynchronizer.sharedInstance.updatePage(self, forceReload: false)
        }
    }

    func updateLayerIndex() {
        for (index, currentLayer) in layers.enumerate() {
            currentLayer.index = index
        }
    }

}
