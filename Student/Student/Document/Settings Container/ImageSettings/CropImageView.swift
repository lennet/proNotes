//
//  CropImageView.swift
//  Student
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

    override func setUpEditMode() {
        setUpPanRecognizer()
    }

    func layout() {
        if let constraint = getConstraint(.Height) {
                layoutIfNeeded()
                let ratio = getImageRatio()

                constraint.constant = (image!.size.height * ratio) + topPadding + bottomPadding
                layoutIfNeeded()
                superview?.layoutIfNeeded()

                overlayRect = getImageRect()
                setNeedsDisplay()
        }
    }

    func getImageRect() -> CGRect {
        return CGRect(x: leftPadding, y: topPadding, width: frame.width - leftPadding - rightPadding, height: frame.height - topPadding - bottomPadding)
    }

    func setUpPanRecognizer() {
        if isEditing {
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
            addGestureRecognizer(panGestureRecognizer)
        } else {
            removeAllGestureRecognizer()
        }
    }

    override func handlePanTranslation(translation: CGPoint) -> CGRect{
        let newOverlayRect = super.handlePanTranslation(translation)

        let imageRect = getImageRect()
        
        overlayRect.origin.x = between(newOverlayRect.origin.x, min: imageRect.origin.x, max: CGRectGetMaxX(imageRect))
        overlayRect.origin.y = between(newOverlayRect.origin.y, min: imageRect.origin.y, max: CGRectGetMaxY(imageRect))
        overlayRect.size.width = between(newOverlayRect.width, min: controlLength * 2, max: imageRect.width)
        overlayRect.size.height = between(newOverlayRect.height, min: controlLength * 2, max: imageRect.height)
        
        setNeedsDisplay()
        
        return newOverlayRect

    }

    func convertToImageRect(var rect: CGRect, ratio: CGFloat) -> CGRect {
        rect.origin.x /= ratio
        rect.origin.y /= ratio
        rect.size.width /= ratio
        rect.size.height /= ratio
        return rect
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
    
    override func drawRect(rect: CGRect) {
        let imageRect = getImageRect()
        let lineWidth: CGFloat = 2

        // TODO only redraw images on changes
        image?.drawInRect(imageRect)

        if isEditing {
            let borderPath = UIBezierPath(rect: imageRect)
            borderPath.lineWidth = lineWidth
            UIColor.lightGrayColor().setStroke()

            let controlLineWidth = lineWidth * 2
            let controlPath = UIBezierPath()

            // Top Left Corner
            controlPath.moveToPoint(CGPoint(x: overlayRect.origin.x, y: overlayRect.origin.y + controlLength))
            controlPath.addLineToPoint(overlayRect.origin)
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x + controlLength, y: overlayRect.origin.y))

            // Bottom Left Corner
            controlPath.moveToPoint(CGPoint(x: overlayRect.origin.x, y: overlayRect.height + overlayRect.origin.y - controlLength))
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x, y: overlayRect.height + overlayRect.origin.y))
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x + controlLength, y: overlayRect.height + overlayRect.origin.y))

            // Top Right Corner
            controlPath.moveToPoint(CGPoint(x: overlayRect.origin.x + overlayRect.width - controlLength, y: overlayRect.origin.y))
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x + overlayRect.width, y: overlayRect.origin.y))
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x + overlayRect.width, y: overlayRect.origin.y + controlLength))

            // Bottom Right Corner
            controlPath.moveToPoint(CGPoint(x: overlayRect.origin.x + overlayRect.width - controlLength, y: overlayRect.origin.y + overlayRect.height))
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x + overlayRect.width, y: overlayRect.origin.y + overlayRect.height))
            controlPath.addLineToPoint(CGPoint(x: overlayRect.origin.x + overlayRect.width, y: overlayRect.origin.y - controlLength + overlayRect.height))

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
