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

    enum  TouchControl {
        case TopLeftCorner
        case TopRightCorner
        case BottomLeftCorner
        case BottomRightCorner
        case TopSide
        case LeftSide
        case RightSide
        case BottomSide
        case Center
        case None
    }
    
    var image: UIImage? {
        didSet{
            if image != nil {
                layout()
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
    
    @IBInspectable
    var controlLength: CGFloat = 22 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var isCropping = false {
        didSet {
            setUpPanRecognizer()
            setNeedsDisplay()
        }
    }
    
    var overlayRect: CGRect = CGRectZero
    var selectedTouchControl = TouchControl.None
    
    override func awakeFromNib() {
        clearsContextBeforeDrawing = true
    }
    
    func layout() {
        for constraint in constraints {
            if constraint.firstAttribute == .Height {
                
                layoutIfNeeded()
                let ratio = getImageRatio()
  
                constraint.constant = (image!.size.height * ratio) + topPadding + bottomPadding
                layoutIfNeeded()
                superview?.layoutIfNeeded()

                overlayRect = getImageRect()
                setNeedsDisplay()
            }
        }
    }
    
    func getImageRect() -> CGRect {
        return CGRect(x: leftPadding, y: topPadding, width: frame.width-leftPadding-rightPadding, height: frame.height-topPadding-bottomPadding)
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
            selectedTouchControl = touchedControlRect(panGestureRecognizer.locationInView(self))
            break
        case .Changed:
            let translation = panGestureRecognizer.translationInView(self)
            panGestureRecognizer.setTranslation(CGPointZero, inView: self)
            var newOverlayRect = overlayRect
            switch selectedTouchControl {
            case .TopLeftCorner:
                newOverlayRect.origin.addPoint(translation)
                newOverlayRect.size.width -= translation.x
                newOverlayRect.size.height -= translation.y
                break
            case .TopRightCorner:
                newOverlayRect.origin.addPoint(CGPoint(x: 0, y: translation.y))
                newOverlayRect.size.width += translation.x
                newOverlayRect.size.height -= translation.y
                break
            case .BottomLeftCorner:
                newOverlayRect.origin.addPoint(CGPoint(x: translation.x, y: 0))
                newOverlayRect.size.width -= translation.x
                newOverlayRect.size.height += translation.y
                break
            case .BottomRightCorner:
                newOverlayRect.size.width += translation.x
                newOverlayRect.size.height += translation.y
                break
            case .TopSide:
                newOverlayRect.origin.y += translation.y
                newOverlayRect.size.height -= translation.y
                break
            case .LeftSide:
                newOverlayRect.origin.addPoint(CGPoint(x: translation.x, y: 0))
                newOverlayRect.size.width -= translation.x
                break
            case .RightSide:
                newOverlayRect.size.width += translation.x
                break
            case .BottomSide:
                newOverlayRect.size.height += translation.y
                break
            case .Center:
                newOverlayRect.origin.addPoint(translation)
                break
            case .None:
                return
            }
            
            let imageRect = getImageRect()
            
            overlayRect.origin.x = between(newOverlayRect.origin.x, min: imageRect.origin.x, max: CGRectGetMaxX(imageRect))
            overlayRect.origin.y = between(newOverlayRect.origin.y, min: imageRect.origin.y, max: CGRectGetMaxY(imageRect))
            overlayRect.size.width = between(newOverlayRect.width, min: controlLength*2, max: imageRect.width)
            overlayRect.size.height = between(newOverlayRect.height, min: controlLength*2, max: imageRect.height)
            
            setNeedsDisplay()
            break
        default:
            selectedTouchControl = .None
            break
        }
       
    }
    
    func touchedControlRect(touchLocation: CGPoint) -> TouchControl {
        for (touchControl , rect) in getControlRects() {
            if  rect.contains(touchLocation){
                return touchControl
            }
        }
        return .None
    }
    
    func getControlRects() -> Dictionary<TouchControl, CGRect> {
        var rects = Dictionary<TouchControl, CGRect>()

        let topLeftRect = CGRect(center: overlayRect.origin, width: controlLength*2, height: controlLength*2)
        rects[.TopLeftCorner] = topLeftRect
        
        let topRightRect = CGRect(center: CGPoint(x: CGRectGetMaxX(overlayRect), y: overlayRect.origin.y), width: controlLength*2, height: controlLength*2)
        rects[.TopRightCorner] = topRightRect
        
        let bottomLeftRect = CGRect(center: CGPoint(x: overlayRect.origin.x, y: CGRectGetMaxY(overlayRect)), width: controlLength*2, height: controlLength*2)
        rects[.BottomLeftCorner] = bottomLeftRect
        
        let bottomRightRect = CGRect(center: CGPoint(x: CGRectGetMaxX(overlayRect), y: CGRectGetMaxY(overlayRect)), width: controlLength*2, height: controlLength*2)
        rects[.BottomRightCorner] = bottomRightRect
        
        let topSideRect = CGRect(center: CGPoint(x: CGRectGetMidX(overlayRect), y: CGRectGetMidY(topLeftRect)), width: overlayRect.width - (2*controlLength), height: 2*controlLength)
        rects[.TopSide] = topSideRect
        
        let leftSideRect = CGRect(center: CGPoint(x: CGRectGetMidX(topLeftRect), y: CGRectGetMidY(overlayRect)), width: 2*controlLength, height: overlayRect.height - (2*controlLength))
        rects[.LeftSide] = leftSideRect
        
        let rightSideRect = CGRect(center: CGPoint(x: CGRectGetMidX(topRightRect), y: CGRectGetMidY(overlayRect)), width: 2*controlLength, height: overlayRect.height - (2*controlLength))
        rects[.RightSide] = rightSideRect
        
        let bottomSideRect = CGRect(center: CGPoint(x: CGRectGetMidX(topSideRect), y: CGRectGetMidY(bottomLeftRect)), width: topSideRect.width, height: topSideRect.height)
        rects[.BottomSide] = bottomSideRect
        
        let centerRect = CGRect(center: overlayRect.getCenter(), width: overlayRect.width-2*controlLength, height: overlayRect.height-2*controlLength)
        rects[.Center] = centerRect
        
        return rects
    }
    
    func convertToImageRect(var rect: CGRect, ratio: CGFloat) -> CGRect {
        rect.origin.x /= ratio
        rect.origin.y /= ratio
        rect.size.width /= ratio
        rect.size.height /= ratio
        return rect
    }

    func getImageRatio() -> CGFloat{
        if image != nil {
            let width = bounds.width - leftPadding - rightPadding
            let ratio = width/image!.size.width
            return ratio
        }
        return 0
    }
    
    func crop() {
        let newImageRect = convertToImageRect(CGRect(origin: CGPoint(x: overlayRect.origin.x-leftPadding, y: overlayRect.origin.y-topPadding), size: overlayRect.size), ratio: getImageRatio())
        isCropping = false
        image = image?.cropedImage(newImageRect)
        layout()
    }
    
    override func drawRect(rect: CGRect) {
        let imageRect = getImageRect()
        let lineWidth: CGFloat = 2

        // TODO only redraw images on changes
        image?.drawInRect(imageRect)
        
        if isCropping {
            let borderPath = UIBezierPath(rect: imageRect)
            borderPath.lineWidth = lineWidth
            UIColor.lightGrayColor().setStroke()

            let controlLineWidth = lineWidth*2
            let controlPath = UIBezierPath()
            
            // Top Left Corner
            controlPath.moveToPoint(CGPoint(x: overlayRect.origin.x, y: overlayRect.origin.y+controlLength))
            controlPath.addLineToPoint(overlayRect.origin)
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x+controlLength, y: overlayRect.origin.y))
            
            // Bottom Left Corner
            controlPath.moveToPoint(CGPoint(x: overlayRect.origin.x, y: overlayRect.height+overlayRect.origin.y-controlLength))
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x, y: overlayRect.height+overlayRect.origin.y))
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x+controlLength, y: overlayRect.height+overlayRect.origin.y))
            
            // Top Right Corner
            controlPath.moveToPoint(CGPoint(x: overlayRect.origin.x+overlayRect.width-controlLength, y: overlayRect.origin.y))
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x+overlayRect.width, y: overlayRect.origin.y))
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x+overlayRect.width, y:overlayRect.origin.y+controlLength))
            
            // Bottom Right Corner
            controlPath.moveToPoint(CGPoint(x: overlayRect.origin.x+overlayRect.width-controlLength, y: overlayRect.origin.y+overlayRect.height))
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x+overlayRect.width, y: overlayRect.origin.y+overlayRect.height))
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x+overlayRect.width, y:overlayRect.origin.y-controlLength+overlayRect.height))
            
            controlPath.lineWidth = controlLineWidth
            controlPath.stroke()

            borderPath.stroke()
            
            if !CGRectEqualToRect(overlayRect, imageRect) {
                let overlayPath = UIBezierPath(rect: imageRect)
                overlayPath.appendPath(UIBezierPath(rect: overlayRect).bezierPathByReversingPath())
                overlayPath.fillWithBlendMode(.Darken, alpha: 0.5)
            }
        }
    }

}
