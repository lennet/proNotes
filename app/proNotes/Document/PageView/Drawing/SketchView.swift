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


    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        undoImage = image
        penObject.isEraser ? eraseForTouches(touches, withEvent: event) : strokeBuffer?.handleTouches(touches, withEvent: event)
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        penObject.isEraser ? eraseForTouches(touches, withEvent: event) : strokeBuffer?.handleTouches(touches, withEvent: event)
    }

    override func touchesEnded(touches: Set<UITouch>,
                               withEvent event: UIEvent?) {
        handleTouchesEnded()
    }

    override func touchesCancelled(touches: Set<UITouch>?,
                                   withEvent event: UIEvent?) {
        handleTouchesEnded()
    }

    func handleTouchesEnded() {
        // merge current Stroke
        if let newStrokeImage = strokeBuffer?.image {
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
            image?.drawInRect(bounds)
            newStrokeImage.drawInRect(bounds, blendMode: .Normal, alpha: strokeBuffer?.alpha ?? 1)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        strokeBuffer?.reset()
        updateImage(image)
    }

    func updateImage(image: UIImage?) {
        self.image = image
        if sketchLayer != nil && sketchLayer?.docPage != nil {
            DocumentInstance.sharedInstance.registerUndoAction(undoImage, pageIndex: sketchLayer!.docPage.index, layerIndex: sketchLayer!.index)
            undoImage = nil
        }
        saveChanges()
    }

    private func eraseForTouches(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        image?.drawInRect(bounds)
        for touch in event?.coalescedTouchesForTouch(touch) ?? [touch] {
            drawEraseStroke(context, touch: touch)
        }
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

    private func drawEraseStroke(context: CGContext?, touch: UITouch) {
        let previousLocation = touch.previousLocationInView(self)
        let location = touch.locationInView(self)
        CGContextSetBlendMode(context, .Clear)
        CGContextSetLineWidth(context, penObject.lineWidth)
        CGContextSetLineCap(context, .Round)
        CGContextMoveToPoint(context, previousLocation.x, previousLocation.y)
        CGContextAddLineToPoint(context, location.x, location.y)
        CGContextStrokePath(context)
    }

    func removeLayer() {
        clearSketch()
        removeFromSuperview()
        sketchLayer?.removeFromPage()
        sketchLayer = nil
        SettingsViewController.sharedInstance?.currentSettingsType = .PageInfo
    }

    // MARK: - PageSubViewProtocol

    func undoAction(oldObject: AnyObject?) {
        if let oldImage = oldObject as? UIImage {
            updateImage(oldImage)
        }
    }

    func setSelected() {
        SettingsViewController.sharedInstance?.currentSettingsType = .Sketch
        SketchSettingsViewController.delegate = self
        setUpStrokeBuffer()
    }
    
    func setDeselected() {
        strokeBuffer?.removeFromSuperview()
        strokeBuffer = nil
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

    func didSelectColor(color: UIColor) {
        penObject.color = color
    }

    func didSelectDrawingObject(object: Pen) {
        penObject = object
    }
    
    func didSelectLineWidth(width: CGFloat) {
        penObject.lineWidth = width
    }

    func clearSketch() {
        image = nil
        strokeBuffer?.reset()
    }

}
