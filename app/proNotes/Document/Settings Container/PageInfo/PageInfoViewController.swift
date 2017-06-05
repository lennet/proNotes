//
//  PageInfoViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 11/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PageInfoViewController: SettingsBaseViewController, UITableViewDataSource, UITableViewDelegate, DocumentInstanceDelegate, ReordableTableViewDelegate, PageInfoLayerTableViewCellDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var layerTableView: ReordableTableView!
    @IBOutlet weak var layerTableViewHeightConstraint: NSLayoutConstraint!

    private final let collectionViewCellIdentifier = "UICollectionViewCellIdentifier"

    let paperSizes = CGSize.paperSizes()

    weak var page: DocumentPage? = DocumentInstance.sharedInstance.currentPage {
        didSet {
            layerTableView.reloadData()
            layoutTableView()
            titleLabel.text = String(format:NSLocalizedString("PageInfoTitle", comment: ""), (page?.index ?? 0) + 1)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layerTableView.reordableDelegate = self

        let doupleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(PageInfoViewController.handleDoubleTap(_:)))
        doupleTapRecognizer.numberOfTapsRequired = 2
        layerTableView.addGestureRecognizer(doupleTapRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DocumentInstance.sharedInstance.addDelegate(self)
        layerTableView.setUp()
        layerTableView.deactivateDelaysContentTouches()
        layoutTableView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DocumentInstance.sharedInstance.removeDelegate(self)
    }

    func layoutTableView() {
        layerTableView.reloadData()
        layerTableView.layoutIfNeeded()
        layerTableViewHeightConstraint.constant = layerTableView.contentSize.height
        self.view.layoutIfNeeded()
    }

    @objc func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: layerTableView)
        guard let indexPath = layerTableView.indexPathForRow(at: location) else {
            return
        }

        PagesTableViewController.sharedInstance?.currentPageView?.setLayerSelected((indexPath as NSIndexPath).row)
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return page?.layers.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PageInfoLayerTableViewCell.identifier, for: indexPath) as? PageInfoLayerTableViewCell else {
            return UITableViewCell()
        }

        guard let currentLayer = page?.layers[(indexPath as NSIndexPath).row] else {
            return cell
        }

        cell.setUpCell(with: currentLayer)
        cell.delegate = self
        return cell
    }

    func currentPageDidChange(_ page: DocumentPage) {
        self.page = page
    }

    // MARK: - ReordableTableViewDelegate

    func didSwapElements(_ firstIndex: Int, secondIndex: Int) {
        page?.swapLayerPositions(firstIndex, secondIndex: secondIndex)
        PagesTableViewController.sharedInstance?.currentPageView?.swapLayerPositions(firstIndex, secondIndex: secondIndex)
        DocumentInstance.sharedInstance.flushUndoManager()
    }

    func finishedSwappingElements() {
        if let pageIndex = page?.index {
            DocumentInstance.sharedInstance.didUpdatePage(pageIndex)
        }
    }
    
    // MARK: - PageInfoLayerTableViewCellDelegate

    func didRemovedLayer() {
        UIView.animate(withDuration: standardAnimationDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
            () -> Void in
            self.layoutTableView()
        }, completion: nil)
    }

}
