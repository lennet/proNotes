//
//  CropImageView.swift
//  proNotes
//
//  Created by Leo Thomas on 02/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit


@IBDesignable
class CropImageView: TouchControlView {

    // TODO implement maxHeight

    var image: UIImage? {
        didSet {
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

    var overlayRect: CGRect = CGRectZero
    var animateLayoutChanges = true
    
    override var movable: Bool {
        get {
            return true
        }
    }
    
    override var controlLineWidth: CGFloat {
        get {
            return 4
        }
    }
    
    override func setUpEditMode() {
        setUpPanRecognizer()
    }

    func layout() {
        if let constraint = getConstraint(.Height) {
            layoutIfNeeded()
            let ratio = getImageRatio()

            constraint.constant = (image!.size.height * ratio) + topPadding + bottomPadding

            UIView.animateWithDuration((animateLayoutChanges ? standardAnimationDuration : 0), delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 5, options: .CurveEaseInOut, animations: {
                () -> Void in
                self.layoutIfNeeded()
                self.superview?.layoutIfNeeded()
            }, completion: nil)

            overlayRect = getImageRect()
            setNeedsDisplay()
        }
    }

    func getImageRect() -> CGRect {
        return CGRect(x: leftPadding, y: topPadding, width: frame.width - leftPadding - rightPadding, height: frame.height - topPadding - bottomPadding)
    }

    func setUpPanRecognizer() {
        if isEditing {
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(TouchControlView.handlePan(_:)))
            addGestureRecognizer(panGestureRecognizer)
        } else {
            removeAllGestureRecognizer()
        }
    }

    override func handlePanTranslation(translation: CGPoint) -> CGRect {
        let newOverlayRect = super.handlePanTranslation(translation)

        let imageRect = getImageRect()

        overlayRect.size.width = between(newOverlayRect.width, min: controlLength * 2, max: imageRect.width)
        overlayRect.size.height = between(newOverlayRect.height, min: controlLength * 2, max: imageRect.height)
        overlayRect.origin.x = between(newOverlayRect.origin.x, min: imageRect.origin.x, max: CGRectGetMaxX(imageRect))
        overlayRect.origin.y = between(newOverlayRect.origin.y, min: imageRect.origin.y, max: CGRectGetMaxY(imageRect))
        
        let widthOffSet = CGRectGetMaxX(overlayRect) - CGRectGetMaxX(imageRect)
        if widthOffSet > 0 {
            overlayRect.size.width -= widthOffSet
        }
        let heigthOffSet = CGRectGetMaxY(overlayRect) - CGRectGetMaxY(imageRect)
        if heigthOffSet > 0 {
            overlayRect.size.height -= heigthOffSet
        }

        setNeedsDisplay()

        return newOverlayRect
    }

    func convertToImageRect(rect: CGRect, ratio: CGFloat) -> CGRect {
        var newRect = rect
        newRect.origin.x /= ratio
        newRect.origin.y /= ratio
        newRect.size.width /= ratio
        newRect.size.height /= ratio
        return newRect
    }

    func getImageRatio() -> CGFloat {
        if image != nil {
            let width = bounds.width - leftPadding - rightPadding
            let ratio = width / image!.size.width
            return ratio
        }
        return 0
    }

    func crop() {
        let newImageRect = convertToImageRect(CGRect(origin: CGPoint(x: overlayRect.origin.x - leftPadding, y: overlayRect.origin.y - topPadding), size: overlayRect.size), ratio: getImageRatio())
        isEditing = false
        image = image?.cropedImage(newImageRect)
        layout()
    }

    override func getControllableRect() -> CGRect {
        return overlayRect
    }

    override func getMovableRect() -> CGRect {
        return overlayRect
    }
    
    override func getDrawRect() -> CGRect {
        return overlayRect
    }

    override func drawRect(rect: CGRect) {
        let imageRect = getImageRect()
        image?.drawInRect(imageRect)

        if isEditing {
            super.drawRect(rect)

            let borderPath = UIBezierPath(rect: overlayRect)
            borderPath.lineWidth = controlLineWidth/2
            borderPath.stroke()
            
            if !CGRectEqualToRect(overlayRect, imageRect) {
                let overlayPath = UIBezierPath(rect: imageRect)
                overlayPath.appendPath(UIBezierPath(rect: overlayRect).bezierPathByReversingPath())
                overlayPath.fillWithBlendMode(.Darken, alpha: 0.5)
            }
        }
    }

}
