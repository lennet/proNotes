//
//  PageInfoViewController.swift
//  Student
//
//  Created by Leo Thomas on 11/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PageInfoViewController: SettingsBaseViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, DocumentSynchronizerDelegate, ReordableTableViewDelegate {

    @IBOutlet weak var backgroundSelectionCollectionView: UICollectionView!
    @IBOutlet weak var layerTableView: ReordableTableView!

    @IBOutlet weak var formatSelectionCollectionView: UICollectionView!
    @IBOutlet weak var layerTableViewHeightConstraint: NSLayoutConstraint!

    private final let collectionViewCellIdentifier = "UICollectionViewCellIdentifier"

    let paperSizes = CGSize.paperSizes()

    weak var page: DocumentPage? = DocumentSynchronizer.sharedInstance.currentPage {
        didSet {
            layerTableView.reloadData()
            layoutTableView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layerTableView.reordableDelegate = self

        let doupleTapRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleDoubleTap:"))
        doupleTapRecognizer.numberOfTapsRequired = 2
        layerTableView.addGestureRecognizer(doupleTapRecognizer)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        DocumentSynchronizer.sharedInstance.addDelegate(self)
        layoutTableView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        DocumentSynchronizer.sharedInstance.removeDelegate(self)
    }

    func layoutTableView() {
        layerTableView.layoutIfNeeded()
        layerTableViewHeightConstraint.constant = layerTableView.contentSize.height
        self.view.layoutIfNeeded()
    }

    func handleDoubleTap(gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.locationInView(layerTableView)
        guard let indexPath = layerTableView.indexPathForRowAtPoint(location) else {
            return
        }

        PagesTableViewController.sharedInstance?.currentPageView()?.setLayerSelected(indexPath.row)
    }

    // MARK: - UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return page?.layers.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(PageInfoLayerTableViewCell.identifier, forIndexPath: indexPath) as? PageInfoLayerTableViewCell else {
            return UITableViewCell()
        }

        guard let currentLayer = page?.layers[indexPath.row] else {
            return cell
        }

        cell.setUpCellWithLayer(currentLayer)
        return cell
    }

    func updateDocument(document: Document, forceReload: Bool) {

    }

    func currentPageDidChange(page: DocumentPage) {
        self.page = page
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == backgroundSelectionCollectionView {
            return 2
        } else {
            return paperSizes.count
        }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(collectionViewCellIdentifier, forIndexPath: indexPath)
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView == backgroundSelectionCollectionView {
            return CGSizeMake(collectionView.bounds.height / 1.5, collectionView.bounds.height / 1.5)
        } else {
            var size = paperSizes[indexPath.row]
            let maxRatio = collectionView.bounds.height / paperSizes[0].height * 0.8
            size.multiplySize(maxRatio)
            return size
        }
    }

    // MARK: - ReordableTableViewDelegate

    func didSwapElements(firstIndex: Int, secondIndex: Int) {
        PagesTableViewController.sharedInstance?.currentPageView()?.swapLayerPositions(firstIndex, secondIndex: secondIndex)
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // TODO
    }

}
