//
//  PagesOverviewTableViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PagesOverviewTableViewController: UITableViewController, DocumentInstanceDelegate, ReordableTableViewDelegate {

    var document: Document? {
        get {
            return DocumentInstance.sharedInstance.document
        }
    }
    
    var currentVisibleIndex = 0 {
        didSet {
            let oldIndexPath = NSIndexPath(forRow: oldValue, inSection: 0)
            let newIndexPath = NSIndexPath(forRow: currentVisibleIndex, inSection: 0)
            tableView.reloadRowsAtIndexPaths([newIndexPath, oldIndexPath], withRowAnimation: .None)
        }
    }

    weak var pagesOverViewDelegate: PagesOverviewTableViewCellDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        (tableView as? ReordableTableView)?.reordableDelegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        DocumentInstance.sharedInstance.addDelegate(self)
        tableView.reloadData()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        DocumentInstance.sharedInstance.removeDelegate(self)
    }

    // MARK: - ReordableTableViewDelegate

    func didSwapElements(firstIndex: Int, secondIndex: Int) {
        document?.swapPagePositions(firstIndex, secondIndex: secondIndex)
        PagesTableViewController.sharedInstance?.swapPagePositions(firstIndex, secondIndex: secondIndex)
        DocumentInstance.sharedInstance.flushUndoManager()
    }
    
    func finishedSwappingElements() {
        document?.updateChangeCount(.Done)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return document?.getNumberOfPages() ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PagesOverviewTableViewCell.identifier, forIndexPath: indexPath) as! PagesOverviewTableViewCell
        let highlighted = indexPath.row == currentVisibleIndex
        cell.numberLabel.textColor = highlighted ? UIColor.blackColor() : UIColor.lightGrayColor()
        cell.index = indexPath.row
        cell.delegate = pagesOverViewDelegate
        if let page = document?[indexPath.row] {
            let thumbSize = page.size.sizeToFit(CGSize(width: 100, height: 100))
            cell.pageThumbViewHeightConstraint.constant = thumbSize.height * (highlighted ? 1.1 : 1)
            cell.pageThumbViewWidthConstraint.constant = thumbSize.width * (highlighted ? 1.1 : 1)
            let image = page.previewImage
            cell.pageThumbView.setBackgroundImage(image, forState: .Normal)
        }
        
        if highlighted {
            cell.pageThumbView.layer.setUpHighlitedShadow()
        } else {
            cell.pageThumbView.layer.setUpDefaultShaddow()
        }
        
        return cell
    }

    // MARK: - DocumentInstanceDelegate

    func didAddPage(index: Int) {
        if index < tableView.numberOfRowsInSection(0) {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else {
            tableView.reloadData()
        }
    }
    
    func didUpdatePage(index: Int) {
        document?.pages[index].removePreviewImage()
        if index < tableView.numberOfRowsInSection(0) {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }
    }
    
    func currentPageDidChange(page: DocumentPage) {
        currentVisibleIndex = page.index
    }

}
