//
//  DocumentSynchronizer.swift
//  Student
//
//  Created by Leo Thomas on 29/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

protocol DocumentSynchronizerDelegate {
    func updateDocument(document: Document, forceReload: Bool)

    func currentPageDidChange(page: DocumentPage)
}

class DocumentSynchronizer: NSObject {

    static let sharedInstance = DocumentSynchronizer()
    var delegates = [DocumentSynchronizerDelegate]()

    var currentPage: DocumentPage? {
        didSet {
            if currentPage != nil {
                informDelegateToUpdateCurrentPage(currentPage!)
            }
        }
    }

    var document: Document? {
        didSet {
            if document != nil {
                informDelegateToUpdateDocument(document!, forceReload: true)
                if oldValue == nil {
                    currentPage = document?.pages.first
                }
            }
        }
    }
    
    func renameDocument(newName: String, forceOverWrite: Bool,viewController: UIViewController?, completion: ((Bool) -> Void)?){
        guard document != nil else {
            return
        }
        
        guard newName != document?.name else {
            return
        }
        
        guard let oldURL = document?.fileURL else {
            return
        }
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            FileManager.sharedInstance.renameObject(oldURL, fileName: newName, forceOverWrite: false, completion: { (success, error) -> Void in
                if success {
                    completion?(true)
                } else if error != nil {
                    switch error! {
                    case RenameError.AlreadyExists:
                        dispatch_async(dispatch_get_main_queue(),{
                            let alertView = UIAlertController(title: nil, message: "Filename already exists", preferredStyle: .Alert)
                            alertView.addAction(UIAlertAction(title: "Override", style: .Destructive, handler: { (action) -> Void in
                                self.renameDocument(newName,forceOverWrite:true ,viewController: viewController, completion: completion)
                            }))
                            alertView.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
                                completion?(false)
                            }))
                            
                            viewController?.presentViewController(alertView, animated: true, completion: nil)
                        })
                        break
                    default:
                        dispatch_async(dispatch_get_main_queue(),{
                            let alertView = UIAlertController(title: nil, message: "Try again later", preferredStyle: .Alert)
                            viewController?.presentViewController(alertView, animated: true, completion: nil)
                            alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
                                completion?(false)
                            }))
                        })
                        break
                    }
                } else {
                    completion?(false)
                }
            })
        }
    }

    func updatePage(page: DocumentPage, forceReload: Bool) {
        if document != nil {
            guard page.index < document?.pages.count else {
                return
            }
            document?.pages[page.index] = page
            if page.index == currentPage?.index {
                currentPage = page
            }
            informDelegateToUpdateDocument(document!, forceReload: forceReload)
        }
    }

    func updateDrawLayer(drawLayer: DocumentDrawLayer, forceReload: Bool) {
        if document != nil {
            let page = drawLayer.docPage
            page.layers[drawLayer.index] = drawLayer
            guard page.index < document?.pages.count else {
                return
            }
            document?.pages[page.index] = page
            dispatch_async(dispatch_get_main_queue(), {
                self.informDelegateToUpdateDocument(self.document!, forceReload: forceReload)
            })
        }
    }

    func updateMovableLayer(movableLayer: MovableLayer) {
        if document != nil {
            let page = movableLayer.docPage
            page.layers[movableLayer.index] = movableLayer
            document?.pages[page.index] = page
            dispatch_async(dispatch_get_main_queue(), {
                self.informDelegateToUpdateDocument(self.document!, forceReload: false)
            })
        }
    }

    func save() {
        document?.saveToURL(document!.fileURL, forSaveOperation: .ForOverwriting, completionHandler: nil)
    }
    
    // MARK: - Delegate Handling

    func addDelegate(delegate: DocumentSynchronizerDelegate) {
        if !delegates.containsObject(delegate) {
            delegates.append(delegate)
        }
    }

    func removeDelegate(delegate: DocumentSynchronizerDelegate) {
        delegates.removeObject(delegate)
    }

    func informDelegateToUpdateDocument(document: Document, forceReload: Bool) {
        for delegate in delegates {
            delegate.updateDocument(document, forceReload: forceReload)
        }
    }

    func informDelegateToUpdateCurrentPage(page: DocumentPage) {
        for delegate in delegates {
            delegate.currentPageDidChange(page)
        }
    }

}
