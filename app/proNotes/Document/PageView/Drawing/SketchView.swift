//
//  SketchView.swift
//  proNotes
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class SketchView: UIImageView, PageSubView, SketchSettingsDelegate {
    
    // MARK - Properties
    
    var penObject: Pen = Pencil() {
        didSet {
            strokeBuffer?.alpha = penObject.alphaValue
        }
    }
    
    private var undoImage: UIImage?
    
    weak var sketchLayer: SketchLayer? {
        didSet {
            image = sketchLayer?.image
        }
    }
    
    weak var strokeBuffer: StrokeBufferView?
    
    // MARK - Init
    
    init(sketchLayer: SketchLayer, frame: CGRect) {
        self.sketchLayer = sketchLayer
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        isUserInteractionEnabled = false 
        image = sketchLayer?.image
    }
    
    private func setUpStrokeBuffer() {
        guard self.strokeBuffer == nil else {
            return
        }
        let strokeBuffer = StrokeBufferView(frame: bounds)
        strokeBuffer.alpha = penObject.alphaValue
        addSubview(strokeBuffer)
        self.strokeBuffer = strokeBuffer
    }

    // MARK: - Touch Handling


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        undoImage = image
        if penObject.isEraser {
            eraseForTouches(touches, withEvent: event)
        } else {
            strokeBuffer?.handleTouches(touches, withEvent: event)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if penObject.isEraser {
            eraseForTouches(touches, withEvent: event)
        } else {
            strokeBuffer?.handleTouches(touches, withEvent: event)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        handleTouchesEnded()
    }

    override func touchesCancelled(_ touches: Set<UITouch>,
                                   with event: UIEvent?) {
        handleTouchesEnded()
    }

    func handleTouchesEnded() {
        // merge current Stroke
        if let newStrokeImage = strokeBuffer?.image {
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
            image?.draw(in: bounds)
            newStrokeImage.draw(in: bounds, blendMode: .normal, alpha: strokeBuffer?.alpha ?? 1)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        strokeBuffer?.reset()
        updateImage(image)
    }

    func updateImage(_ image: UIImage?) {
        self.image = image
        if sketchLayer != nil && sketchLayer?.docPage != nil {
            DocumentInstance.sharedInstance.registerUndoAction(undoImage, pageIndex: sketchLayer!.docPage.index, layerIndex: sketchLayer!.index)
            undoImage = nil
        }
        saveChanges()
    }

    private func eraseForTouches(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        image?.draw(in: bounds)
        for touch in event?.coalescedTouches(for: touch) ?? [touch] {
            drawEraseStroke(context, touch: touch)
        }
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

    private func drawEraseStroke(_ context: CGContext?, touch: UITouch) {
        let previousLocation = touch.previousLocation(in: self)
        let location = touch.location(in: self)
        context?.setBlendMode(.clear)
        context?.setLineWidth(penObject.lineWidth)
        context?.setLineCap(.round)
        context?.move(to: previousLocation)
        context?.addLine(to: location)
        context?.strokePath()
    }

    func removeLayer() {
        clearSketch()
        removeFromSuperview()
        sketchLayer?.removeFromPage()
        sketchLayer = nil
        SettingsViewController.sharedInstance?.currentType = .pageInfo
    }

    // MARK: - PageSubViewProtocol

    func undoAction(_ oldObject: Any?) {
        if let oldImage = oldObject as? UIImage {
            updateImage(oldImage)
        }
    }

    func setSelected() {
        SettingsViewController.sharedInstance?.currentType = .sketch
        SketchSettingsViewController.delegate = self
        setUpStrokeBuffer()
        isUserInteractionEnabled = true
    }
    
    func setDeselected() {
        strokeBuffer?.removeFromSuperview()
        strokeBuffer = nil
        isUserInteractionEnabled = false
    }

    func saveChanges() {
        if image != nil && sketchLayer != nil {
            sketchLayer?.image = image
        }
        if let pageIndex = sketchLayer?.docPage.index {
            DocumentInstance.sharedInstance.didUpdatePage(pageIndex)
        }
    }

    // MARK: - DrawingSettingsDelegate

    func didSelectColor(_ color: UIColor) {
        strokeBuffer?.strokeColor = color
    }

    func didSelectDrawingObject(_ object: Pen) {
        penObject = object
    }
    
    func didSelectLineWidth(_ width: CGFloat) {
        penObject.lineWidth = width
    }

    func clearSketch() {
        image = nil
        strokeBuffer?.reset()
    }

}
