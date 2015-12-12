//
//  PageInfoViewController.swift
//  Student
//
//  Created by Leo Thomas on 11/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PageInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DocumentSynchronizerDelegate {
    
    @IBOutlet weak var layerTableView: UITableView!
    
    var snapshotView: UIView = UIView()
    var sourceIndexPath :NSIndexPath?
    
    var page: DocumentPage? = DocumentSynchronizer.sharedInstance.currentPage {
        didSet {
            layerTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DocumentSynchronizer.sharedInstance.addDelegate(self)
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
        layerTableView.addGestureRecognizer(gestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Inspired by http://www.raywenderlich.com/63089/cookbook-moving-table-view-cells-with-a-long-press-gesture
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer){
        let location = gestureRecognizer.locationInView(layerTableView)
        guard let indexPath = layerTableView.indexPathForRowAtPoint(location) else {
            return
        }

        switch gestureRecognizer.state {
        case .Began:
            sourceIndexPath = indexPath
            guard let cell = layerTableView.cellForRowAtIndexPath(indexPath) else {
                return
            }
            snapshotView = cell.snapshotView()
            var center = cell.center
            snapshotView.center = center
            snapshotView.alpha = 0
            layerTableView.addSubview(snapshotView)
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                center.y = location.y
                self.snapshotView.center = center
                self.snapshotView.transform = CGAffineTransformMakeScale(1.05, 1.05)
                self.snapshotView.alpha = 0.98
                cell.alpha = 0
                }, completion: { (Bool) -> Void in
                    cell.hidden = true
            })
            break
        case .Changed:
            var center = snapshotView.center
            center.y = location.y
            snapshotView.center = center
            if !indexPath.isEqual(sourceIndexPath){
                page?.swapLayerPositions((sourceIndexPath?.row)!, secondIndex: indexPath.row)
                layerTableView.moveRowAtIndexPath(sourceIndexPath!, toIndexPath: indexPath)
                sourceIndexPath = indexPath
            }
            break
        default:
            let cell = layerTableView.cellForRowAtIndexPath(sourceIndexPath!)
            cell?.hidden = false
            cell?.alpha = 0
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.snapshotView.center = cell?.center ?? self.snapshotView.center
                self.snapshotView.transform = CGAffineTransformIdentity
                self.snapshotView.alpha = 0
                cell?.alpha = 1
                }, completion: { (Bool) -> Void in
                    self.sourceIndexPath = nil
                    self.snapshotView.removeFromSuperview()
                    self.snapshotView = UIView()
            })
            break
        }
    }

    
    // MARK: - UITableViewDatasource
    
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
    
    func currentPageDidChange(page: DocumentPage){
        self.page = page
    }
}
