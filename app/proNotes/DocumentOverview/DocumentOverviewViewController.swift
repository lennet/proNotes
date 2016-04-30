//
//  DocumentOverviewViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 16/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class DocumentOverviewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, FileManagerDelegate {
    
    @IBOutlet weak var documentsCollectionViewController: UICollectionView!
    
    private final let showDocumentSegueIdentifier = "showDocumentSegue"
    private var alreadyOpeningFile = false
    
    var fileManager: FileManager {
        get {
            return FileManager.sharedInstance
        }
    }

    enum OverViewSection: Int {
        case RecentlyUsed = 0
        case AllDocuments = 1
    }
    
    var objects: [DocumentsOverviewObject] {
        get {
            return fileManager.objects.sort({ (first, second) -> Bool in
                return first.description.localizedCaseInsensitiveCompare(second.description) == NSComparisonResult.OrderedAscending
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Preferences.isFirstRun() {
            performSegueWithIdentifier("WelcomSegueIdentifier", sender: nil)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fileManager.delegate = nil
        fileManager.reload()
        documentsCollectionViewController.reloadData()
        fileManager.delegate = self
        alreadyOpeningFile = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        fileManager.delegate = nil
    }
    
    // MARK: - Actions

    @IBAction func handleNewButtonPressed(sender: AnyObject) {
        fileManager.createDocument()
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fileManager.objects.count
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: UIDevice.currentDevice().userInterfaceIdiom == .Phone ? 100 : 150 , height: 150)
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(DocumentOverviewCollectionViewCell.reusableIdentifier, forIndexPath: indexPath) as! DocumentOverviewCollectionViewCell

        let object = objects[indexPath.row]
        cell.nameLabel.text = object.description
        cell.dateLabel.text = object.metaData?.fileModificationDate?.toString()
        
        if !object.downloaded {
            cell.thumbImageView.image = UIImage(named: "cloud")
            cell.thumbImageView.contentMode = .Center
        }
        
        if let thumbImage = object.metaData?.thumbImage {
            cell.thumbImageView.image = thumbImage
            cell.thumbImageViewHeightConstraint.constant = thumbImage.size.height
            cell.thumbImageViewWidthConstraint.constant = thumbImage.size.width
        }
        
        cell.layoutIfNeeded()
        return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? DocumentOverviewCollectionViewCell else {
            return
        }
        cell.activityIndicator.startAnimating()
        cell.activityIndicator.hidden = false
        let selectedObject = objects[indexPath.row]
        if selectedObject.downloaded {
            guard !alreadyOpeningFile else {
                return 
            }
            alreadyOpeningFile = true
            let document = Document(fileURL: selectedObject.fileURL)
            document.openWithCompletionHandler({
                (success) -> Void in
                if success {
                    DocumentInstance.sharedInstance.document = document
                    self.performSegueWithIdentifier(self.showDocumentSegueIdentifier, sender: nil)
                } else {
                    // TODO show error
                }
                collectionView.reloadItemsAtIndexPaths([indexPath])
            })
        } else {
            fileManager.downloadObject(selectedObject)
        }
    }

    // MARK: - FileManagerDelegate 

    func reloadObjects() {
        documentsCollectionViewController.reloadData()
    }

    func reloadObjectAtIndex(index: Int) {
        documentsCollectionViewController.reloadData()
    }

    func insertObjectAtIndex(index: Int) {
        documentsCollectionViewController.reloadData()
    }

    func removeObjectAtIndex(index: Int) {
        documentsCollectionViewController.reloadData()
    }

}