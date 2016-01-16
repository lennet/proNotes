//
//  PagesTableViewController.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PagesTableViewController: UIViewController, DocumentSynchronizerDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {

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
        setUpTableView()
        loadTableView()
        setUpScrollView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setUpScrollView()
        // FIXME doubled setUpScrollView call && animated Appearance beacuse of a layouting bug 
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 5, options: .CurveEaseInOut, animations: {
            () -> Void in
            self.scrollView.alpha = 1
            }, completion: nil)
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
        layoutDidChange()
    }
    
    func setUpScrollView() {
        let minZoomScale = scrollView.bounds.width/tableView.bounds.width*0.9
        print(minZoomScale)
        scrollView.minimumZoomScale = minZoomScale
        scrollView.maximumZoomScale = minZoomScale*5
        scrollView.zoomScale = minZoomScale
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
    }
    
    func setUpTableView() {
//        tableView = UITableView(frame: CGRect(origin: CGPointZero, size: CGSize.dinA4())) //TODO add default padding
//        tableView.dataSource = self
//        tableView.delegate = self
//        scrollView.addSubview(tableView)
        
        tableViewWidth?.constant = CGSize.dinA4().width;
        view.layoutSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func scroll(down: Bool) {
        tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentOffset.y+75*(down ? 1 : -1)), animated: true)
    }
    
    // MARK: - Screen Rotation
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        layoutDidChange()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ (context) -> Void in
                self.layoutDidChange()
            }) { (context) -> Void in

        }

    }
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {

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
        
        tableView.frame = centredFrame
        updateTableViewHeight()
    }
    
    func updateTableViewHeight() {
        var frame = tableView.frame
        frame.size.height = scrollView.bounds.height
        tableView.frame = frame
    }
    
    func layoutDidChange() {
        layoutTableView()
        var frame = tableView.frame
        frame.origin = CGPoint(x: frame.origin.x, y: 0)
        tableView.frame = frame
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return tableView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        layoutDidChange()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // only update tableview height if scrollview is'nt bouncing
        if !(scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.height
            && scrollView.contentSize.height > scrollView.bounds.height) && !(scrollView.contentOffset.y < 0) {
            updateTableViewHeight()
        }
    }
    
    // MARK: - DocumentSynchronizerDelegate

    func updateDocument(document: Document, forceReload: Bool) {
        shouldReload = forceReload
        self.document = document
    }

    func currentPageDidChange(page: DocumentPage) {
    }

}
