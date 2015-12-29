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

class MovableView: PageSubView {

    static let touchSize: CGFloat = 20
    
    var editMode = false
    var touchedRect: TouchRect?
    var finishedSetup = false
    var lastPinchScale: CGFloat = 0
    var movableLayer: MovableLayer?
    
    init(frame: CGRect, movableLayer: MovableLayer) {
        self.movableLayer = movableLayer
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
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
    
    override func setSelected() {
        handleTap(nil)
    }
    
    override func handleTap(recognizer: UITapGestureRecognizer?) {
        editMode = !editMode
        
        if editMode {
//            self.superview?.addGestureRecognizer(recognizer)
            setUpSettingsViewController()
            
        } else {
//            self.superview?.removeGestureRecognizer(recognizer)
//            self.addGestureRecognizer(recognizer)
            setDeselected()
            DocumentSynchronizer.sharedInstance.settingsViewController?.currentSettingsType = .PageInfo
        }
        
        setNeedsDisplay()
    }
    
    override func handlePan(recognizer: UIPanGestureRecognizer){
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
                    origin.y += translation.y/2
                    size.height -= translation.y
                    break
                case .TopRight:
                    origin.y += translation.y
                    size.height -= translation.y
                    size.width += translation.x
                    break
                case .MiddleLeft:
                    origin.x += translation.x/2
                    size.width -= translation.x
                    break
                case .MiddleRight:
                    size.width += translation.x
                    origin.x += translation.x/2
                    break
                case .BottomLeft:
                    origin.x += translation.x
                    size.width -= translation.x
                    size.height += translation.y
                    break
                case .BottomMiddle:
                    size.height += translation.y
                    origin.y += translation.y/2
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
            case .Ended:
                if movableLayer != nil {
                    movableLayer?.origin = frame.origin
                
                    var newSize = frame.size
                    movableLayer?.size = newSize.increaseSize(MovableView.touchSize*(-2))
                    saveChanges()
                }
                break
            default:
                break
            }
        }
    }
    
    override func handlePinch(recognizer: UIPinchGestureRecognizer){
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
    
    
    
    
    
    override func saveChanges() {
        DocumentSynchronizer.sharedInstance.updateMovableLayer(movableLayer!)
    }
    
}
