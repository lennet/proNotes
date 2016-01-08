//
//  PagesTableViewController.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PagesTableViewController: UITableViewController, DocumentSynchronizerDelegate {

    static var sharedInstance: PagesTableViewController?

    var shouldReload = true

    var document: Document? {
        didSet {
            if shouldReload {
                loadTableView()
            } else {
                shouldReload = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 500.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.panGestureRecognizer.minimumNumberOfTouches = 2
        DocumentSynchronizer.sharedInstance.addDelegate(self)
        document = DocumentSynchronizer.sharedInstance.document
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loadTableView()
    }

    deinit {
        DocumentSynchronizer.sharedInstance.removeDelegate(self)
    }

    func loadTableView() {
        tableView.reloadData()
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showPage(pageNumber: Int) {
        let indexPath = NSIndexPath(forRow: pageNumber, inSection: 0)
        DocumentSynchronizer.sharedInstance.currentPage = document?.pages[pageNumber]
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }

    func currentPageView() -> PageView? {
        if let indexPaths = tableView.indexPathsForVisibleRows {
            for indexPath in indexPaths {
                if let cell = tableView.cellForRowAtIndexPath(indexPath) as? PageTableViewCell {
                    return cell.pageView
                }
            }
        }

        return nil
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return document?.getNumberOfPages() ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PageTableViewCell.identifier, forIndexPath: indexPath) as! PageTableViewCell

        if let currentPage = document?.pages[indexPath.row] {
            cell.pageView.page = currentPage
            cell.pageView.setUpLayer()
            cell.pageView.pdfViewDelegate = cell
            cell.tableView = tableView
        }

        cell.layoutIfNeeded()

        return cell

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - DocumentSynchronizerDelegate

    func updateDocument(document: Document, forceReload: Bool) {
        shouldReload = forceReload
        self.document = document
    }

    func currentPageDidChange(page: DocumentPage) {
    }

}
