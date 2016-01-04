//
//  CropImageView.swift
//  Student
//
//  Created by Leo Thomas on 02/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

@IBDesignable
class CropImageView: UIView {

    var image: UIImage? {
        didSet{
            if image != nil {
                setNeedsDisplay()
            }
        }
    }
    
    @IBInspectable
    var leftPadding: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var rightPadding: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var topPadding: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var bottomPadding: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func awakeFromNib() {
        clearsContextBeforeDrawing = true
    }
    
    var isCropping = false {
        didSet {
            if isCropping {
                newImageRect = getImageRect()
            }
            setNeedsDisplay()
        }
    }
    
    var newImageRect: CGRect = CGRectZero
    
    func getImageRect() -> CGRect {
        return CGRect(x: leftPadding, y: topPadding, width: bounds.width-leftPadding-rightPadding, height: bounds.height-topPadding-bottomPadding)
    }
    
    func setUpPanRecognizer() {
        if isCropping {
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
                addGestureRecognizer(panGestureRecognizer)
        } else {
            removeAllGestureRecognizer()
        }
    }
    
    func handlePan(panGestureRecognizer: UIPanGestureRecognizer){
        switch panGestureRecognizer.state {
        case .Began:
            // todo check if control arrea touched
            break
        case .Changed:
            // translate size changes
            break
        default:
            break
        }
    }
    
    override func drawRect(rect: CGRect) {
        let imageRect = getImageRect()
        let controlLength: CGFloat = 20
        let lineWidth: CGFloat = 2

        image?.drawInRect(imageRect)
        
        if isCropping {
            let borderPath = UIBezierPath(rect: imageRect)
            borderPath.lineWidth = lineWidth
            UIColor.lightGrayColor().setStroke()

            let controlLineWidth = lineWidth*2
            let controlPath = UIBezierPath()
            
            // Top Left Corner
            controlPath.moveToPoint(CGPoint(x: newImageRect.origin.x, y: newImageRect.origin.y+controlLength))
            controlPath.addLineToPoint(newImageRect.origin)
            controlPath.addLineToPoint(CGPoint(x: newImageRect.origin.x+controlLength, y: newImageRect.origin.y))
            
            // Bottom Left Corner
            controlPath.moveToPoint(CGPoint(x: newImageRect.origin.x, y: newImageRect.height+newImageRect.origin.y-controlLength))
            controlPath.addLineToPoint(CGPoint(x: newImageRect.origin.x, y: newImageRect.height+newImageRect.origin.y))
            controlPath.addLineToPoint(CGPoint(x: newImageRect.origin.x+controlLength, y: newImageRect.height+newImageRect.origin.y))
            
            // Top Right Corner
            controlPath.moveToPoint(CGPoint(x: newImageRect.origin.x+newImageRect.width-controlLength, y: newImageRect.origin.y))
            controlPath.addLineToPoint(CGPoint(x: newImageRect.origin.x+newImageRect.width, y: newImageRect.origin.y))
            controlPath.addLineToPoint(CGPoint(x: newImageRect.origin.x+newImageRect.width, y:newImageRect.origin.y+controlLength))
            
            // Bottom Right Corner
            controlPath.moveToPoint(CGPoint(x: newImageRect.origin.x+newImageRect.width-controlLength, y: newImageRect.origin.y+newImageRect.height))
            controlPath.addLineToPoint(CGPoint(x: newImageRect.origin.x+newImageRect.width, y: newImageRect.origin.y+newImageRect.height))
            controlPath.addLineToPoint(CGPoint(x: newImageRect.origin.x+newImageRect.width, y:newImageRect.origin.y-controlLength+newImageRect.height))
            
            controlPath.lineWidth = controlLineWidth
            controlPath.stroke()


            borderPath.stroke()
            
            if !CGRectEqualToRect(newImageRect, imageRect) {
                let overlayPath = UIBezierPath(rect: imageRect)
                overlayPath.appendPath(UIBezierPath(rect: newImageRect).bezierPathByReversingPath())
                overlayPath.fillWithBlendMode(.Darken, alpha: 0.5)
            }
        }
    }

}
