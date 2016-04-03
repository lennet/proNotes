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
    
    private var sketchImage: UIImage?
    
    private var undoImage: UIImage?
    
    weak var sketchLayer: SketchLayer? {
        didSet {
            image = sketchLayer?.image
            sketchImage = image
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
        sketchImage = image
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
            sketchImage?.drawInRect(bounds)
            newStrokeImage.drawInRect(bounds, blendMode: .Normal, alpha: strokeBuffer?.alpha ?? 1)
            sketchImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        strokeBuffer?.reset()
        updateImage(sketchImage)
    }

    func updateImage(image: UIImage?) {

        if sketchLayer != nil && sketchLayer?.docPage != nil {
            DocumentInstance.sharedInstance.registerUndoAction(undoImage, pageIndex: sketchLayer!.docPage.index, layerIndex: sketchLayer!.index)
        }

        self.image = image
        sketchImage = image
        saveChanges()
    }

    private func eraseForTouches(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        sketchImage?.drawInRect(bounds)
        let touches = event?.coalescedTouchesForTouch(touch) ?? [touch]
        for touch in touches {
            eraseStroke(context, touch: touch)
        }
        sketchImage = UIGraphicsGetImageFromCurrentImageContext()
        for touch in event?.predictedTouchesForTouch(touch) ?? [UITouch]() {
            eraseStroke(context, touch: touch)
        }
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

    private func eraseStroke(context: CGContext?, touch: UITouch) {
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
            if sketchLayer != nil && sketchLayer?.docPage != nil {
                DocumentInstance.sharedInstance.registerUndoAction(image, pageIndex: sketchLayer!.docPage.index, layerIndex: sketchLayer!.index)
            }
            updateImage(oldImage)
        }
    }

    func setSelected() {
        SettingsViewController.sharedInstance?.currentSettingsType = .Sketch
        SketchSettingsViewController.delegate = self
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
        sketchImage = nil
        strokeBuffer?.reset()
    }

}
