//
//  ImportDataViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 17/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

protocol ImportDataViewControllerDelgate: class {
    func addEmptyPage()
    func addTextField()
    func addPDF(url: NSURL)
}

class ImportDataViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: ImportDataViewControllerDelgate?
    
    struct TableViewSubObject {
        var title: String
        var action: (()->())
    }
    
    struct TableViewMainObject {
        var title: String
        var collapsed: Bool
        var subObjects: [TableViewSubObject]?
        var action: (()->())?
    }
    
    var dataSourceObjects = [TableViewMainObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSourceObjects.append(TableViewMainObject(title: "Bild", collapsed: true, subObjects: [TableViewSubObject(title: "Photos", action: handleAddPictureCameraRoll), TableViewSubObject(title: "Camera", action: handleAddPictureCamera), TableViewSubObject(title: "iCloud Drive", action: handleAddImageiCloudDrive)], action: nil))
        dataSourceObjects.append(TableViewMainObject(title: "PDF einfügen", collapsed: true, subObjects: nil, action: handleAddPdf))
        dataSourceObjects.append(TableViewMainObject(title: "Textfeld einfügen", collapsed: true, subObjects: nil, action: handleAddTextField))
        dataSourceObjects.append(TableViewMainObject(title: "Seite einfügen", collapsed: true, subObjects: nil, action: handleAddPage))
        
        tableView.sectionHeaderHeight = 0.0
        tableView.sectionFooterHeight = 0.0

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions 
    
    func handleAddPictureCameraRoll() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.allowsEditing = false
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func handleAddPictureCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        imagePicker.allowsEditing = false
        navigationController?.pushViewController(imagePicker, animated: true)
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func handleAddImageiCloudDrive() {
    
    }
    
    func handleAddPdf() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], inMode: .Import)
        documentPicker.delegate = self;
        documentPicker.modalPresentationStyle = .PageSheet
        self.presentViewController(documentPicker, animated: true, completion: nil)
    }
    
    func handleAddTextField() {
        delegate?.addTextField()

    }
    
    func handleAddPage(){
        delegate?.addEmptyPage()
    }

    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSourceObjects.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionObject = dataSourceObjects[section]
        return sectionObject.collapsed ? 1 : (sectionObject.subObjects?.count ?? 0)+1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let dataSourceObject = dataSourceObjects[indexPath.section]
        
        if indexPath.row > 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(ImportDataSubTableViewCell.cellIdentifier, forIndexPath: indexPath) as! ImportDataSubTableViewCell
            cell.label.text = dataSourceObject.subObjects?[indexPath.row-1].title

            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(ImportDataMainTableViewCell.cellIdentifier, forIndexPath: indexPath) as! ImportDataMainTableViewCell
            cell.label.text = dataSourceObject.title
            
            if !dataSourceObject.collapsed {
                cell.accessoryImageView?.transform = CGAffineTransformMakeRotation(π/2)
            } else {
                cell.accessoryImageView?.transform = CGAffineTransformIdentity
            }
            
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.setSelected(false, animated: true)
        let sectionObject = dataSourceObjects[indexPath.section]
        if indexPath.row > 0 {
            sectionObject.subObjects?[indexPath.row-1].action()
        } else if ((sectionObject.action?()) == nil){
            dataSourceObjects[indexPath.section].collapsed = !sectionObject.collapsed
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .None)
        }
    }
    
    
    // MARK: - UIDocumentPickerDelegate
    
    func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        delegate?.addPDF(url)
    }

}
