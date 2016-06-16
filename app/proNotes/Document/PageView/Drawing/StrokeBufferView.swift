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
    
    var strokeColor: UIColor = SettingsViewController.sharedInstance?.currentChildViewController?.colorPicker?.getSelectedColor() ?? UIColor.black()
            
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
        backgroundColor = .clear()
    }
    
    func reset() {
        image = nil
    }
    
    // MARK Touch Handling
    
    func handleTouches(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        image?.draw(in: bounds)
        for touch in event?.coalescedTouches(for: touch) ?? [] {
            drawStroke(context, touch: touch)
        }
    
        image = UIGraphicsGetImageFromCurrentImageContext()
    
        UIGraphicsEndImageContext()
    }
    
    private func drawStroke(_ context: CGContext?, touch: UITouch) {
        let previousLocation = touch.previousLocation(in: self)
        let location = touch.location(in: self)
        context?.setStrokeColor(strokeColor.cgColor)
        context?.setLineWidth(getLineWidth(context, touch: touch))
        context?.setLineCap(.round)
        context?.setLineJoin(.round)
        context?.moveTo(x: previousLocation.x, y: previousLocation.y)
        context?.setAlpha(touch.force/touch.maximumPossibleForce)
        context?.addLineTo(x: location.x, y: location.y)
        context?.strokePath()
    }
    
    private func getLineWidth(_ context: CGContext?, touch: UITouch) -> CGFloat {
        var newLineWidth: CGFloat = 0
        if touch.type == .stylus  {
            newLineWidth = getLineWidthForStylus(touch)
        } else {
            newLineWidth = getLineWidthForDrawing(touch, defaultLineWidth: nil)
        }
        newLineWidth = (newLineWidth + oldLineWidth) / 2
        oldLineWidth = newLineWidth
        return newLineWidth
    }
    
    private func getLineWidthForStylus(_ touch: UITouch) -> CGFloat {
        let previousLocation = touch.previousLocation(in: self)
        let location = touch.location(in: self)
        
        let azimuthVector = touch.azimuthUnitVector(in: self)
        
        let directionVector = CGVector(dx: location.x - previousLocation.x, dy: location.y - previousLocation.y)
        
        var angle = CGVector.angleBetween(azimuthVector, secondVector: directionVector)
        
        if angle > CGFloat(180).toRadians() {
            angle = CGFloat(360).toRadians() - angle
        }
        if angle > CGFloat(90).toRadians() {
            angle = CGFloat(180).toRadians() - angle
        }
        
        let normalizedAltitude = touch.altitudeAngle.normalized(0, max: CGFloat(90).toRadians())
        let normalizedAngle = angle.normalized(0, max: CGFloat(90).toRadians())
        let resultLineWidth = (normalizedAngle * (2/3) + normalizedAltitude * (1/3)) * lineWidth * 2
        
        return currentPenObject.enabledShading ? resultLineWidth : getLineWidthForDrawing(touch, defaultLineWidth: resultLineWidth)
    }
    
    private func getLineWidthForDrawing(_ touch: UITouch, defaultLineWidth: CGFloat?) -> CGFloat {
        if forceTouchAvailable || touch.type == .stylus {
            if touch.force > 0 {
                return touch.force.normalized(0, max: touch.maximumPossibleForce) * (defaultLineWidth ?? lineWidth) * 2
            }
        }
        return touch.majorRadius.normalized(0, max: 100) * lineWidth * 2
    }
}
