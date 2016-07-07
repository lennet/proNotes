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
            let oldIndexPath = IndexPath(row: oldValue, section: 0)
            let newIndexPath = IndexPath(row: currentVisibleIndex, section: 0)
            tableView.reloadRows(at: [newIndexPath, oldIndexPath], with: .none)
        }
    }

    weak var pagesOverViewDelegate: PagesOverviewTableViewCellDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.accessibilityIdentifier = "PagesOverViewTableView"
        
        (tableView as? ReordableTableView)?.reordableDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tableView as? ReordableTableView)?.setUp()
        DocumentInstance.sharedInstance.addDelegate(self)
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DocumentInstance.sharedInstance.removeDelegate(self)
    }

    // MARK: - ReordableTableViewDelegate

    func didSwapElements(_ firstIndex: Int, secondIndex: Int) {
        document?.swapPagePositions(firstIndex, secondIndex: secondIndex)
        PagesTableViewController.sharedInstance?.swapPages(withfirstIndex: firstIndex, secondIndex: secondIndex)
        DocumentInstance.sharedInstance.flushUndoManager()
    }
    
    func finishedSwappingElements() {
        document?.updateChangeCount(.done)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return document?.numberOfPages ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PagesOverviewTableViewCell.identifier, for: indexPath) as! PagesOverviewTableViewCell
        let highlighted = (indexPath as NSIndexPath).row == currentVisibleIndex
        cell.numberLabel.textColor = highlighted ? UIColor.black() : UIColor.lightGray()
        cell.index = (indexPath as NSIndexPath).row
        cell.delegate = pagesOverViewDelegate
        if let page = document?[(indexPath as NSIndexPath).row] {
            let thumbSize = page.size.sizeToFit(CGSize(width: 100, height: 100))
            cell.pageThumbViewHeightConstraint.constant = thumbSize.height * (highlighted ? 1.1 : 1)
            cell.pageThumbViewWidthConstraint.constant = thumbSize.width * (highlighted ? 1.1 : 1)
            let image = page.previewImage
            cell.pageThumbView.setBackgroundImage(image, for: UIControlState())
        }
        
        if highlighted {
            cell.pageThumbView.layer.setUpHighlitedShadow()
        } else {
            cell.pageThumbView.layer.setUpDefaultShaddow()
        }
        
        return cell
    }

    // MARK: - DocumentInstanceDelegate

    func didAddPage(_ index: Int) {
        if index < tableView.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.insertRows(at: [indexPath], with: .fade)
        } else {
            tableView.reloadData()
        }
    }
    
    func didUpdatePage(_ index: Int) {
        document?.pages[index].removePreviewImage()
        if index < tableView.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func currentPageDidChange(_ page: DocumentPage) {
        currentVisibleIndex = page.index
    }

}
