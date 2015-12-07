//
//  MovableView.swift
//  Student
//
//  Created by Leo Thomas on 06/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

enum TouchRect {
    case TopLeft
    case TopMiddle
    case TopRight
    case MiddleLeft
    case MiddleRight
    case BottomLeft
    case BottomMiddle
    case BottomRight
    
    static let allValues = [TopLeft, TopMiddle, TopRight, MiddleLeft, MiddleRight, BottomLeft, BottomMiddle, BottomRight]
}

class MovableView: UIView {

    static let touchSize: CGFloat = 20
    
    var editMode = false
    var touchedRect: TouchRect?
    var finishedSetup = false
    var lastPinchScale: CGFloat = 0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpTouchRecognizer()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func addAutoLayoutConstraints(subview: UIView) {
        let leftConstraint = NSLayoutConstraint(item: subview, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: MovableView.touchSize)
        let rightConstraint = NSLayoutConstraint(item: subview, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant:-MovableView.touchSize)
        let bottomConstraint = NSLayoutConstraint(item: subview, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -MovableView.touchSize)
        let topConstraint = NSLayoutConstraint(item: subview, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: MovableView.touchSize)
            
        addConstraints([leftConstraint, rightConstraint, bottomConstraint, topConstraint])
        layoutIfNeeded()
    }
    
    func setUpTouchRecognizer() {
        backgroundColor = UIColor.purpleColor()
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
        addGestureRecognizer(panRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        addGestureRecognizer(tapRecognizer)
        
        let pinchRecognizer =  UIPinchGestureRecognizer(target: self, action: Selector("handlePinch:"))
        addGestureRecognizer(pinchRecognizer)
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        editMode = !editMode
        
        if editMode {
            self.superview?.addGestureRecognizer(recognizer)
        } else {
            self.superview?.removeGestureRecognizer(recognizer)
            self.addGestureRecognizer(recognizer)
        }
        
        setNeedsDisplay()
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer){
        if editMode {
            switch recognizer.state {
            case .Began:
                let point = recognizer.locationInView(self)
                touchedRect = getTouchedRect(point)
                break
            case .Changed:
                let translation = recognizer.translationInView(self)
                recognizer.setTranslation(CGPointZero, inView: self)
                guard let currentTouchedRect = touchedRect else {
                    center.addPoint(translation)
                    return
                }
                
                var size = bounds.size
                var origin = frame.origin
                
                switch currentTouchedRect {
                case .TopLeft:
                    origin.y += translation.y
                    size.height -= translation.y
                    origin.x += translation.x
                    size.width -= translation.x
                    break
                case .TopMiddle:
                    origin.y += translation.y
                    size.height -= translation.y
                    break
                case .TopRight:
                    origin.y += translation.y
                    size.height -= translation.y
                    size.width += translation.x
                    break
                case .MiddleLeft:
                    origin.x += translation.x
                    size.width -= translation.x
                    break
                case .MiddleRight:
                    size.width += translation.x
                    break
                case .BottomLeft:
                    origin.x += translation.x
                    size.width -= translation.x
                    size.height += translation.y
                    break
                case .BottomMiddle:
                    size.height += translation.y
                    break
                case .BottomRight:
                    size.height += translation.y
                    size.width += translation.x
                    break
                }
                frame.origin = origin
                bounds.size = size
                layoutIfNeeded()
                setNeedsDisplay()
                break
            default:
                break
            }
        }
    }
    
    func handlePinch(recognizer: UIPinchGestureRecognizer){
        if editMode {
            let scale = 1.0 - (lastPinchScale - recognizer.scale);
            bounds.size.multiplySize(scale)
            lastPinchScale = recognizer.scale
        }
    }
    
    func getTouchRects() -> [CGRect]{
        var rects = [CGRect]()
        
        for touchRect in TouchRect.allValues {
            rects.append(getTouchRect(touchRect))
        }

        return rects
    }
    
    func getTouchedRect(point: CGPoint) -> TouchRect? {
        for touchRect in TouchRect.allValues {
            let currentRect = getTouchRect(touchRect)
            if currentRect.contains(point){
                return touchRect
            }
        }
        return nil
    }
    
    func getTouchRect(rect: TouchRect) -> CGRect {
        let midY = CGRectGetMidY(bounds)-MovableView.touchSize
        let maxY = CGRectGetMaxY(bounds)-MovableView.touchSize*2
        let midX = CGRectGetMidX(bounds)-MovableView.touchSize
        let maxX = CGRectGetMaxX(bounds)-MovableView.touchSize*2
        let size = CGSize(width: MovableView.touchSize*2, height: MovableView.touchSize*2)
        var result: CGRect
        switch rect {
        case .TopLeft:
            result = CGRect(origin: CGPointZero, size: size)
            break
        case .TopMiddle:
            result = CGRect(origin: CGPoint(x: midX, y: 0), size: size)
            break
        case .TopRight:
            result = CGRect(origin: CGPoint(x: maxX, y: 0), size: size)
            break
        case .MiddleLeft:
            result = CGRect(origin: CGPoint(x: 0, y: midY), size: size)
            break
        case .MiddleRight:
            result = CGRect(origin: CGPoint(x: maxX, y: midY), size: size)
            break
        case .BottomLeft:
            result = CGRect(origin: CGPoint(x: 0, y: maxY), size: size)
            break
        case .BottomMiddle:
            result = CGRect(origin: CGPoint(x: midX, y: maxY), size: size)
            break
        case .BottomRight:
            result = CGRect(origin: CGPoint(x: maxX, y: maxY), size: size)
            break
        }
        return result
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        if editMode {
            let context = UIGraphicsGetCurrentContext()
            for touchRect in getTouchRects() {
                UIColor.blackColor().setFill()
                CGContextFillRect(context, touchRect)
            }
        }
    }
    
}
