//
//  PageInfoViewController.swift
//  Student
//
//  Created by Leo Thomas on 11/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PageInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DocumentSynchronizerDelegate {

    var page: DocumentPage? = DocumentSynchronizer.sharedInstance.currentPage {
        didSet {
            layerTableView.reloadData()
        }
    }
    
    @IBOutlet weak var layerTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DocumentSynchronizer.sharedInstance.addDelegate(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDatasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return page?.layer.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(PageInfoLayerTableViewCell.identifier, forIndexPath: indexPath) as? PageInfoLayerTableViewCell else {
            return UITableViewCell()
        }
        
        guard let currentLayer = page?.layer[indexPath.row] else {
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
