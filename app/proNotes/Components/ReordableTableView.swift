//
//  ReordableTableView.swift
//  proNotes
//
//  Created by Leo Thomas on 16/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

protocol ReordableTableViewDelegate: class {
    func didSwapElements(_ firstIndex: Int, secondIndex: Int)
    func finishedSwappingElements()
}

class ReordableTableView: UITableView {

    weak var reordableDelegate: ReordableTableViewDelegate?
    
    private var sourceIndexPath: IndexPath?
    private weak var currentSnapShowView: UIView?

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUp() {
        layoutIfNeeded()
        if (forceTouchAvailable || PagesTableViewController.sharedInstance?.view.forceTouchAvailable ?? false) && UIDevice.current.userInterfaceIdiom == .phone {
            let forceTouchRecongizer = DeepTouchGestureRecognizer(target: self, action: #selector(ReordableTableView.handleForceTouch(_:)), threshold: 0.4)
            addGestureRecognizer(forceTouchRecongizer)
        } else {
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ReordableTableView.handleLongPress(_:)))
            addGestureRecognizer(longPressRecognizer)
        }
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.location(in: self)
        switch gestureRecognizer.state {
        case .began:
            handleTouchBegan(location)
            break
        case .changed:
            handleTouchChanged(location)
            break
        default:
            handleTouchEnded()
            break
        }
    }
    
    @objc func handleForceTouch(_ gestureRecognizer: DeepTouchGestureRecognizer) {
        let location = gestureRecognizer.location(in: self)
        switch gestureRecognizer.state {
        case .began:
            handleTouchBegan(location, force: gestureRecognizer.forceValue)
            break
        case .changed:
            handleTouchChanged(location, force: gestureRecognizer.forceValue)
            break
        default:
            handleTouchEnded()
            break
        }
    }
    
    private func handleTouchBegan(_ touchLocation: CGPoint, force: CGFloat? = nil) {
        guard let indexPath = indexPathForRow(at: touchLocation) else {
            return
        }
        
        guard let cell = cellForRow(at: indexPath) else {
            return
        }
        let currentSnapShowView = cell.toImageView(false)
        currentSnapShowView.center = cell.center
        currentSnapShowView.alpha = 0
        addSubview(currentSnapShowView)
        self.currentSnapShowView = currentSnapShowView
        let transformValue: CGFloat = force != nil ? 1 + (0.1 * force!) : 1.05
        UIView.animate(withDuration: standardAnimationDuration, animations: {
            () -> Void in
            self.currentSnapShowView?.transform = CGAffineTransform(scaleX: transformValue, y: transformValue)
            self.currentSnapShowView?.alpha = 0.98
            cell.alpha = 0
            }, completion: {
                (Bool) -> Void in
                cell.isHidden = true
        })
        sourceIndexPath = indexPath
    }
    
    private func handleTouchChanged(_ touchLocation: CGPoint, force: CGFloat? = nil) {
        currentSnapShowView?.center.y = touchLocation.y
        guard let currentIndexPath = indexPathForRow(at: touchLocation), let oldIndexPath = sourceIndexPath else {
            return
        }
        if let forceValue = force {
            let transformValue: CGFloat = 1 + (0.1 * forceValue)
            self.currentSnapShowView?.transform = CGAffineTransform(scaleX: transformValue, y: transformValue)
        }
        if currentIndexPath != oldIndexPath {
            reordableDelegate?.didSwapElements((oldIndexPath as NSIndexPath).row, secondIndex: (currentIndexPath as NSIndexPath).row)
            moveRow(at: oldIndexPath, to: currentIndexPath)
            sourceIndexPath = currentIndexPath
        }
    }
    
    private func handleTouchEnded() {
        guard let indexPath = sourceIndexPath, let cell = cellForRow(at: indexPath) else {
            return
        }
        
        cell.isHidden = false
        cell.alpha = 0
        
        UIView.animate(withDuration: standardAnimationDuration, animations: {
            () -> Void in
            self.currentSnapShowView?.center = cell.center
            self.currentSnapShowView?.transform = CGAffineTransform.identity
            self.currentSnapShowView?.alpha = 0
            cell.alpha = 1
            }, completion: {
                (Bool) -> Void in
                self.sourceIndexPath = nil
                self.currentSnapShowView?.removeFromSuperview()
        })
        reloadData()
        reordableDelegate?.finishedSwappingElements()
    }
    
}
