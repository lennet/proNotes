//
//  ImportExportBaseViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 22/04/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

protocol ImportExportDataViewControllerDelgate: class {
    func addEmptyPage()
    
    func addTextField()
    
    func addPDF(url: NSURL)
    
    func addImage(image: UIImage)
    
    func addSketchLayer()
    
    func exportAsImages()
    
    func exportAsPDF()
    
    func exportAsProNote()
    
    func dismiss(animated: Bool)
}

class ImportExportBaseViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: ImportExportDataViewControllerDelgate?
    var dataSourceObjects = [TableViewMainObject]()
    
    struct TableViewSubObject {
        var title: String
        var action: (() -> ())
    }
    
    struct TableViewMainObject {
        var title: String
        var collapsed: Bool
        var subObjects: [TableViewSubObject]?
        var action: (() -> ())?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDataSource()
        if UIDevice.currentDevice().userInterfaceIdiom != .Phone {
            preferredContentSize = CGSize(width: preferredContentSize.width, height: CGFloat(dataSourceObjects.count * 44))
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUpTableView()
        addDoneButtonIfNeeded()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        dataSourceObjects.removeAll()
    }
    
    private func setUpTableView() {
        tableView.sectionHeaderHeight = 0.0
        tableView.sectionFooterHeight = 0.0
    }
    
    func setUpDataSource() {
        // empty base implementation
    }
    
    private func addDoneButtonIfNeeded() {
        if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
            let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(ImportExportBaseViewController.handleDoneButtonPressed))
            navigationItem.setRightBarButtonItem(doneBarButtonItem, animated: false)
        }
    }

    func handleDoneButtonPressed() {
        delegate?.dismiss(true)
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.setSelected(false, animated: true)
        let sectionObject = dataSourceObjects[indexPath.section]
        if indexPath.row > 0 {
            sectionObject.subObjects?[indexPath.row - 1].action()
        } else if ((sectionObject.action?()) == nil) {
            dataSourceObjects[indexPath.section].collapsed = !sectionObject.collapsed
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .None)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSourceObjects.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionObject = dataSourceObjects[section]
        return sectionObject.collapsed ? 1 : (sectionObject.subObjects?.count ?? 0) + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let dataSourceObject = dataSourceObjects[indexPath.section]
        
        if indexPath.row > 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(ImportDataSubTableViewCell.cellIdentifier, forIndexPath: indexPath) as! ImportDataSubTableViewCell
            cell.label.text = dataSourceObject.subObjects?[indexPath.row - 1].title
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(ImportDataMainTableViewCell.cellIdentifier, forIndexPath: indexPath) as! ImportDataMainTableViewCell
            cell.label.text = dataSourceObject.title
            
            if !dataSourceObject.collapsed {
                cell.accessoryImageView?.transform = CGAffineTransformMakeRotation(π / 2)
            } else {
                cell.accessoryImageView?.transform = CGAffineTransformIdentity
            }
            
            return cell
        }
    }

}
