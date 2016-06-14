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
    @objc optional func currentPageDidChange(_ page: DocumentPage)

    @objc optional func didAddPage(_ index: Int)
    
    @objc optional func didUpdatePage(_ index: Int)
}

class DocumentInstance: NSObject {

    static let sharedInstance = DocumentInstance()
    var delegates = Set<UIViewController>()

    var undoManager: UndoManager? {
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

    func renameDocument(_ newName: String, forceOverWrite: Bool, viewController: UIViewController?, completion: ((Bool) -> Void)?) {
        guard document != nil else {
            return
        }

        guard newName != document?.name else {
            return
        }

        guard let oldURL = document?.fileURL else {
            return
        }

        let priority = DispatchQueue.GlobalAttributes.qosDefault
        DispatchQueue.global(attributes: priority).async {
            FileManager.sharedInstance.renameObject(oldURL, fileName: newName, forceOverWrite: false, completion: {
                (success, error) -> Void in
                if success {
                    completion?(true)
                } else if error != nil {
                    switch error! {
                    case RenameError.alreadyExists:
                        DispatchQueue.main.async(execute: {
                            
                            let alertView = UIAlertController(title: nil, message: NSLocalizedString("ErrorFileAlreadyExists", comment:"error message if a file with the given name already exists & ask for override"), preferredStyle: .alert)
                            alertView.addAction(UIAlertAction(title: NSLocalizedString("Override", comment:""), style: .destructive, handler: {
                                (action) -> Void in
                                self.renameDocument(newName, forceOverWrite: true, viewController: viewController, completion: completion)
                            }))
                            alertView.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment:""), style: .cancel, handler: {
                                (action) -> Void in
                                completion?(false)
                            }))

                            viewController?.present(alertView, animated: true, completion: nil)
                        })
                        break
                    default:
                        DispatchQueue.main.async(execute: {
                            let alertView = UIAlertController(title: nil, message: NSLocalizedString("ErrorUnknown", comment:""), preferredStyle: .alert)
                            viewController?.present(alertView, animated: true, completion: nil)
                            alertView.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment:""), style: .default, handler: {
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
    
    func didUpdatePage(_ index: Int) {
        document?.updateChangeCount(.done)
        informDelegateDidUpdatePage(index)
    }
    
    func save(_ completionHandler: ((Bool) -> Void)?) {
        document?.save(to: document!.fileURL, for: .forOverwriting, completionHandler: completionHandler)
    }
    
    func flushUndoManager() {
        undoManager?.removeAllActions()
        NotificationCenter.default().post(name: NSNotification.Name.NSUndoManagerWillUndoChange, object: nil)
    }
    // MARK: - NSUndoManager

    func registerUndoAction(_ object: AnyObject?, pageIndex: Int, layerIndex: Int) {
        undoManager?.prepare(withInvocationTarget: self).undoAction(object, pageIndex: pageIndex, layerIndex: layerIndex)
    }

    func undoAction(_ object: AnyObject?, pageIndex: Int, layerIndex: Int) {
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

    func addDelegate(_ delegate: DocumentInstanceDelegate) {
        if let viewController = delegate as? UIViewController {
            if !delegates.contains(viewController) {
                delegates.insert(viewController)
            }
        }
    }

    func removeDelegate(_ delegate: DocumentInstanceDelegate) {
        if let viewController = delegate as? UIViewController {
            if delegates.contains(viewController) {
                delegates.remove(viewController)
            }
        }
    }
    
    func removeAllDelegates() {
        for case let delegate as DocumentInstanceDelegate in delegates {
            removeDelegate(delegate)
        }
    }

    func informDelegateToUpdateCurrentPage(_ page: DocumentPage) {
        for case let delegate as DocumentInstanceDelegate  in delegates {
            delegate.currentPageDidChange?(page)
        }
    }

    func informDelegateDidAddPage(_ index: Int) {
        for case let delegate as DocumentInstanceDelegate  in delegates {
            delegate.didAddPage?(index)
        }
    }
    
    func informDelegateDidUpdatePage(_ index: Int) {
        for case let delegate as DocumentInstanceDelegate  in delegates {
            delegate.didUpdatePage?(index)
        }
    }

}
