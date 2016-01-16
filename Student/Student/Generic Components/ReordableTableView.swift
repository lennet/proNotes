//
//  ReordableTableView.swift
//  Student
//
//  Created by Leo Thomas on 16/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

protocol ReordableTableViewDelegate {
    func didSwapElements(firstIndex: Int, secondIndex: Int)
}

class ReordableTableView: UITableView {

    var currentSnapShowView: UIView = UIView()
    var sourceIndexPath: NSIndexPath?
    
    var reordableDelegate: ReordableTableViewDelegate?
    
    override func awakeFromNib() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
        addGestureRecognizer(longPressRecognizer)
    }
    
    // Inspired by http://www.raywenderlich.com/63089/cookbook-moving-table-view-cells-with-a-long-press-gesture
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.locationInView(self)
        guard let indexPath = indexPathForRowAtPoint(location) else {
            return
        }
        
        switch gestureRecognizer.state {
        case .Began:
            sourceIndexPath = indexPath
            guard let cell = cellForRowAtIndexPath(indexPath) else {
                return
            }
            currentSnapShowView = cell.snapshotView()
            var center = cell.center
            currentSnapShowView.center = center
            currentSnapShowView.alpha = 0
            addSubview(currentSnapShowView)
            UIView.animateWithDuration(0.25, animations: {
                () -> Void in
                center.y = location.y
                self.currentSnapShowView.center = center
                self.currentSnapShowView.transform = CGAffineTransformMakeScale(1.05, 1.05)
                self.currentSnapShowView.alpha = 0.98
                cell.alpha = 0
                }, completion: {
                    (Bool) -> Void in
                    cell.hidden = true
            })
            break
        case .Changed:
            var center = currentSnapShowView.center
            center.y = location.y
            currentSnapShowView.center = center
            if !indexPath.isEqual(sourceIndexPath) {
                // TODO move changes to extra method
                reordableDelegate?.didSwapElements((sourceIndexPath?.row)!, secondIndex: indexPath.row)
                moveRowAtIndexPath(sourceIndexPath!, toIndexPath: indexPath)
                sourceIndexPath = indexPath
            }
            break
        default:
            let cell = cellForRowAtIndexPath(sourceIndexPath!)
            cell?.hidden = false
            cell?.alpha = 0
            UIView.animateWithDuration(0.25, animations: {
                () -> Void in
                self.currentSnapShowView.center = cell?.center ?? self.currentSnapShowView.center
                self.currentSnapShowView.transform = CGAffineTransformIdentity
                self.currentSnapShowView.alpha = 0
                cell?.alpha = 1
                }, completion: {
                    (Bool) -> Void in
                    self.sourceIndexPath = nil
                    self.currentSnapShowView.removeFromSuperview()
                    self.currentSnapShowView = UIView()
            })
            reloadData()
            break
        }
    }
}
