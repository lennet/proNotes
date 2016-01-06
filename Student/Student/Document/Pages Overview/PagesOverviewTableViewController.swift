//
//  PagesOverviewTableViewController.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PagesOverviewTableViewController: UITableViewController, DocumentSynchronizerDelegate {

    var shouldReload = true

    var document: Document? = DocumentSynchronizer.sharedInstance.document {
        didSet {
            if shouldReload {
                tableView.reloadData()
            } else {
                shouldReload = true
            }
        }
    }

    var pagesOverViewDelegate: PagesOverviewTableViewCellDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        DocumentSynchronizer.sharedInstance.addDelegate(self)
    }

    deinit {
        DocumentSynchronizer.sharedInstance.removeDelegate(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

        cell.numberLabel.text = String(indexPath.row + 1)
        cell.index = indexPath.row
        cell.delegate = pagesOverViewDelegate

        return cell
    }

    // MARK: - DocumentSynchronizerDelegate
    func updateDocument(document: Document, forceReload: Bool) {
        shouldReload = forceReload
        self.document = document
    }

    func currentPageDidChange(page: DocumentPage) {
    }
}
