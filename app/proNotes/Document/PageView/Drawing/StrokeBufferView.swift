//
//  StrokeBufferView.swift
//  proNotes
//
//  Created by Leo Thomas on 03/04/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class StrokeBufferView: UIImageView {

    // MARK: - Properties

    var currentPenObject: Pen {
        get {
            return (superview as? SketchView)?.penObject ?? Pencil()
        }
    }
    
    private var lineWidth: CGFloat {
        get {
            return currentPenObject.lineWidth ?? 1
        }
    }
    
    private var strokeColor: UIColor {
        get {
            return currentPenObject.color
        }
    }
    
    private final let minPenAngle: CGFloat = CGFloat(35).toRadians()
    private final let minLineWidth: CGFloat = 1
    private var oldLineWidth: CGFloat = 0
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = .clearColor()
    }
    
    func reset() {
        image = nil
    }
    
    // MARK Touch Handling
    
    func handleTouches(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        image?.drawInRect(bounds)
        for touch in event?.coalescedTouchesForTouch(touch) ?? [] {
            drawStroke(context, touch: touch)
        }
    
        image = UIGraphicsGetImageFromCurrentImageContext()
    
        UIGraphicsEndImageContext()
    }
    
    private func drawStroke(context: CGContext?, touch: UITouch) {
        let previousLocation = touch.previousLocationInView(self)
        let location = touch.locationInView(self)
        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor)
        CGContextSetLineWidth(context, getLineWidth(context, touch: touch))
        CGContextSetLineCap(context, .Round)
        CGContextSetLineJoin(context, .Round)
        CGContextMoveToPoint(context, previousLocation.x, previousLocation.y)
        CGContextAddLineToPoint(context, location.x, location.y)
        CGContextStrokePath(context)
    }
    
    private func getLineWidth(context: CGContext?, touch: UITouch) -> CGFloat {
        var newLineWidth: CGFloat = 0
        if touch.type == .Stylus  {
            newLineWidth = getLineWidthForStylus(touch)
        } else {
            newLineWidth = getLineWidthForDrawing(touch, defaultLineWidth: nil)
        }
        newLineWidth = (newLineWidth + oldLineWidth) / 2
        oldLineWidth = newLineWidth
        return newLineWidth
    }
    
    private func getLineWidthForStylus(touch: UITouch) -> CGFloat {
        
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
        
        let resultLineWidth = angle.normalized(0, max: CGFloat(90).toRadians()) * lineWidth * 2
        
        return currentPenObject.enabledShading ? resultLineWidth : getLineWidthForDrawing(touch, defaultLineWidth: resultLineWidth)
    }
    
    private func getLineWidthForDrawing(touch: UITouch, defaultLineWidth: CGFloat?) -> CGFloat {
        if forceTouchAvailable || touch.type == .Stylus {
            if touch.force > 0 {
                return touch.force.normalized(0, max: touch.maximumPossibleForce) * (defaultLineWidth ?? lineWidth) * 2
            }
        }
        return touch.majorRadius.normalized(0, max: 100) * lineWidth * 2
    }
}
