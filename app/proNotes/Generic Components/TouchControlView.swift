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
        case topLeftCorner
        case topRightCorner
        case bottomLeftCorner
        case bottomRightCorner
        case topSide
        case leftSide
        case rightSide
        case bottomSide
        case center
        case none
        
        func isRight() -> Bool {
            return self == .topRightCorner || self == .rightSide || self == .bottomRightCorner
        }
        
        func isBottom() -> Bool {
            return self == .bottomSide || self == .bottomLeftCorner || self == .bottomRightCorner
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
    var selectedTouchControl = TouchControl.none

    override func awakeFromNib() {
        clearsContextBeforeDrawing = true
    }

    func setUpEditMode() {
        // empty base Implementation
    }

    func handlePan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        if isEditing {
            switch panGestureRecognizer.state {
            case .began:
                oldFrame = frame
                selectedTouchControl = touchedControlRect(panGestureRecognizer.location(in: self))
                break
            case .changed:
                let translation = panGestureRecognizer.translation(in: self)
                panGestureRecognizer.setTranslation(CGPoint.zero, in: self)
                handlePanTranslation(translation)
                break
            default:
                handlePanEnded()
                break
            }
        }
    }

    func touchedControlRect(_ touchLocation: CGPoint) -> TouchControl {
        for (touchControl, rect) in getControlRects() where rect.contains(touchLocation) {
            if widthResizingOnly && (touchControl == .topSide || touchControl == .bottomSide) {
                return .center
            }
            return touchControl
        }
        return .none
    }

    func getControlRects() -> Dictionary<TouchControl, CGRect> {
        var rects = Dictionary<TouchControl, CGRect>()
        let mainRect = getControllableRect()

        let topLeftRect = CGRect(center: mainRect.origin, width: controlLength * 2, height: controlLength * 2)
        rects[.topLeftCorner] = topLeftRect

        let topRightRect = CGRect(center: CGPoint(x: mainRect.maxX, y: mainRect.origin.y), width: controlLength * 2, height: controlLength * 2)
        rects[.topRightCorner] = topRightRect

        let bottomLeftRect = CGRect(center: CGPoint(x: mainRect.origin.x, y: mainRect.maxY), width: controlLength * 2, height: controlLength * 2)
        rects[.bottomLeftCorner] = bottomLeftRect

        let bottomRightRect = CGRect(center: CGPoint(x: mainRect.maxX, y: mainRect.maxY), width: controlLength * 2, height: controlLength * 2)
        rects[.bottomRightCorner] = bottomRightRect

        let topSideRect = CGRect(center: CGPoint(x: mainRect.midX, y: topLeftRect.midY), width: mainRect.width - (2 * controlLength), height: 2 * controlLength)
        rects[.topSide] = topSideRect

        let leftSideRect = CGRect(center: CGPoint(x: topLeftRect.midX, y: mainRect.midY), width: 2 * controlLength, height: mainRect.height - (2 * controlLength))
        rects[.leftSide] = leftSideRect

        let rightSideRect = CGRect(center: CGPoint(x: topRightRect.midX, y: mainRect.midY), width: 2 * controlLength, height: mainRect.height - (2 * controlLength))
        rects[.rightSide] = rightSideRect

        let bottomSideRect = CGRect(center: CGPoint(x: topSideRect.midX, y: bottomLeftRect.midY), width: topSideRect.width, height: topSideRect.height)
        rects[.bottomSide] = bottomSideRect

        let centerRect = CGRect(center: mainRect.getCenter(), width: mainRect.width - 2 * controlLength, height: mainRect.height - 2 * controlLength)
        rects[.center] = centerRect

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

    @discardableResult
    func handlePanTranslation(_ translation: CGPoint) -> CGRect {
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
    
    private func getHeightOffset(_ translation: CGPoint, control: TouchControl) -> CGFloat {
        switch control {
        case .topLeftCorner, .topRightCorner, .topSide:
            return -translation.y
        case .bottomLeftCorner, .bottomRightCorner, .bottomSide:
            return translation.y
        default:
            return 0
        }
    }
    
    private func getWidthOffset(_ translation: CGPoint, control: TouchControl) -> CGFloat {
        switch control {
        case .topLeftCorner, .bottomLeftCorner, .leftSide:
            return -translation.x
        case .topRightCorner, .bottomRightCorner, .rightSide:
            return translation.x
        default:
            return 0
        }
    }
    
    private func calculateProportionalSizeChange(_ sizeChange: inout CGSize, originalSize: CGSize) {
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
    
    private func getOriginOffset(_ sizeChange: CGSize, translation: CGPoint, control: TouchControl, proportional: Bool) -> CGPoint {
        
        var xOffset = control.isRight() ? 0 : -sizeChange.width
        var yOffset = control.isBottom() ? 0 : -sizeChange.height

        switch control {
        case .center:
            return movable ? translation : .zero
        case .topSide, .bottomSide:
            xOffset /= 2
            break
        case .leftSide, .rightSide:
            yOffset /= 2
            break
        default:
            break
        }
        
        return CGPoint(x: xOffset, y: yOffset)
    }
    
    func handlePanEnded() {
        selectedTouchControl = .none
    }

    override func draw(_ rect: CGRect) {
        UIColor.lightGray().setStroke()
        let controlPath = UIBezierPath()
        let overlayRect = getDrawRect()
        controlPath.lineWidth = controlLineWidth
        
        if widthResizingOnly {
            let midY = overlayRect.midY
            // Center Left Side
            controlPath.move(to: CGPoint(x: overlayRect.origin.x, y: midY-controlLength/4))
            controlPath.addLine(to: CGPoint(x: overlayRect.origin.x, y: midY+controlLength/4))
            
            // Center Right Side
            controlPath.move(to: CGPoint(x: overlayRect.maxX, y: midY-controlLength/4))
            controlPath.addLine(to: CGPoint(x: overlayRect.maxX, y: midY+controlLength/4))
        } else {
            // Top Left Corner
            controlPath.move(to: CGPoint(x: overlayRect.origin.x, y: overlayRect.origin.y + controlLineLength))
            controlPath.addLine(to: overlayRect.origin)
            controlPath.addLine(to: CGPoint(x: overlayRect.origin.x + controlLineLength, y: overlayRect.origin.y))
            
            // Bottom Left Corner
            controlPath.move(to: CGPoint(x: overlayRect.origin.x, y: overlayRect.height + overlayRect.origin.y - controlLineLength))
            controlPath.addLine(to: CGPoint(x: overlayRect.origin.x, y: overlayRect.height + overlayRect.origin.y))
            controlPath.addLine(to: CGPoint(x: overlayRect.origin.x + controlLineLength, y: overlayRect.height + overlayRect.origin.y))
            
            // Top Right Corner
            controlPath.move(to: CGPoint(x: overlayRect.origin.x + overlayRect.width - controlLineLength, y: overlayRect.origin.y))
            controlPath.addLine(to: CGPoint(x: overlayRect.origin.x + overlayRect.width, y: overlayRect.origin.y))
            controlPath.addLine(to: CGPoint(x: overlayRect.origin.x + overlayRect.width, y: overlayRect.origin.y + controlLineLength))
            
            // Bottom Right Corner
            controlPath.move(to: CGPoint(x: overlayRect.origin.x + overlayRect.width - controlLineLength, y: overlayRect.origin.y + overlayRect.height))
            controlPath.addLine(to: CGPoint(x: overlayRect.origin.x + overlayRect.width, y: overlayRect.origin.y + overlayRect.height))
            controlPath.addLine(to: CGPoint(x: overlayRect.origin.x + overlayRect.width, y: overlayRect.origin.y - controlLineLength + overlayRect.height))
        }
        controlPath.stroke()
    }
    
}
