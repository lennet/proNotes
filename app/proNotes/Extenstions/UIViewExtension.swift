//
//  UIViewExtension.swift
//  proNotes
//
//  Created by Leo Thomas on 11/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

extension UIView {

    // MARK - AutoLayout

    func getConstraint(attribute: NSLayoutAttribute) -> NSLayoutConstraint? {
        for constraint in constraints {
            if constraint.firstAttribute == attribute {
                return constraint
            }
        }
        return nil
    }

    func deactivateConstraints() {
        for constraint in constraints {
            self.removeConstraint(constraint)
        }
    }

    // MARK: - UITouch

    var forceTouchAvailable: Bool {
        return traitCollection.forceTouchCapability == .Available
    }

    // MARK: - Sub/ Parentviews

    func setSubviewsAlpha(startIndex: Int, alphaValue: CGFloat) {
        let transparentSubviews = subviews[startIndex ..< subviews.count]
        for subview in transparentSubviews {
            subview.alpha = alphaValue
        }
    }

    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.nextResponder()
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }

    // MARK: - Snapshot

    func toImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0);
        self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshot
    }

    func toImageView() -> UIView {
        let snapshotView = UIImageView(image: toImage())
        snapshotView.layer.masksToBounds = false
        snapshotView.layer.shadowOffset = CGSizeMake(-5, 0)
        snapshotView.layer.shadowRadius = 5
        snapshotView.layer.shadowOpacity = 0.4
        return snapshotView
    }

    // MARK: - Gesture Recognizer

    func removeAllGestureRecognizer() {
        if gestureRecognizers != nil {
            for recognizer in gestureRecognizers! {
                removeGestureRecognizer(recognizer)
            }
        }
    }

    func deactivateDelaysContentTouches() {
        for case let scrollView as UIScrollView in self.subviews {
            scrollView.delaysContentTouches = false
        }


        (self as? UIScrollView)?.delaysContentTouches = false
    }

}
