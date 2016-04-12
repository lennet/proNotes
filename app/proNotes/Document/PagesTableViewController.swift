//
//  PagesTableViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PagesTableViewController: UIViewController, DocumentInstanceDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
   
   weak static var sharedInstance: PagesTableViewController?
   
   private let defaultMargin: CGFloat = 10
   private var pageUpdateEnabled = true
   private var documentViewController: DocumentViewController? {
      get {
         return parentViewController as? DocumentViewController
      }
   }
   
   @IBOutlet weak var tableView: UITableView!
   @IBOutlet weak var scrollView: UIScrollView!
   @IBOutlet weak var tableViewWidth: NSLayoutConstraint!
   
   weak var currentPageView: PageView? {
      didSet {
         guard oldValue?.page != currentPageView?.page else {
            return
         }
         let isSketchMode = documentViewController?.isSketchMode ?? false

         oldValue?.selectedSubView = nil
         if  isSketchMode {
            currentPageView?.handleSketchButtonPressed()
         }
         
         DocumentInstance.sharedInstance.currentPage = currentPageView?.page
      }
   }
   
   var twoTouchesForScrollingRequired = false {
      didSet {
         if twoTouchesForScrollingRequired {
            tableView.panGestureRecognizer.minimumNumberOfTouches = 2
            scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
         } else {
            tableView.panGestureRecognizer.minimumNumberOfTouches = 1
            scrollView.panGestureRecognizer.minimumNumberOfTouches = 1
         }
      }
   }
   
   var document: Document? {
      get {
         return DocumentInstance.sharedInstance.document
      }
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      setUpTableView()
      loadTableView()
   }
   
   override func viewWillAppear(animated: Bool) {
      super.viewWillAppear(animated)
      DocumentInstance.sharedInstance.addDelegate(self)
   }
   
   override func viewDidAppear(animated: Bool) {
      super.viewDidAppear(animated)
      setUpScrollView()
   }
   
   override func viewWillDisappear(animated: Bool) {
      super.viewWillDisappear(animated)
      DocumentInstance.sharedInstance.removeDelegate(self)
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
      guard tableView.bounds.width != 0 else {
         return 
      }
      let minZoomScale = scrollView.bounds.width / tableView.bounds.width * 0.9
      scrollView.minimumZoomScale = minZoomScale
      scrollView.maximumZoomScale = minZoomScale * 5
      scrollView.zoomScale = minZoomScale
      scrollView.deactivateDelaysContentTouches()
      scrollView.showsVerticalScrollIndicator = false
      scrollView.alpha = 1
   }
   
   func setUpTableView() {
      tableViewWidth?.constant = (document?.getMaxWidth() ?? 0) + 2 * defaultMargin
      tableView.deactivateDelaysContentTouches()
      
      view.layoutSubviews()
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   func scroll(down: Bool) {
      var newYContentOffset = tableView.contentOffset.y + 75 * (down ? 1 : -1)
      newYContentOffset = max(0, newYContentOffset)
      newYContentOffset = min(tableView.contentSize.height - tableView.bounds.height , newYContentOffset)
      tableView.setContentOffset(CGPoint(x: 0, y: newYContentOffset), animated: true)
   }
   
   // MARK: - Screen Rotation
   
   override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
      layoutDidChange()
   }
   
   override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
      coordinator.animateAlongsideTransition({
         (context) -> Void in
         self.layoutDidChange()
      }) {
         (context) -> Void in
      }
   }
   
   override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
      
   }
   
   // MARK: - Page Handling
   
   func showPage(pageNumber: Int) {
      if pageNumber < tableView.numberOfRowsInSection(0) {
         pageUpdateEnabled = false
         let indexPath = NSIndexPath(forRow: pageNumber, inSection: 0)
         DocumentInstance.sharedInstance.currentPage = document?[pageNumber]
         tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
      }
   }
   
   private func getVisiblePageView() -> PageView? {
      if let indexPaths = tableView.indexPathsForVisibleRows {
         for indexPath in indexPaths {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? PageTableViewCell {
               return cell.pageView
            }
         }
      }
      
      return nil
   }
   
   func swapPagePositions(firstIndex: Int, secondIndex: Int) {
      let pagesCount = document?.pages.count ?? 0
      if firstIndex != secondIndex && firstIndex >= 0 && secondIndex >= 0 && firstIndex < pagesCount && secondIndex < pagesCount {
         tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: firstIndex, inSection: 0), NSIndexPath(forRow: secondIndex, inSection: 0)], withRowAnimation: .Automatic)
      } else {
         print("Swap Layerpositions failed with firstIndex:\(firstIndex) and secondIndex\(secondIndex) and pagesCount \(pagesCount)")
      }
   }
   
   // MARK: - Table view data source
   
   func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return 1
   }
   
   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return document?.getNumberOfPages() ?? 0
   }
   
   func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      let pageHeight = (document?[indexPath.row]?.size.height ?? 0)
      return pageHeight + 2 * defaultMargin
   }
   
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier(PageTableViewCell.identifier, forIndexPath: indexPath) as! PageTableViewCell
      
      cell.layer.setUpDefaultShaddow()
      
      if let currentPage = document?[indexPath.row] {
         cell.widthConstraint?.constant = currentPage.size.width
         cell.heightConstraint?.constant = currentPage.size.height
         cell.pageView.page = currentPage
         cell.pageView.setUpLayer()
         cell.tableView = tableView
      }
      
      cell.layoutIfNeeded()
      
      return cell
      
   }
   
   func layoutTableView() {
      
      let size = scrollView.bounds.size
      var centredFrame = tableView.frame
      
      centredFrame.origin.x = centredFrame.size.width < size.width ? (size.width - centredFrame.size.width) / 2 : 0
      
      centredFrame.origin.y = centredFrame.size.height < size.height ? (size.height - centredFrame.size.height) / 2 : 0
      
      tableView.frame = centredFrame
      updateTableViewHeight()
   }
   
   func updateTableViewHeight() {
      var frame = tableView.frame
      frame.size.height = max(scrollView.bounds.height, scrollView.contentSize.height)
      tableView.frame = frame
      scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: tableView.bounds.height)
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
      // disable vertical scrolling for ZoomingScrollView
      if (self.scrollView.contentOffset.y != 0) {
         self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentOffset.x, y: 0);
      }
      
      if pageUpdateEnabled {
         currentPageView = getVisiblePageView()
      }
   }
   
   func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
      pageUpdateEnabled = true
      currentPageView = getVisiblePageView()
   }
   
   // MARK: - DocumentSynchronizerDelegate
   
   func didAddPage(index: NSInteger) {
      if index < tableView.numberOfRowsInSection(0) {
         let indexPath = NSIndexPath(forRow: index, inSection: 0)
         tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
      } else {
         tableView.reloadData()
      }
   }
   
}
