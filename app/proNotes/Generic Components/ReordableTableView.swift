//
//  ReordableTableView.swift
//  proNotes
//
//  Created by Leo Thomas on 16/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

protocol ReordableTableViewDelegate: class {
    func didSwapElements(firstIndex: Int, secondIndex: Int)
}

class ReordableTableView: UITableView {

    weak var reordableDelegate: ReordableTableViewDelegate?
    
    private var sourceIndexPath: NSIndexPath?
    private weak var currentSnapShowView: UIView?

    override func awakeFromNib() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ReordableTableView.handleLongPress(_:)))
        addGestureRecognizer(longPressRecognizer)
    }

    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.locationInView(self)
        switch gestureRecognizer.state {
        case .Began:
            handleTouchBegan(location)
            break
        case .Changed:
            handleTouchChanged(location)
            break
        default:
            handleTouchEnded()
            break
        }
    }
    
    private func handleTouchBegan(touchLocation: CGPoint) {
        guard let indexPath = indexPathForRowAtPoint(touchLocation) else {
            return
        }
        
        guard let cell = cellForRowAtIndexPath(indexPath) else {
            return
        }
        let currentSnapShowView = cell.toImageView(false)
        currentSnapShowView.center = cell.center
        currentSnapShowView.alpha = 0
        addSubview(currentSnapShowView)
        self.currentSnapShowView = currentSnapShowView
        UIView.animateWithDuration(standardAnimationDuration, animations: {
            () -> Void in
            self.currentSnapShowView?.transform = CGAffineTransformMakeScale(1.05, 1.05)
            self.currentSnapShowView?.alpha = 0.98
            cell.alpha = 0
            }, completion: {
                (Bool) -> Void in
                cell.hidden = true
        })
        sourceIndexPath = indexPath
    }
    
    private func handleTouchChanged(touchLocation: CGPoint) {
        currentSnapShowView?.center.y = touchLocation.y
        guard let currentIndexPath = indexPathForRowAtPoint(touchLocation), let oldIndexPath = sourceIndexPath else {
            return
        }
        if !currentIndexPath.isEqual(oldIndexPath) {
            reordableDelegate?.didSwapElements(oldIndexPath.row, secondIndex: currentIndexPath.row)
            moveRowAtIndexPath(oldIndexPath, toIndexPath: currentIndexPath)
            sourceIndexPath = currentIndexPath
        }
    }
    
    private func handleTouchEnded() {
        guard let indexPath = sourceIndexPath, let cell = cellForRowAtIndexPath(indexPath) else {
            return
        }
        
        cell.hidden = false
        cell.alpha = 0
        
        UIView.animateWithDuration(standardAnimationDuration, animations: {
            () -> Void in
            self.currentSnapShowView?.center = cell.center
            self.currentSnapShowView?.transform = CGAffineTransformIdentity
            self.currentSnapShowView?.alpha = 0
            cell.alpha = 1
            }, completion: {
                (Bool) -> Void in
                self.sourceIndexPath = nil
                self.currentSnapShowView?.removeFromSuperview()
        })
        reloadData()
    }
    
}
