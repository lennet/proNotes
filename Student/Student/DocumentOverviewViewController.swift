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
    
    var fileManager: FileManager {
        get {
            return FileManager.sharedInstance
        }
    }
    
    enum OverViewSection: Int {
        case RecentlyUsed = 0
        case AllDocuments = 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fileManager.delegate = self
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? UICollectionViewCell {
            var indexPath = recentlyUsedCollectionView.indexPathForCell(cell)
            if indexPath == nil {
                indexPath = allDocumentsCollectionView.indexPathForCell(cell)
            }
            
            guard let finalIndexPath = indexPath else {
                return
            }
            
            let fileUrl = fileManager.objects[finalIndexPath.row].fileURL
            let document = Document(fileURL: fileUrl)
            document.openWithCompletionHandler({
                (success) -> Void in
                if success {
                    DocumentSynchronizer.sharedInstance.document = document
                }
            })            
        }
    }
    
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
        do {
            let attr: NSDictionary? = try NSFileManager.defaultManager().attributesOfItemAtPath(object.fileURL.path!)
            
            if let _attr = attr {
                let fileSize = Int64(_attr.fileSize())
                
                let sizeString = NSByteCountFormatter.stringFromByteCount(fileSize, countStyle: .Binary)
                cell.nameLabel.text = sizeString + object.description
            }
        } catch {
            print("Error: \(error)")
        }
        
        
        return cell
    }
    
    
    
    // MARK: UICollectionViewDelegate
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    
    //  MARK: - UIDocumenPicker
    
    func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        let documentUrl = try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let fileExtension = String(NSDate().timeIntervalSinceReferenceDate) + "test.studentDoc"
        let fileURL = documentUrl.URLByAppendingPathComponent(fileExtension)
        let document = Document(fileURL: fileURL)
        document.addPDF(url)
        DocumentSynchronizer.sharedInstance.document = document
        performSegueWithIdentifier("test", sender: nil)
    }
    
    // MARK: - FileManagerDelegate 
    
    func reloadObjects() {
        recentlyUsedCollectionView.reloadData()
        allDocumentsCollectionView.reloadData()
    }
    
}