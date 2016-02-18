//
//  DocumentPage.swift
//  proNotes
//
//  Created by Leo Thomas on 13/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class DocumentPage: NSObject, NSCoding {

    private final let indexKey = "index"
    private final let sizeKey = "size"
    private final let layersKey = "layers"
    
    var layers: [DocumentLayer]
    var index = 0
    var size = CGSize.dinA4()

    init(index: Int) {
        layers = [DocumentLayer]()
        super.init()
        self.index = index
    }

    init(pdfData: NSData, index: Int) {
        layers = [DocumentLayer]()
        super.init()
        self.index = index
        addPDFLayer(pdfData)
    }

    required init(coder aDecoder: NSCoder) {
        size = aDecoder.decodeCGSizeForKey(sizeKey)
        index = aDecoder.decodeIntegerForKey(indexKey)
        layers = aDecoder.decodeObjectForKey(layersKey) as? [DocumentLayer] ?? [DocumentLayer]()
        super.init()
        for layer in layers {
            layer.docPage = self
        }
    }

    subscript(layerIndex: Int) -> DocumentLayer? {
        get {
            if layerIndex < layers.count {
                return layers[layerIndex]
            }
            return nil
        }
    }

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

    func addPDFLayer(pdfData: NSData) {
        let pdfLayer = DocumentPDFLayer(index: layers.count, pdfData: pdfData, docPage: self)
        layers.append(pdfLayer)
    }

    func addImageLayer(image: UIImage) -> ImageLayer {
        let layerSize = image.sizeToFit(size)
        let imageLayer = ImageLayer(index: layers.count, docPage: self, origin: CGPointZero, size: layerSize, image: image)
        layers.append(imageLayer)
        return imageLayer
    }

    func addTextLayer(text: String) -> TextLayer {
        let textLayer = TextLayer(index: layers.count, docPage: self, origin: CGPointZero, size: CGSize(width: 200, height: 200), text: "")
        layers.append(textLayer)
        return textLayer
    }

    func changeLayerVisibility(hidden: Bool, layer: DocumentLayer) {
        if layer.index < layers.count {
            layer.hidden = hidden
            layers[layer.index] = layer
        }
    }

    func removeLayer(layer: DocumentLayer) {
        if layer.index < layers.count {
            if layers[layer.index] == layer {
                layers.removeAtIndex(layer.index)
                updateLayerIndex()
            }
        }
    }

    func swapLayerPositions(firstIndex: Int, secondIndex: Int) {
        if firstIndex != secondIndex && firstIndex >= 0 && secondIndex >= 0 && firstIndex < layers.count && secondIndex < layers.count {
            let tmp = firstIndex
            layers[firstIndex].index = secondIndex
            layers[secondIndex].index = tmp
            swap(&layers[firstIndex], &layers[secondIndex])
        }
    }

    func updateLayerIndex() {
        for (index, currentLayer) in layers.enumerate() {
            currentLayer.index = index
        }
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        guard let page = object as? DocumentPage else {
            return false
        }
        
        guard page.index == self.index else {
            return false
        }
        
        guard page.layers.count == layers.count else {
            return false
        }

        for i in 0..<layers.count {
            if self[i] != page[i] {
                return false
            }
        }
        
        return true
    }

}
