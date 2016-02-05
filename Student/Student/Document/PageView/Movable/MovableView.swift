//
//  MovableView.swift
//  Student
//
//  Created by Leo Thomas on 06/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class MovableView: TouchControlView, PageSubView {

    // TODO style

    var finishedSetup = false
    var lastPinchScale: CGFloat = 0
    var movableLayer: MovableLayer?

    var debugMode = true

    init(frame: CGRect, movableLayer: MovableLayer) {
        self.movableLayer = movableLayer
        let newControlLength: CGFloat = 44
        super.init(frame: CGRect(origin: frame.origin, size: CGSize(width: frame.size.width + newControlLength * 2, height: frame.size.height + newControlLength * 2)))
        controlLength = newControlLength
        backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didAddSubview(subview: UIView) {
        let leftConstraint = NSLayoutConstraint(item: subview, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: controlLength)
        let rightConstraint = NSLayoutConstraint(item: subview, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: -controlLength)
        let bottomConstraint = NSLayoutConstraint(item: subview, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -controlLength)
        let topConstraint = NSLayoutConstraint(item: subview, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: controlLength)

        addConstraints([leftConstraint, rightConstraint, bottomConstraint, topConstraint])
        layoutIfNeeded()
    }

    func setSelected() {
        handleTap(nil)
    }

    func handleTap(recognizer: UITapGestureRecognizer?) {
        isEditing = !isEditing

        if isEditing {
            setUpSettingsViewController()

        } else {
            setDeselected()
            SettingsViewController.sharedInstance?.currentSettingsType = .PageInfo
        }

        setNeedsDisplay()
    }

    override func handlePanTranslation(translation: CGPoint) -> CGRect {
        frame = super.handlePanTranslation(translation)
        layoutIfNeeded()
        setNeedsDisplay()
        return frame
    }
    
    func redoFrameChange(frame: CGRect) {
        oldFrame = self.frame
        UIView.animateWithDuration(0.1, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .CurveEaseInOut, animations: { () -> Void in
            self.frame = frame
            }) { (finished) -> Void in
                self.updateFrameChanges()
        }
    }
    
    func updateFrameChanges() {
        if movableLayer != nil {
            movableLayer?.origin = frame.origin
            if oldFrame != nil {
                undoManager?.prepareWithInvocationTarget(self).redoFrameChange(oldFrame!)
            }
            
            var newSize = frame.size
            movableLayer?.size = newSize.increaseSize(controlLength * (-2))
            saveChanges()
        }
    }

    override func handlePanEnded() {
        super.handlePanEnded()
        updateFrameChanges()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        if isEditing {
            let context = UIGraphicsGetCurrentContext()
            if debugMode {
                for touchRect in getControlRects().values {
                    UIColor.randomColor().colorWithAlphaComponent(0.5).setFill()
                    CGContextFillRect(context, touchRect)
                }
            }
        }
    }

    func saveChanges() {
        DocumentSynchronizer.sharedInstance.updateMovableLayer(movableLayer!)
    }
    
    func setUpSettingsViewController() {
        // empty Base implementation
    }
    
    func setDeselected() {
        // empty Base implementation
    }
    
}
