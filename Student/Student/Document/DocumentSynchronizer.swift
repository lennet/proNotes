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
}

class DocumentSynchronizer: NSObject {

    static let sharedInstance = DocumentSynchronizer()
    var delegates = [DocumentSynchronizerDelegate]()
    var settingsViewController: SettingsViewController?

    var document: Document?{
        didSet{
            if document != nil {
                informDelegateToUpdateDocument(document!, forceReload: true)
            }
        }
    }
    
    func updatePage(page: DocumentPage) {
        if document != nil {
            document?.pages[page.index] = page
            informDelegateToUpdateDocument(document!, forceReload: false)
        }
    }
    
    func updateDrawLayer(drawLayer: DocumentDrawLayer, forceReload: Bool){
        if document != nil {
            let page = drawLayer.docPage
            page.layer[drawLayer.index] = drawLayer
            document?.pages[page.index] = page
            dispatch_async(dispatch_get_main_queue(),{
                self.informDelegateToUpdateDocument(self.document!, forceReload: forceReload)
            })
        }
    }
    
    func updateMovableLayer(movableLayer: MovableLayer) {
        if document != nil {
            let page = movableLayer.docPage
            page.layer[movableLayer.index] = movableLayer
            document?.pages[page.index] = page
            dispatch_async(dispatch_get_main_queue(),{
                self.informDelegateToUpdateDocument(self.document!, forceReload: false)
            })
        }
    }
    
    // MARK: - Delegate Handling
    
    func addDelegate(delegate  :DocumentSynchronizerDelegate) {
        if !delegates.containsObject(delegate) {
            delegates.append(delegate)
        }
    }
    
    func removeDelegate(delegate :DocumentSynchronizerDelegate) {
        delegates.removeObject(delegate)
    }
    
    func informDelegateToUpdateDocument(document :Document, forceReload: Bool) {
        for delegate in delegates {
            delegate.updateDocument(document, forceReload: forceReload)
        }
    }

    
}
