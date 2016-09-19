//
//  RenameDocumentManager.swift
//  proNotes
//
//  Created by Leo Thomas on 19/09/2016.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

struct RenameDocumentManager {
    
    var oldURL: URL
    var newName: String
    weak var viewController: UIViewController?
    var completion: ((Bool, URL?) -> ())
    
    var documentManager: DocumentManager {
        return DocumentManager.sharedInstance
    }
    
    func rename() {
        if documentManager.fileNameExistsInObjects(newName) {
            showFileExistsAlert(to: viewController)
        } else {
            moveDocument()
        }
    }
    
    private func moveDocument() {
        let newURL = DocumentManager.sharedInstance.getDocumentURL(newName, uniqueFileName: true)
        documentManager.moveObject(fromURL: oldURL, to: newURL, completion: { (success, error) in
            if success && error == nil {
                self.callCompletion(success: true, url: newURL)
            } else {
                self.showUnknownErrorMessage()
            }
        })
    }
    
    private func override() {
        let newURL = DocumentManager.sharedInstance.getDocumentURL(newName, uniqueFileName: false)
        guard let object = documentManager.objectForURL(newURL) else {
            showUnknownErrorMessage()
            return
        }
        documentManager.deleteObject(object) { (success, error) in
            DispatchQueue.main.async(execute: {
                if success && error == nil {
                    self.moveDocument()
                } else {
                    self.showUnknownErrorMessage()
                }
            })
        }
    }
    
    func showFileExistsAlert(to viewController: UIViewController?) {
        let alertView = UIAlertController(title: nil, message: NSLocalizedString("ErrorFileAlreadyExists", comment:"error message if a file with the given name already exists & ask for override"), preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: NSLocalizedString("Override", comment:""), style: .destructive, handler: {
            (action) -> Void in
            self.override()
        }))
        alertView.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment:""), style: .cancel, handler: {
            (action) -> Void in
            self.callCompletion(success: false, url: nil)
        }))
        
        viewController?.present(alertView, animated: true, completion: nil)
    }
    
    func showUnknownErrorMessage() {
        let alertView = UIAlertController(title: nil, message: NSLocalizedString("ErrorUnknown", comment:""), preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment:""), style: .default, handler: {
            (action) -> Void in
            self.callCompletion(success: false, url: nil)
        }))
        viewController?.present(alertView, animated: true, completion: nil)
    }
    
    func callCompletion(success: Bool, url: URL?) {
        DispatchQueue.main.async(execute: {
            self.completion(success, url)
        })
    }
}
