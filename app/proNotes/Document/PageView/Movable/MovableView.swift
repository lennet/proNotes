//
//  MovableView.swift
//  proNotes
//
//  Created by Leo Thomas on 06/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class MovableView: TouchControlView, PageSubView {

    var movableLayer: MovableLayer!
    private let debugMode = false
    private var renderMode = false

    init(frame: CGRect, movableLayer: MovableLayer, renderMode: Bool = false) {
        self.movableLayer = movableLayer
        let newControlLength: CGFloat = 44

        super.init(frame: CGRect(origin: frame.origin, size: CGSize(width: frame.size.width + newControlLength, height: frame.size.height + newControlLength)))
        controlLength = newControlLength
        isUserInteractionEnabled = false
        self.renderMode = renderMode
        backgroundColor = UIColor.clear()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didAddSubview(_ subview: UIView) {
        if !renderMode {
            subview.translatesAutoresizingMaskIntoConstraints = false
            let leftConstraint = NSLayoutConstraint(item: subview, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: controlLength/2)
            let rightConstraint = NSLayoutConstraint(item: subview, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -controlLength/2)
            let bottomConstraint = NSLayoutConstraint(item: subview, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -controlLength/2)
            let topConstraint = NSLayoutConstraint(item: subview, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: controlLength/2)
            
            addConstraints([leftConstraint, rightConstraint, bottomConstraint, topConstraint])
            layoutIfNeeded()
        } else {
            subview.frame = CGRect(origin: CGPoint(x: controlLength/2, y: controlLength/2), size: CGSize(width: movableLayer.size.width, height: movableLayer.size.height))
        }
    }
    
    // MARK: - Gesture Recognizer

    override func handlePanTranslation(_ translation: CGPoint) -> CGRect {
        frame = super.handlePanTranslation(translation)
        layoutIfNeeded()
        setNeedsDisplay()
        return frame
    }

    func updateFrameChanges() {
        movableLayer.origin = frame.origin
        if movableLayer.docPage != nil && oldFrame != nil {
            DocumentInstance.sharedInstance.registerUndoAction(NSValue(cgRect: oldFrame!), pageIndex: movableLayer.docPage.index, layerIndex: movableLayer.index)
        }

        var newSize = frame.size
        movableLayer.size = newSize.increaseSize(controlLength * (-1))
        saveChanges()
    }

    override func handlePanEnded() {
        super.handlePanEnded()
        updateFrameChanges()
    }
    
    
    override func getDrawRect() -> CGRect {
        return subviews.first?.frame ?? bounds
    }

    override func draw(_ rect: CGRect) {
        if isEditing {
            let context = UIGraphicsGetCurrentContext()
            if debugMode {
                for touchRect in getControlRects().values {
                    UIColor.randomColor().withAlphaComponent(0.5).setFill()
                    context?.fill(touchRect)
                }
            }
            super.draw(rect)
        }
    }

    func saveChanges() {
        let pageIndex = movableLayer.docPage.index
        DocumentInstance.sharedInstance.didUpdatePage(pageIndex)
    }

    func setUpSettingsViewController() {
        // empty Base implementation
    }

    func setSelected() {
        isEditing = true
        isUserInteractionEnabled = true
        setUpSettingsViewController()
        for view in subviews {
            view.isUserInteractionEnabled = true
            view.layer.borderColor = UIColor.lightGray().cgColor
            view.layer.borderWidth = 1
        }
        setNeedsDisplay()
    }
    
    func setDeselected() {
        isEditing = false
        isUserInteractionEnabled = false
        for view in subviews {
            view.isUserInteractionEnabled = true
            view.layer.borderWidth = 0
        }
        SettingsViewController.sharedInstance?.currentSettingsType = .PageInfo
        setNeedsDisplay()
    }

    func undoAction(_ oldObject: AnyObject?) {
        guard let value = oldObject as? NSValue else {
            return
        }
        let frame = value.cgRectValue()
        oldFrame = self.frame
        UIView.animate(withDuration: standardAnimationDuration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions(), animations: {
            () -> Void in
            self.frame = frame
        }, completion: nil)
        updateFrameChanges()
    }
    
}
