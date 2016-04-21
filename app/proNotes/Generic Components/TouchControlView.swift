//
//  TouchControlView.swift
//  proNotes
//
//  Created by Leo Thomas on 07/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class TouchControlView: UIView {

    enum TouchControl {
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
        
        func isRight() -> Bool {
            return self == .TopRightCorner || self == .RightSide || self == .BottomRightCorner
        }
        
        func isBottom() -> Bool {
            return self == .BottomSide || self == .BottomLeftCorner || self == .BottomRightCorner
        }
    }

    var controlLength: CGFloat = 22 {
        didSet {
            setNeedsDisplay()
        }
    }

    var isEditing = false {
        didSet {
            setUpEditMode()
            setNeedsDisplay()
        }
    }
    
    var movable: Bool {
        get {
            return true
        }
    }
    
    var controlLineWidth: CGFloat {
        get {
            return controlLength / 4
        }
    }
    
    var controlLineLength: CGFloat {
        get {
            return controlLength * (2/3)
        }
    }
    
    // ProportionalResize & WidthResizingOnly is not possible
    
    var proportionalResize = false {
        didSet {
            if proportionalResize && widthResizingOnly {
                widthResizingOnly = false
            }
        }
    }
    var widthResizingOnly = false {
        didSet {
            if widthResizingOnly && proportionalResize {
                proportionalResize = false
            }
        }
    }

    var oldFrame: CGRect?
    var selectedTouchControl = TouchControl.None

    override func awakeFromNib() {
        clearsContextBeforeDrawing = true
    }

    func setUpEditMode() {
        // empty base Implementation
    }

    func handlePan(panGestureRecognizer: UIPanGestureRecognizer) {
        if isEditing {
            switch panGestureRecognizer.state {
            case .Began:
                oldFrame = frame
                selectedTouchControl = touchedControlRect(panGestureRecognizer.locationInView(self))
                break
            case .Changed:
                let translation = panGestureRecognizer.translationInView(self)
                panGestureRecognizer.setTranslation(CGPointZero, inView: self)
                handlePanTranslation(translation)
                break
            default:
                handlePanEnded()
                break
            }
        }
    }

    func touchedControlRect(touchLocation: CGPoint) -> TouchControl {
        for (touchControl, rect) in getControlRects() where rect.contains(touchLocation) {
            if widthResizingOnly && (touchControl == .TopSide || touchControl == .BottomSide) {
                return .Center
            }
            return touchControl
        }
        return .None
    }

    func getControlRects() -> Dictionary<TouchControl, CGRect> {
        var rects = Dictionary<TouchControl, CGRect>()
        let mainRect = getControllableRect()

        let topLeftRect = CGRect(center: mainRect.origin, width: controlLength * 2, height: controlLength * 2)
        rects[.TopLeftCorner] = topLeftRect

        let topRightRect = CGRect(center: CGPoint(x: CGRectGetMaxX(mainRect), y: mainRect.origin.y), width: controlLength * 2, height: controlLength * 2)
        rects[.TopRightCorner] = topRightRect

        let bottomLeftRect = CGRect(center: CGPoint(x: mainRect.origin.x, y: CGRectGetMaxY(mainRect)), width: controlLength * 2, height: controlLength * 2)
        rects[.BottomLeftCorner] = bottomLeftRect

        let bottomRightRect = CGRect(center: CGPoint(x: CGRectGetMaxX(mainRect), y: CGRectGetMaxY(mainRect)), width: controlLength * 2, height: controlLength * 2)
        rects[.BottomRightCorner] = bottomRightRect

        let topSideRect = CGRect(center: CGPoint(x: CGRectGetMidX(mainRect), y: CGRectGetMidY(topLeftRect)), width: mainRect.width - (2 * controlLength), height: 2 * controlLength)
        rects[.TopSide] = topSideRect

        let leftSideRect = CGRect(center: CGPoint(x: CGRectGetMidX(topLeftRect), y: CGRectGetMidY(mainRect)), width: 2 * controlLength, height: mainRect.height - (2 * controlLength))
        rects[.LeftSide] = leftSideRect

        let rightSideRect = CGRect(center: CGPoint(x: CGRectGetMidX(topRightRect), y: CGRectGetMidY(mainRect)), width: 2 * controlLength, height: mainRect.height - (2 * controlLength))
        rects[.RightSide] = rightSideRect

        let bottomSideRect = CGRect(center: CGPoint(x: CGRectGetMidX(topSideRect), y: CGRectGetMidY(bottomLeftRect)), width: topSideRect.width, height: topSideRect.height)
        rects[.BottomSide] = bottomSideRect

        let centerRect = CGRect(center: mainRect.getCenter(), width: mainRect.width - 2 * controlLength, height: mainRect.height - 2 * controlLength)
        rects[.Center] = centerRect

        return rects
    }

    func getMovableRect() -> CGRect {
        return frame
    }

    func getControllableRect() -> CGRect {
        return bounds
    }
    
    func getDrawRect() -> CGRect {
        return bounds
    }

    func handlePanTranslation(translation: CGPoint) -> CGRect {
        var controlableRect = getMovableRect()
        var sizeOffset = CGSize(width: getWidthOffset(translation, control:selectedTouchControl), height: widthResizingOnly ? 0 : getHeightOffset(translation, control: selectedTouchControl))

        if proportionalResize {
            calculateProportionalSizeChange(&sizeOffset, originalSize: controlableRect.size)
        }
        
        controlableRect.size.width += sizeOffset.width
        controlableRect.size.height += sizeOffset.height
        controlableRect.origin.addPoint(getOriginOffset(sizeOffset, translation: translation, control: selectedTouchControl, proportional: proportionalResize))
        return controlableRect
    }
    
    private func getHeightOffset(translation: CGPoint, control: TouchControl) -> CGFloat {
        switch control {
        case .TopLeftCorner, .TopRightCorner, .TopSide:
            return -translation.y
        case .BottomLeftCorner, .BottomRightCorner, .BottomSide:
            return translation.y
        default:
            return 0
        }
    }
    
    private func getWidthOffset(translation: CGPoint, control: TouchControl) -> CGFloat {
        switch control {
        case .TopLeftCorner, .BottomLeftCorner, .LeftSide:
            return -translation.x
        case .TopRightCorner, .BottomRightCorner, .RightSide:
            return translation.x
        default:
            return 0
        }
    }
    
    private func calculateProportionalSizeChange(inout sizeChange: CGSize, originalSize: CGSize) {
        var ratio: CGFloat = 1
        if sizeChange.width != 0 && sizeChange.height != 0 {
            ratio = min(sizeChange.width / originalSize.width, sizeChange.width / originalSize.height)
        } else if sizeChange.height != 0 {
            ratio = sizeChange.height / originalSize.height
        } else  if sizeChange.width != 0 {
            ratio = sizeChange.width / originalSize.width
        } else {
            return
        }
        
        sizeChange.width = originalSize.width * ratio
        sizeChange.height = originalSize.height * ratio
    
    }
    
    private func getOriginOffset(sizeChange: CGSize, translation: CGPoint, control: TouchControl, proportional: Bool) -> CGPoint {
        
        var xOffset = control.isRight() ? 0 : -sizeChange.width
        var yOffset = control.isBottom() ? 0 : -sizeChange.height

        switch control {
        case .Center:
            return movable ? translation : .zero
        case .TopSide, .BottomSide:
            xOffset /= 2
            break
        case .LeftSide, .RightSide:
            yOffset /= 2
            break
        default:
            break
        }
        
        return CGPoint(x: xOffset, y: yOffset)
    }
    
    func handlePanEnded() {
        selectedTouchControl = .None
    }

    override func drawRect(rect: CGRect) {
        UIColor.lightGrayColor().setStroke()
        let controlPath = UIBezierPath()
        let overlayRect = getDrawRect()
        controlPath.lineWidth = controlLineWidth
        
        if widthResizingOnly {
            let midY = CGRectGetMidY(overlayRect)
            // Center Left Side
            controlPath.moveToPoint(CGPoint(x: overlayRect.origin.x, y: midY-controlLength/4))
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x, y: midY+controlLength/4))
            
            // Center Right Side
            controlPath.moveToPoint(CGPoint(x: CGRectGetMaxX(overlayRect), y: midY-controlLength/4))
            controlPath.addLineToPoint(CGPoint(x: CGRectGetMaxX(overlayRect), y: midY+controlLength/4))
        } else {
            // Top Left Corner
            controlPath.moveToPoint(CGPoint(x: overlayRect.origin.x, y: overlayRect.origin.y + controlLineLength))
            controlPath.addLineToPoint(overlayRect.origin)
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x + controlLineLength, y: overlayRect.origin.y))
            
            // Bottom Left Corner
            controlPath.moveToPoint(CGPoint(x: overlayRect.origin.x, y: overlayRect.height + overlayRect.origin.y - controlLineLength))
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x, y: overlayRect.height + overlayRect.origin.y))
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x + controlLineLength, y: overlayRect.height + overlayRect.origin.y))
            
            // Top Right Corner
            controlPath.moveToPoint(CGPoint(x: overlayRect.origin.x + overlayRect.width - controlLineLength, y: overlayRect.origin.y))
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x + overlayRect.width, y: overlayRect.origin.y))
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x + overlayRect.width, y: overlayRect.origin.y + controlLineLength))
            
            // Bottom Right Corner
            controlPath.moveToPoint(CGPoint(x: overlayRect.origin.x + overlayRect.width - controlLineLength, y: overlayRect.origin.y + overlayRect.height))
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x + overlayRect.width, y: overlayRect.origin.y + overlayRect.height))
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x + overlayRect.width, y: overlayRect.origin.y - controlLineLength + overlayRect.height))
        }
        controlPath.stroke()
    }
    
}
