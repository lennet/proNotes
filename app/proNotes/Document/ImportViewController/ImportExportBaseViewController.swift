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
    
    func addPDF(_ url: URL)
    
    func addImage(_ image: UIImage)
    
    func addSketchLayer()
    
    func exportAsImages(_ images: [UIImage])
    
    func exportAsPDF(_ data: Data)
    
    func exportAsProNote(_ url: URL)
    
    func dismiss(_ animated: Bool)
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
        if UIDevice.current().userInterfaceIdiom != .phone {
            preferredContentSize = CGSize(width: preferredContentSize.width, height: CGFloat(dataSourceObjects.count * 44))
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpTableView()
        addDoneButtonIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
        if UIDevice.current().userInterfaceIdiom != .pad {
            let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ImportExportBaseViewController.handleDoneButtonPressed))
            navigationItem.setRightBarButton(doneBarButtonItem, animated: false)
        }
    }

    func handleDoneButtonPressed() {
        delegate?.dismiss(true)
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        let sectionObject = dataSourceObjects[(indexPath as NSIndexPath).section]
        if (indexPath as NSIndexPath).row > 0 {
            sectionObject.subObjects?[(indexPath as NSIndexPath).row - 1].action()
        } else if ((sectionObject.action?()) == nil) {
            dataSourceObjects[(indexPath as NSIndexPath).section].collapsed = !sectionObject.collapsed
            tableView.reloadSections(IndexSet(integer: (indexPath as NSIndexPath).section), with: .none)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSourceObjects.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionObject = dataSourceObjects[section]
        return sectionObject.collapsed ? 1 : (sectionObject.subObjects?.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dataSourceObject = dataSourceObjects[(indexPath as NSIndexPath).section]
        
        if (indexPath as NSIndexPath).row > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ImportDataSubTableViewCell.cellIdentifier, for: indexPath) as! ImportDataSubTableViewCell
            cell.label.text = dataSourceObject.subObjects?[(indexPath as NSIndexPath).row - 1].title
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ImportDataMainTableViewCell.cellIdentifier, for: indexPath) as! ImportDataMainTableViewCell
            cell.label.text = dataSourceObject.title
            
            if !dataSourceObject.collapsed {
                cell.accessoryImageView?.transform = CGAffineTransform(rotationAngle: π / 2)
            } else {
                cell.accessoryImageView?.transform = CGAffineTransform.identity
            }
            
            return cell
        }
    }

}
