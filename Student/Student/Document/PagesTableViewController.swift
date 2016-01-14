//
//  PagesTableViewController.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PagesTableViewController: UIViewController, DocumentSynchronizerDelegate, UIScrollViewDelegate {

    static var sharedInstance: PagesTableViewController?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var shouldReload = true
    @IBOutlet weak var tableViewWidth: NSLayoutConstraint?

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
        tableView.panGestureRecognizer.minimumNumberOfTouches = 2
        DocumentSynchronizer.sharedInstance.addDelegate(self)
        document = DocumentSynchronizer.sharedInstance.document
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUpTableView()
        setUpScrollView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setUpTableView()
        loadTableView()
        print(tableView.frame)
    }

    deinit {
        DocumentSynchronizer.sharedInstance.removeDelegate(self)
    }

    func loadTableView() {
        tableView.reloadData()
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.reloadData()
        layoutTableView()
    }
    
    func setUpScrollView() {
        scrollView.minimumZoomScale = 0.3
        scrollView.maximumZoomScale = 8
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
    }
    
    func setUpTableView() {
        tableViewWidth?.constant = CGSize.dinA4().width;
        view.layoutSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Screen Rotation
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        layoutTableView()
    }
    
    // MARK: - Page Handling
    
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

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return document?.getNumberOfPages() ?? 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UIScreen.mainScreen().bounds.size.height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PageTableViewCell.identifier, forIndexPath: indexPath) as! PageTableViewCell

        if let currentPage = document?.pages[indexPath.row] {
            cell.widthConstraint?.constant = currentPage.size.width
            cell.heightConstraint?.constant = currentPage.size.height
            cell.pageView.page = currentPage
            cell.pageView.setUpLayer()
            cell.pageView.pdfViewDelegate = cell
            cell.tableView = tableView
        }

        cell.layoutIfNeeded()

        return cell

    }

    func layoutTableView() {
        
        let size = scrollView.bounds.size
        var centredFrame = tableView.frame
        
        centredFrame.origin.x = centredFrame.size.width < size.width ? (size.width-centredFrame.size.width)/2 : 0
        
        centredFrame.origin.y = centredFrame.size.height < size.height ? (size.height-centredFrame.size.height)/2 : 0
        
        centredFrame.size.height = scrollView.bounds.height
        
        tableView.frame = centredFrame
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return tableView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        layoutTableView()
    }
    
    // MARK: - DocumentSynchronizerDelegate

    func updateDocument(document: Document, forceReload: Bool) {
        shouldReload = forceReload
        self.document = document
    }

    func currentPageDidChange(page: DocumentPage) {
    }

}
