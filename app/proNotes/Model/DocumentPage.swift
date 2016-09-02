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
    
    private var _previewImage: UIImage?
    var previewImage: UIImage? {
        get {
            if _previewImage == nil {
                let pageView = PageView(page: self, renderMode: true)
                _previewImage = pageView.toThumbImage()
            }
            return _previewImage
        }
    }

    init(index: Int) {
        layers = [DocumentLayer]()
        super.init()
        self.index = index
    }

    init(pdfData: Data, index: Int, pdfSize: CGSize) {
        layers = [DocumentLayer]()
        self.size = pdfSize
        self.index = index
        super.init()
        addPDFLayer(pdfData)
    }

    required init(coder aDecoder: NSCoder) {
        size = aDecoder.decodeCGSize(forKey: sizeKey)
        index = aDecoder.decodeInteger(forKey: indexKey)
        layers = aDecoder.decodeObject(forKey: layersKey) as? [DocumentLayer] ?? [DocumentLayer]()
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

    func encode(with aCoder: NSCoder) {
        aCoder.encode(index, forKey: indexKey)
        aCoder.encode(layers, forKey: layersKey)
        aCoder.encode(size, forKey: sizeKey)
    }
    
    // MARK: - Preview Image Handling
    
    func removePreviewImage() {
        _previewImage = nil
    }
    
    func previewImageAvailable() -> Bool {
        return _previewImage == nil 
    }
    
    // MARK: - Add Layer

    @discardableResult
    func addSketchLayer(_ image: UIImage?) -> SketchLayer {
        let sketchLayer = SketchLayer(index: layers.count, image: image, docPage: self)
        layers.append(sketchLayer)
        return sketchLayer
    }

    func addPDFLayer(_ pdfData: Data) {
        let pdfLayer = PDFLayer(index: layers.count, pdfData: pdfData, docPage: self)
        layers.append(pdfLayer)
    }
    
    @discardableResult
    func addImageLayer(_ image: UIImage) -> ImageLayer {
        let layerSize = image.size.sizeToFit(size)
        let imageLayer = ImageLayer(index: layers.count, docPage: self, origin: CGPoint.zero, size: layerSize, image: image)
        layers.append(imageLayer)
        return imageLayer
    }

    @discardableResult
    func addTextLayer(_ text: String) -> TextLayer {
        let textLayer = TextLayer(index: layers.count, docPage: self, origin: CGPoint.zero, size: CGSize(width: 200, height: 30), text: "")
        layers.append(textLayer)
        return textLayer
    }
    
    // MARK: - LayerManipulation

    func changeLayerVisibility(_ hidden: Bool, layer: DocumentLayer) {
        if layer.index < layers.count {
            layer.hidden = hidden
            layers[layer.index] = layer
        }
    }

    func removeLayer(_ layer: DocumentLayer) {
        if layer.index < layers.count {
            if layers[layer.index] == layer {
                layers.remove(at: layer.index)
                updateLayerIndex()
            }
        }
    }

    func swapLayerPositions(_ firstIndex: Int, secondIndex: Int) {
        if firstIndex != secondIndex && firstIndex >= 0 && secondIndex >= 0 && firstIndex < layers.count && secondIndex < layers.count {
            let tmp = firstIndex
            layers[firstIndex].index = secondIndex
            layers[secondIndex].index = tmp
            swap(&layers[firstIndex], &layers[secondIndex])
        }
    }

    func updateLayerIndex() {
        for (index, currentLayer) in layers.enumerated() {
            currentLayer.index = index
        }
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let page = object as? DocumentPage else {
            return false
        }

        guard page.index == self.index else {
            return false
        }

        guard page.layers.count == layers.count else {
            return false
        }

        for i in 0 ..< layers.count {
            if self[i] != page[i] {
                return false
            }
        }

        return true
    }

}
