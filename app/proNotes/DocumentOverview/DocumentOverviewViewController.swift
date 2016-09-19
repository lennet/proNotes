//
//  DocumentOverviewViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 16/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class DocumentOverviewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DocumentManagerDelegate {
    
    @IBOutlet weak var documentsCollectionViewController: UICollectionView!
    
    private final let showDocumentSegueIdentifier = "showDocumentSegue"
    private var alreadyOpeningFile = false
    
    var documentManager: DocumentManager {
        get {
            return DocumentManager.sharedInstance
        }
    }

    enum OverViewSection: Int {
        case recentlyUsed = 0
        case allDocuments = 1
    }
    
    var objects: [DocumentsOverviewObject] {
        get {
            return documentManager.objects.sorted(by: { (first, second) -> Bool in
                return first.description.localizedCaseInsensitiveCompare(second.description) == ComparisonResult.orderedAscending
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Preferences.showWelcomeScreen {
            showWelcomeScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        documentManager.delegate = nil
        documentManager.reload()
        documentsCollectionViewController.reloadData()
        documentManager.delegate = self
        alreadyOpeningFile = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        documentManager.delegate = nil
        alreadyOpeningFile = false
    }
    
    func showWelcomeScreen() {
        performSegue(withIdentifier: "WelcomSegueIdentifier", sender: nil)
    }
    
    // MARK: - Actions

    @IBAction func handleNewButtonPressed(_ sender: AnyObject) {
        createNewDocument()
    }
    
    func createNewDocument() {
        documentManager.createDocument { (url) in
            self.openDocument(url as URL)
        }
    }
    
    func openDocument(_ url: URL) {
        DispatchQueue.main.async(execute: {
        for (index, object) in self.objects.enumerated() {
            if object.fileURL == url {
                    let index = IndexPath(item: index, section: 0)
                    self.documentsCollectionViewController.selectItem(at: index, animated: false, scrollPosition: UICollectionViewScrollPosition())
                    self.collectionView(self.documentsCollectionViewController, didSelectItemAt: index)
            }
        }
        })
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return documentManager.objects.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIDevice.current.userInterfaceIdiom == .phone ? 100 : 150 , height: 150)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DocumentOverviewCollectionViewCell.reusableIdentifier, for: indexPath) as! DocumentOverviewCollectionViewCell
        cell.delegate = self

        let object = objects[(indexPath as NSIndexPath).row]
        cell.nameTextField.text = object.description
        cell.dateLabel.text = object.metaData?.fileModificationDate?.toString()
        
        if !object.downloaded {
            cell.thumbImageView.image = UIImage(named: "cloud")
            cell.thumbImageView.contentMode = .center
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
    
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DocumentOverviewCollectionViewCell else {
            return
        }
        cell.activityIndicator.startAnimating()
        cell.activityIndicator.isHidden = false
        let selectedObject = objects[(indexPath as NSIndexPath).row]
        if selectedObject.downloaded {
            guard !alreadyOpeningFile else {
                return 
            }
            alreadyOpeningFile = true
            let document = Document(fileURL: selectedObject.fileURL)
            document.open(completionHandler: {
                (success) -> Void in
                if success {
                    DocumentInstance.sharedInstance.document = document
                    self.performSegue(withIdentifier: self.showDocumentSegueIdentifier, sender: nil)
                } else {
                    self.alert(message: "Error Occured. Please try again")
                }
            })
        } else {
            documentManager.downloadObject(selectedObject)
        }
    }

    // MARK: - FileManagerDelegate 

    func reloadObjects() {
        documentsCollectionViewController.reloadData()
    }

    func reloadObjectAtIndex(_ index: Int) {
        documentsCollectionViewController.reloadData()
    }

    func insertObjectAtIndex(_ index: Int) {
        documentsCollectionViewController.reloadData()
    }

    func removeObjectAtIndex(_ index: Int) {
        documentsCollectionViewController.reloadData()
    }
    
    // MARK: - Navigation 
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "CCBYAttributionIdentifier" && UIDevice.current.userInterfaceIdiom == .phone {
            let alertViewController = UIAlertController(title: "Creative Commons", message: "The icons are made by Freepik from www.flaticon.com and are licensed under CC BY 3.0.", preferredStyle: .actionSheet)
            alertViewController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
            }))
            present(alertViewController, animated: true, completion: nil)
            return false
        }
        return true
    }
}

extension DocumentOverviewViewController: DocumentOverviewCollectionViewCellDelegate {
    
    func didPressedDeleteButton(forCell cell: DocumentOverviewCollectionViewCell) {
        guard let index = documentsCollectionViewController.indexPath(for: cell) else { return }
        let object = objects[index.row]
        documentManager.deleteObject(object) { [weak self ] (success, error) in
            DispatchQueue.main.async {
                if !success {
                    self?.alert(message: "Error Ocurred. Please Try again")
                }
            }
        }
    }
    
    func didRenamedDocument(forCell cell: DocumentOverviewCollectionViewCell, newName: String) {
        guard let index = documentsCollectionViewController.indexPath(for: cell) else { return }
        let object = objects[index.row]
        documentManager.delegate = nil
        documentManager.renameDocument(withurl: object.fileURL, newName: newName, forceOverWrite: false, viewController: self) { (success, _) in
            DispatchQueue.main.async(execute: {
                self.documentManager.reload()
                self.documentsCollectionViewController.reloadData()
                
                self.documentManager.delegate = self
                if !success {
                    // reset title to old name
                    self.alert(message: "Error Ocurred. Please Try again")
                }
            })
        }
    }

}
