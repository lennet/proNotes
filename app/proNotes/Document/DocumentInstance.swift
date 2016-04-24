//
//  DocumentInstance.swift
//  proNotes
//
//  Created by Leo Thomas on 29/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

@objc
protocol DocumentInstanceDelegate: class {
    optional func currentPageDidChange(page: DocumentPage)

    optional func didAddPage(index: Int)
    
    optional func didUpdatePage(index: Int)
}

class DocumentInstance: NSObject {

    static let sharedInstance = DocumentInstance()
    var delegates = Set<UIViewController>()

    var undoManager: NSUndoManager? {
        get {
            let manager = PagesTableViewController.sharedInstance?.undoManager
            manager?.levelsOfUndo = 5
            return manager
        }
    }

    weak var currentPage: DocumentPage? {
        didSet {
            if currentPage != nil && oldValue != currentPage {
                informDelegateToUpdateCurrentPage(currentPage!)
            }
        }
    }

    var document: Document? {
        didSet {
            if document != nil {
                if oldValue == nil {
                    currentPage = document?.pages.first
                }
            }
        }
    }

    func renameDocument(newName: String, forceOverWrite: Bool, viewController: UIViewController?, completion: ((Bool) -> Void)?) {
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
            FileManager.sharedInstance.renameObject(oldURL, fileName: newName, forceOverWrite: false, completion: {
                (success, error) -> Void in
                if success {
                    completion?(true)
                } else if error != nil {
                    switch error! {
                    case RenameError.AlreadyExists:
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            let alertView = UIAlertController(title: nil, message: NSLocalizedString("ErrorFileAlreadyExists", comment:"error message if a file with the given name already exists & ask for override"), preferredStyle: .Alert)
                            alertView.addAction(UIAlertAction(title: NSLocalizedString("Override", comment:""), style: .Destructive, handler: {
                                (action) -> Void in
                                self.renameDocument(newName, forceOverWrite: true, viewController: viewController, completion: completion)
                            }))
                            alertView.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment:""), style: .Cancel, handler: {
                                (action) -> Void in
                                completion?(false)
                            }))

                            viewController?.presentViewController(alertView, animated: true, completion: nil)
                        })
                        break
                    default:
                        dispatch_async(dispatch_get_main_queue(), {
                            let alertView = UIAlertController(title: nil, message: NSLocalizedString("ErrorUnknown", comment:""), preferredStyle: .Alert)
                            viewController?.presentViewController(alertView, animated: true, completion: nil)
                            alertView.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment:""), style: .Default, handler: {
                                (action) -> Void in
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
    
    func didUpdatePage(index: Int) {
        document?.updateChangeCount(.Done)
        informDelegateDidUpdatePage(index)
    }

    func save(completionHandler: ((Bool) -> Void)?) {
        document?.saveToURL(document!.fileURL, forSaveOperation: .ForOverwriting, completionHandler: completionHandler)
    }

    // MARK: - NSUndoManager

    func registerUndoAction(object: AnyObject?, pageIndex: Int, layerIndex: Int) {
        undoManager?.prepareWithInvocationTarget(self).undoAction(object, pageIndex: pageIndex, layerIndex: layerIndex)
    }

    func undoAction(object: AnyObject?, pageIndex: Int, layerIndex: Int) {
        if let pageView = PagesTableViewController.sharedInstance?.currentPageView {
            if pageView.page?.index == pageIndex {
                if let pageSubView = pageView[layerIndex] {
                    pageSubView.undoAction?(object)
                    return
                }
            }
        }

        // Swift 😍
        document?[pageIndex]?[layerIndex]?.undoAction(object)
    }

    // MARK: - Delegate Handling

    func addDelegate(delegate: DocumentInstanceDelegate) {
        if let viewController = delegate as? UIViewController {
            if !delegates.contains(viewController) {
                delegates.insert(viewController)
            }
        }
    }

    func removeDelegate(delegate: DocumentInstanceDelegate) {
        if let viewController = delegate as? UIViewController {
            if delegates.contains(viewController) {
                delegates.remove(viewController)
            }
        }
    }

    func informDelegateToUpdateCurrentPage(page: DocumentPage) {
        for case let delegate as DocumentInstanceDelegate  in delegates {
            delegate.currentPageDidChange?(page)
        }
    }

    func informDelegateDidAddPage(index: Int) {
        for case let delegate as DocumentInstanceDelegate  in delegates {
            delegate.didAddPage?(index)
        }
    }
    
    func informDelegateDidUpdatePage(index: Int) {
        for case let delegate as DocumentInstanceDelegate  in delegates {
            delegate.didUpdatePage?(index)
        }
    }

}
