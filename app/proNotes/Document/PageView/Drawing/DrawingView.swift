//
//  DrawingView.swift
//  proNotes
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class DrawingView: UIImageView, PageSubView, DrawingSettingsDelegate {
    
    init(drawLayer: DocumentDrawLayer, frame: CGRect) {
        self.drawLayer = drawLayer
        super.init(frame: frame)
        image = self.drawLayer?.image
        drawingImage = image
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    weak var drawLayer: DocumentDrawLayer? {
        didSet {
            image = drawLayer?.image
            drawingImage = image
        }
    }

    var penObject: Pen = Pencil()

    private let forceSensitivity: CGFloat = 4.0

    private let minPenAngle: CGFloat = CGFloat(35).toRadians()

    private var lineWidth : CGFloat = 1
    
    private var minLineWidth: CGFloat {
        get {
            return lineWidth * 0.1
        }
    }

    private var oldTouchForce: CGFloat = 0

    private var drawingImage: UIImage?

    private var undoImage: UIImage?


    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        undoImage = image
        handleTouches(touches, withEvent: event)
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouches(touches, withEvent: event)
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
        updateImage(drawingImage)
    }

    func updateImage(image: UIImage?) {

        if drawLayer != nil && drawLayer?.docPage != nil {
            DocumentInstance.sharedInstance.registerUndoAction(undoImage, pageIndex: drawLayer!.docPage.index, layerIndex: drawLayer!.index)
        }

        self.image = image
        drawingImage = image
        saveChanges()
    }

    private func handleTouches(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()

        drawingImage?.drawInRect(bounds)

        let touches = event?.coalescedTouchesForTouch(touch) ?? [touch]

        for touch in touches {
            drawStroke(context, touch: touch)
        }

        drawingImage = UIGraphicsGetImageFromCurrentImageContext()

        for touch in event?.predictedTouchesForTouch(touch) ?? [UITouch]() {
            drawStroke(context, touch: touch)
        }

        self.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

    private func drawStroke(context: CGContext?, touch: UITouch) {
        let previousLocation = touch.previousLocationInView(self)
        let location = touch.locationInView(self)
        
        penObject.color.setStroke()

        if penObject.isEraser {
            CGContextSetBlendMode(context, .Clear)
        }

        CGContextSetLineWidth(context, getLineWidth(context, touch: touch))
        CGContextSetLineCap(context, .Round)
        CGContextMoveToPoint(context, previousLocation.x, previousLocation.y)
        CGContextAddLineToPoint(context, location.x, location.y)
        CGContextStrokePath(context)
    }

    private func getLineWidth(context: CGContext?, touch: UITouch) -> CGFloat {
        if !penObject.dynamicLineWidth {
            return lineWidth
        }

        if touch.altitudeAngle < minPenAngle && touch.type == .Stylus && penObject.enabledShading {
            return lineWidthForShading(context, touch: touch)
        } else {
            return lineWidthForDrawing(context, touch: touch)
        }

    }

    private func lineWidthForShading(context: CGContext?, touch: UITouch) -> CGFloat {

        let previousLocation = touch.previousLocationInView(self)
        let location = touch.locationInView(self)

        let azimuthVector = touch.azimuthUnitVectorInView(self)

        let directionVector = CGVector(dx: location.x - previousLocation.x, dy: location.y - previousLocation.y)

        var angle = CGVector.angleBetween(azimuthVector, secondVector: directionVector)

        if angle > CGFloat(180).toRadians() {
            angle = CGFloat(360).toRadians() - angle
        }
        if angle > CGFloat(90).toRadians() {
            angle = CGFloat(180).toRadians() - angle
        }

        let normalizedAngle = angle.normalized(0, max: CGFloat(90).toRadians())

        let maxLineWidth: CGFloat = penObject.lineWidth * 4
        var lineWidth: CGFloat
        lineWidth = maxLineWidth * normalizedAngle

        let minAltitudeAngle: CGFloat = 0.25

        let altitudeAngle = touch.altitudeAngle < minAltitudeAngle
                ? minAltitudeAngle : touch.altitudeAngle

        let normalizedAltitude = 1 - altitudeAngle.normalized(minAltitudeAngle, max: minPenAngle)

        lineWidth = lineWidth * normalizedAltitude + minLineWidth

        return lineWidth
    }

    private func lineWidthForDrawing(context: CGContext?, touch: UITouch) -> CGFloat {

        var result = lineWidth
        if penObject.dynamicLineWidth {
            if forceTouchAvailable || touch.type == .Stylus {
                if touch.force > 0 {
                    result = touch.force.normalized(0, max: touch.maximumPossibleForce) * lineWidth * 2
                }
            } else {
                result = touch.majorRadius / 2
            }
        }

        return result
    }

    func removeLayer() {
        clearDrawing()
        removeFromSuperview()
        drawLayer?.removeFromPage()
        drawLayer = nil
        SettingsViewController.sharedInstance?.currentSettingsType = .PageInfo
    }

    // MARK: - PageSubViewProtocol

    func undoAction(oldObject: AnyObject?) {
        if let oldImage = oldObject as? UIImage {
            if drawLayer != nil && drawLayer?.docPage != nil {
                DocumentInstance.sharedInstance.registerUndoAction(image, pageIndex: drawLayer!.docPage.index, layerIndex: drawLayer!.index)
            }
            updateImage(oldImage)
        }
    }

    func setSelected() {
        SettingsViewController.sharedInstance?.currentSettingsType = .Drawing
        DrawingSettingsViewController.delegate = self
    }

    func saveChanges() {
        if image != nil && drawLayer != nil {
            drawLayer?.image = image
        }
        if let pageIndex = drawLayer?.docPage.index {
            DocumentInstance.sharedInstance.didUpdatePage(pageIndex)
        }
    }

    // MARK: - DrawingSettingsDelegate

    func didSelectColor(color: UIColor) {
        penObject.color = color
    }

    func didSelectDrawingObject(object: Pen) {
        penObject = object
        lineWidth = penObject.lineWidth
    }
    
    func didSelectLineWidth(width: CGFloat) {
        lineWidth = width
    }

    func clearDrawing() {
        self.image = nil
        self.drawingImage = nil
    }

}
