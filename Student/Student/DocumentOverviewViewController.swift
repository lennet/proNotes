//
//  DocumentOverviewViewController.swift
//  Student
//
//  Created by Leo Thomas on 16/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class DocumentOverviewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIDocumentPickerDelegate, FileManagerDelegate {

    @IBOutlet weak var recentlyUsedCollectionView: UICollectionView!
    @IBOutlet weak var allDocumentsCollectionView: UICollectionView!
    
    private final let showDocumentSegueIdentifier = "showDocumentSegue"
    
    var fileManager: FileManager {
        get {
            return FileManager.sharedInstance
        }
    }
    
    enum OverViewSection: Int {
        case RecentlyUsed = 0
        case AllDocuments = 1
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fileManager.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        fileManager.delegate = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Actions
    
    @IBAction func handleImportButtonPressed(sender: AnyObject) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], inMode: .Import)
        documentPicker.delegate = self;
        documentPicker.modalPresentationStyle = .PageSheet
        self.presentViewController(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func handleNewButtonPressed(sender: AnyObject) {
        fileManager.createDocument()
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fileManager.objects.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(recentlyUsedCollectionView.bounds.height, recentlyUsedCollectionView.bounds.height)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(DocumentOverviewCollectionViewCell.reusableIdentifier, forIndexPath: indexPath) as! DocumentOverviewCollectionViewCell
        
        let object = fileManager.objects[indexPath.row]
        cell.nameLabel.text = object.description
        cell.downloadIndicator.hidden = object.downloaded
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedObject = fileManager.objects[indexPath.row]
        if selectedObject.downloaded {
            let document = Document(fileURL: selectedObject.fileURL)
            document.openWithCompletionHandler({
                (success) -> Void in
                if success {
                    DocumentSynchronizer.sharedInstance.document = document
                    self.performSegueWithIdentifier(self.showDocumentSegueIdentifier, sender: nil)
                } else {
                    // TODO show error
                }
            })
        } else {
            fileManager.downloadObject(selectedObject)
        }
    }
    
    //  MARK: - UIDocumenPicker
    
    func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        let documentUrl = try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let fileExtension = String(NSDate().timeIntervalSinceReferenceDate) + "test.studentDoc"
        let fileURL = documentUrl.URLByAppendingPathComponent(fileExtension)
        let document = Document(fileURL: fileURL)
        document.addPDF(url)
        DocumentSynchronizer.sharedInstance.document = document
        performSegueWithIdentifier(showDocumentSegueIdentifier, sender: nil)
    }
    
    // MARK: - FileManagerDelegate 
    
    func reloadObjects() {
        recentlyUsedCollectionView.reloadData()
        allDocumentsCollectionView.reloadData()
    }
    
    func reloadObjectAtIndex(index: Int) {
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        
        guard indexPath.row+1 > allDocumentsCollectionView.numberOfItemsInSection(0) else {
            reloadObjects()
            return
        }
        
        recentlyUsedCollectionView.reloadItemsAtIndexPaths([indexPath])
        allDocumentsCollectionView.reloadItemsAtIndexPaths([indexPath])
    }
    
    func insertObjectAtIndex(index: Int) {
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        allDocumentsCollectionView.insertItemsAtIndexPaths([indexPath])
        recentlyUsedCollectionView.insertItemsAtIndexPaths([indexPath])
    }
    
    func removeObjectAtIndex(index: Int) {
        // maybe add a fancy animtaion in the future
        // FIXME Crash after deleting all Notes 
        reloadObjectAtIndex(index)
    }
    
}