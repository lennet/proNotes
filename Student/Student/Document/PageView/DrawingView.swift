//
//  DrawingView.swift
//  Student
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

    func commonInit() {
        userInteractionEnabled = false
        backgroundColor = UIColor.clearColor()
    }
    
    weak var drawLayer: DocumentDrawLayer? {
        didSet {
            image = drawLayer?.image
            drawingImage = image
        }
    }
    
    var drawingObject: DrawingObject = Pen()

    private let forceSensitivity: CGFloat = 4.0
    
    private let minPenAngle: CGFloat = CGFloat(35).toRadians()
    
    private var minLineWidth: CGFloat {
        get {
            return drawingObject.lineWidth * 0.1
        }
    }
    
    private var defaultAlphaValue: CGFloat {
        get {
            return drawingObject.defaultAlphaValue ?? 1
        }
    }
    
    private var oldAlphaValue: CGFloat = 0
    
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
    
    func undoImage(image: UIImage?) {
        undoManager?.prepareWithInvocationTarget(self).redoImage(self.image)
        updateImage(image)

    }

    func redoImage(image: UIImage?) {
        updateImage(image)
    }

    func updateImage(image: UIImage?) {
        undoManager?.prepareWithInvocationTarget(self).undoImage(undoImage)
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
    
    // With help of http://www.raywenderlich.com/121834/apple-pencil-tutorial
    
    private func drawStroke(context: CGContext?, touch: UITouch) {
        let previousLocation = touch.previousLocationInView(self)
        let location = touch.locationInView(self)
        
        let lineWidth = getLineWidth(context, touch: touch)
        let alpha = getAlpha(touch)
        print(alpha)
        
        drawingObject.color.setStroke()
        
        if drawingObject.color == UIColor.clearColor() {
            CGContextSetBlendMode(context, .Clear)
        }
        
        CGContextSetAlpha(context, alpha)
        
        CGContextSetLineWidth(context, lineWidth)
        CGContextSetLineCap(context, .Round)
        
        CGContextMoveToPoint(context, previousLocation.x, previousLocation.y)
        CGContextAddLineToPoint(context, location.x, location.y)
        
        CGContextStrokePath(context)

    }
    
    private func getLineWidth(context: CGContext?, touch: UITouch) -> CGFloat {
        if !drawingObject.dynamicLineWidth {
            return drawingObject.lineWidth
        }

        if touch.altitudeAngle < minPenAngle && touch.type == .Stylus && drawingObject.enabledShading {
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

        let maxLineWidth: CGFloat = drawingObject.lineWidth * 4
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
        
        var lineWidth = drawingObject.lineWidth
        if drawingObject.dynamicLineWidth {
            if forceTouchAvailable || touch.type == .Stylus {
                if touch.force > 0 {
                    lineWidth = touch.force * forceSensitivity
                }
            } else {
                lineWidth = touch.majorRadius / 2
            }
        }
        
        return lineWidth
    }
    
    private func getAlpha(touch: UITouch) -> CGFloat {
        var alpha = defaultAlphaValue
        if forceTouchAvailable || touch.type == .Stylus {

            alpha = (touch.force + defaultAlphaValue).normalized(defaultAlphaValue, max: touch.maximumPossibleForce)
            
            alpha = (alpha + oldAlphaValue) / 2
            
            oldAlphaValue = alpha
        }

        return alpha
    }

    func removeLayer() {
        clearDrawing()
        removeFromSuperview()
        drawLayer?.removeFromPage()
        drawLayer = nil
        SettingsViewController.sharedInstance?.currentSettingsType = .PageInfo
    }
    
    // MARK: - PageSubViewProtocol
    
    func setSelected() {
        SettingsViewController.sharedInstance?.currentSettingsType = .Drawing
        DrawingSettingsViewController.delegate = self
    }
    
    func saveChanges() {
        if image != nil && drawLayer != nil {
            drawLayer?.image = image
            DocumentSynchronizer.sharedInstance.updateDrawLayer(drawLayer!, forceReload: false)
        }
    }
    
    // MARK: - DrawingSettingsDelegate

    func didSelectColor(color: UIColor) {
        drawingObject.color = color
    }
    
    func didSelectDrawingObject(object: DrawingObject) {
        drawingObject = object
    }

    func clearDrawing() {
        self.image = nil
        self.drawingImage = nil
    }
    
}
