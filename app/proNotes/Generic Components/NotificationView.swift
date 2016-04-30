//
//  NotificationView.swift
//  proNotes
//
//  Created by Leo Thomas on 27/04/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class NotificationView: UIView {

    var message: String
    weak var topConstraint: NSLayoutConstraint?
    var tapAction: () -> Void
    
    init(message: String, error: Bool,  tapAction: () -> Void) {
        self.message = message
        self.tapAction = tapAction
        super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 64)))
        backgroundColor = error ? UIColor.PNRedColor() : UIColor.PNIconBlueColor()
        addLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        message = ""
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = NSLayoutConstraint(item: self, attribute: .Left, relatedBy: .Equal, toItem: superview, attribute: .Left, multiplier: 1.0, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: self, attribute: .Right, relatedBy: .Equal, toItem: superview, attribute: .Right, multiplier: 1.0, constant: 0)
        let topConstraint = NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1.0, constant: -64)
        let heightConstraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 64)
        superview?.addConstraints([leftConstraint, rightConstraint, topConstraint, heightConstraint])
        self.topConstraint = topConstraint
        
        layoutIfNeeded()
        superview?.layoutIfNeeded()
        show()
    }
    
    func addLabel() {
        let label = UILabel(frame: CGRect.zero)
        label.text = message
        label.textAlignment = .Center
        label.numberOfLines = 0
        label.textColor = UIColor.whiteColor()
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        let labelCenterX = NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        let labelCenterY = NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: label, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 8)
        let rightConstraint = NSLayoutConstraint(item: label, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 8)
        let topConstraint = NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: -8)
        let bottomConstraint = NSLayoutConstraint(item: label, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 8)
        addConstraints([labelCenterX, labelCenterY, leftConstraint, topConstraint, rightConstraint, bottomConstraint])
        layoutIfNeeded()
    }
    
    func show() {
        topConstraint?.constant = 0
        animateLayoutChanges { (_) in
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NotificationView.handleTap))
            let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(NotificationView.handleSwipe))
            swipeGestureRecognizer.direction = .Up
            self.addGestureRecognizer(swipeGestureRecognizer)
            self.addGestureRecognizer(tapGestureRecognizer)
            NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(NotificationView.hide), userInfo: nil, repeats: false)
        }
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    func hide() {
        topConstraint?.constant = -frame.height
        animateLayoutChanges { (_) in
            self.hidden = true
        }
    }
    
    func animateLayoutChanges(completion: ((Bool) -> Void)?) {
        UIView.animateWithDuration((standardAnimationDuration*3), delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 5, options: .CurveEaseInOut, animations: {
            () -> Void in
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
            }, completion: completion)
    }
    
    func handleTap() {
        hide()
        for recognizer in gestureRecognizers ?? [] {
            removeGestureRecognizer(recognizer)
        }
        tapAction()
    }
    
    func handleSwipe() {
        hide()
        for recognizer in gestureRecognizers ?? [] {
            removeGestureRecognizer(recognizer)
        }
    }
    
}
