//
//  PagesTableViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PagesTableViewController: UIViewController, DocumentInstanceDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
   
   // MARK: - Outlets
   @IBOutlet weak var tableView: UITableView!
   @IBOutlet weak var scrollView: UIScrollView!
   @IBOutlet weak var tableViewWidth: NSLayoutConstraint!
   
   weak static var sharedInstance: PagesTableViewController?
   
   private let defaultMargin: CGFloat = 10
   private var pageUpdateEnabled = true
   private var documentViewController: DocumentViewController? {
      get {
         return parent as? DocumentViewController
      }
   }

   weak var currentPageView: PageView? {
      didSet {
         guard oldValue?.page != currentPageView?.page || forcePageUpdate else {
            return
         }
         let isSketchMode = documentViewController?.isSketchMode ?? false

         oldValue?.selectedSubView = nil
         if isSketchMode {
            currentPageView?.handleSketchButtonPressed()
         }
         
         DocumentInstance.sharedInstance.currentPage = currentPageView?.page
         forcePageUpdate = false
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
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      DocumentInstance.sharedInstance.addDelegate(self)
      updateCurrentPageView()
   }
   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      setUpScrollView()
   }
   
   override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      DocumentInstance.sharedInstance.removeDelegate(self)
   }
   
   private func loadTableView() {
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
   
   private func setUpTableView() {
      tableViewWidth?.constant = (document?.getMaxWidth() ?? 0) + 2 * defaultMargin
      tableView.deactivateDelaysContentTouches()
      
      view.layoutSubviews()
   }
   
   func scroll(_ down: Bool) {
      var newYContentOffset = tableView.contentOffset.y + 75 * (down ? 1 : -1)
      newYContentOffset = max(0, newYContentOffset)
      newYContentOffset = min(tableView.contentSize.height - tableView.bounds.height , newYContentOffset)
      tableView.setContentOffset(CGPoint(x: 0, y: newYContentOffset), animated: true)
   }
   
   // MARK: - Screen Rotation
   
   override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
      layoutDidChange()
   }
   
   override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
      coordinator.animate(alongsideTransition: {
         (context) -> Void in
         self.setUpScrollView()
         self.layoutDidChange()
      }) {
         (context) -> Void in
      }
   }
   
   // MARK: - Page Handling
   
   func showPage(_ pageNumber: Int) {
      if pageNumber < tableView.numberOfRows(inSection: 0) {
         pageUpdateEnabled = false
         let indexPath = IndexPath(row: pageNumber, section: 0)
         DocumentInstance.sharedInstance.currentPage = document?[pageNumber]
         tableView.scrollToRow(at: indexPath, at: .top, animated: true)
      }
   }
   
   private func updateCurrentPageView(_ force: Bool = false) {
      if pageUpdateEnabled || force {
         currentPageView = getVisiblePageView()
      }
   }
   
   private func getVisiblePageView() -> PageView? {
      var visiblePageView: PageView? = nil
      if let indexPaths = tableView.indexPathsForVisibleRows {
         let visibleRect = CGRect(origin: tableView.contentOffset, size: tableView.bounds.size)
         var maxSize = CGSize.zero
         for indexPath in indexPaths {
            let cellRect = tableView.rectForRow(at: indexPath)
            let intersectionSize = visibleRect.intersection(cellRect).size
            if intersectionSize.height > maxSize.height {
               maxSize = intersectionSize
               if let cell = tableView.cellForRow(at: indexPath) as? PageTableViewCell {
                  visiblePageView = cell.pageView
               }
            }
         }
      }
      
      return visiblePageView
   }
   
   func swapPagePositions(_ firstIndex: Int, secondIndex: Int) {
      let pagesCount = document?.pages.count ?? 0
      if firstIndex != secondIndex && firstIndex >= 0 && secondIndex >= 0 && firstIndex < pagesCount && secondIndex < pagesCount {
         tableView.reloadRows(at: [IndexPath(row: firstIndex, section: 0), IndexPath(row: secondIndex, section: 0)], with: .automatic)
      } else {
         print("Swap Layerpositions failed with firstIndex:\(firstIndex) and secondIndex\(secondIndex) and pagesCount \(pagesCount)")
      }
   }
   
   // MARK: - Table view data source
   
   func numberOfSections(in tableView: UITableView) -> Int {
      return 1
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return document?.getNumberOfPages() ?? 0
   }
   
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      let pageHeight = (document?[(indexPath as NSIndexPath).row]?.size.height ?? 0)
      return pageHeight + 2 * defaultMargin
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      return tableView.dequeueReusableCell(withIdentifier: PageTableViewCell.identifier, for: indexPath)
   }
   
   func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      guard let pageCell = cell as? PageTableViewCell else {
         return
      }
      
      guard let currentPage = document?[(indexPath as NSIndexPath).row] else {
         return
      }
      
      pageCell.widthConstraint?.constant = currentPage.size.width
      pageCell.heightConstraint?.constant = currentPage.size.height
      pageCell.pageView.page = currentPage
      pageCell.pageView.setUpLayer()
      
      pageCell.layoutIfNeeded()
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
      scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: frame.height)
   }
   
   func layoutDidChange() {
      layoutTableView()
      var frame = tableView.frame
      frame.origin = CGPoint(x: frame.origin.x, y: 0)
      tableView.frame = frame
   }
   
   // MARK: - UIScrollViewDelegate
   
   func viewForZooming(in scrollView: UIScrollView) -> UIView? {
      return tableView
   }
   
   func scrollViewDidZoom(_ scrollView: UIScrollView) {
      layoutDidChange()
   }
   
   func scrollViewDidScroll(_ scrollView: UIScrollView) {
      
      // only update tableview height if scrollview is'nt bouncing
      if !(scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.height
         && scrollView.contentSize.height > scrollView.bounds.height) && !(scrollView.contentOffset.y < 0) {
         updateTableViewHeight()
      }
      // disable vertical scrolling for ZoomingScrollView
      if (self.scrollView.contentOffset.y != 0) {
         self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentOffset.x, y: 0);
      }
      
      updateCurrentPageView()
   }
   
   var forcePageUpdate = false
   func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
      if !pageUpdateEnabled {
         pageUpdateEnabled = true
         forcePageUpdate = true
         updateCurrentPageView()
      }
      
   }
   
   // MARK: - DocumentSynchronizerDelegate
   
   func didAddPage(_ index: NSInteger) {
      if index < tableView.numberOfRows(inSection: 0) {
         let indexPath = IndexPath(row: index, section: 0)
         tableView.insertRows(at: [indexPath], with: .fade)
      } else {
         tableView.reloadData()
      }
   }
   
}
