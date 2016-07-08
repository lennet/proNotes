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
    
    func didUpdatePage(_ index: Int) {
        document?.updateChangeCount(.done)
        informDelegateDidUpdatePage(index)
    }
    
    func save(_ completionHandler: ((Bool) -> Void)?) {
        document?.save(to: document!.fileURL, for: .forOverwriting, completionHandler: completionHandler)
    }
    
    func flushUndoManager() {
        undoManager?.removeAllActions()
        NotificationCenter.default.post(name: NSNotification.Name.NSUndoManagerWillUndoChange, object: nil)
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
