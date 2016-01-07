//
//  TouchControlView.swift
//  Student
//
//  Created by Leo Thomas on 07/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class TouchControlView: PageSubView {

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
    
    var selectedTouchControl = TouchControl.None
    
    override func awakeFromNib() {
        clearsContextBeforeDrawing = true
    }
    
    func setUpEditMode() {
    
    }
    
    override func handlePan(panGestureRecognizer: UIPanGestureRecognizer) {
        if isEditing {
            switch panGestureRecognizer.state {
            case .Began:
                selectedTouchControl = touchedControlRect(panGestureRecognizer.locationInView(self))
                break
            case .Changed:
                let translation = panGestureRecognizer.translationInView(self)
                panGestureRecognizer.setTranslation(CGPointZero, inView: self)
                handlePanTranslation(translation)
                setNeedsDisplay()
                break
            default:
                handlePanEnded()
                break
            }
        }
    }
    
    func touchedControlRect(touchLocation: CGPoint) -> TouchControl {
        for (touchControl, rect) in getControlRects() {
            if rect.contains(touchLocation) {
                return touchControl
            }
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

    func getControllableRect() -> CGRect {
        return frame
    }
    
    func handlePanTranslation(translation: CGPoint) -> CGRect {
        var contralableRect = getControllableRect()
        print(selectedTouchControl)
        switch selectedTouchControl {
        case .TopLeftCorner:
            contralableRect.origin.addPoint(translation)
            contralableRect.size.width -= translation.x
            contralableRect.size.height -= translation.y
            break
        case .TopRightCorner:
            contralableRect.origin.addPoint(CGPoint(x: 0, y: translation.y))
            contralableRect.size.width += translation.x
            contralableRect.size.height -= translation.y
            break
        case .BottomLeftCorner:
            contralableRect.origin.addPoint(CGPoint(x: translation.x, y: 0))
            contralableRect.size.width -= translation.x
            contralableRect.size.height += translation.y
            break
        case .BottomRightCorner:
            contralableRect.size.width += translation.x
            contralableRect.size.height += translation.y
            break
        case .TopSide:
            contralableRect.origin.y += translation.y
            contralableRect.size.height -= translation.y
            break
        case .LeftSide:
            contralableRect.origin.addPoint(CGPoint(x: translation.x, y: 0))
            contralableRect.size.width -= translation.x
            break
        case .RightSide:
            contralableRect.size.width += translation.x
            break
        case .BottomSide:
            contralableRect.size.height += translation.y
            break
        case .Center:
            contralableRect.origin.addPoint(translation)
            break
        case .None:
            break
        }
        return contralableRect
    }
    
    func handlePanEnded() {
        selectedTouchControl = .None
    }

}
