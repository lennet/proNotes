//
//  FileManager.swift
//  Student
//
//  Created by Leo Thomas on 17/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

protocol FileManagerDelegate {
    func reloadObjects()
}

class FileManager: NSObject {
    
    static let sharedInstance = FileManager()
    
    final let fileExtension = "ProNote"
    final let defaultName = "Note"

    var delegate: FileManagerDelegate?
    
    var objects = [DocumentsOverviewObject]()
    var query: NSMetadataQuery?

    var iCloudAvailable = false
    
    private var _documentsRootUrl: NSURL?
    var documentsRootURL: NSURL! {
        get {
            if _documentsRootUrl == nil {
                let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains:.UserDomainMask)
                _documentsRootUrl = paths.first
            }
            return _documentsRootUrl
        }
        
        set {
            _documentsRootUrl = newValue
        }
    }
    
    var iCloudRootURL: NSURL?
    
    override init() {
        super.init()
        reload()
    }
    
    func reload() {
        objects.removeAll()
        
        initializeiCLoud { (success) -> () in
            self.iCloudAvailable = success
            if self.iCloudAvailable {
                self.startQuery()
            }
        }
    }
    
    func checkFiles() {
        query?.disableUpdates()
        
        
        guard let results = query?.results as? [NSMetadataItem] else {
            query?.enableUpdates()
            return
        }
        
        for result in results {
            if let fileURL = result.fileURL {
                let newObject = DocumentsOverviewObject(fileURL: fileURL)
                if result.isLocalAvailable() {
                    do {
                        var resource: AnyObject?
                        try fileURL.getResourceValue(&resource, forKey:NSURLIsHiddenKey )
                        if let isHidden = resource as? NSNumber {
                            if !isHidden.boolValue {
                                newObject.downloaded = true
                                updateObject(newObject)
                            }
                        }
                    } catch {
                        print("Error: \(error)")
                    }
                    
                } else {
                    newObject.downloaded = false
                    print(result.valueForAttribute(NSMetadataUbiquitousItemPercentDownloadedKey))
                    // TODO check if file is available
                    updateObject(newObject)
                }
            }
        }
        
        delegate?.reloadObjects()
        
        query?.enableUpdates()
    }
    
    func useiCloud() -> Bool{
        return true
    }
    
    func downloadObject(object: DocumentsOverviewObject) {
        do {
            try NSFileManager.defaultManager().startDownloadingUbiquitousItemAtURL(object.fileURL)
        } catch {
            print("Error: \(error)")
        }
    }
    
    
    // MARK - CRUD
    
    func createDocument() {
        let fileUrl = getDocumentURL(defaultName)
        
        let document = Document(fileURL: fileUrl)
        document.saveToURL(fileUrl, forSaveOperation: .ForCreating) { (success) -> Void in
            if !success{
                print("Couldn't create Document: \(document.description)")
                return
            }
            let metaData = document.metaData
            let fileURL = document.fileURL
            let state = document.documentState
            let version =  NSFileVersion.currentVersionOfItemAtURL(fileURL)
            
            document.closeWithCompletionHandler({ (sucess) -> Void in
                dispatch_async(dispatch_get_main_queue(),{
                    self.updateObject(fileURL, metaData: metaData, state: state, version: version, downloaded: true)
                })
            })
        }
    }
    
    func updateMetadata(fileURL: NSURL) {
        guard let path = fileURL.path else {
            return
        }
        if NSFileManager.defaultManager().fileExistsAtPath(path){
            let document = Document(fileURL: fileURL)
            document.openWithCompletionHandler { (success) -> Void in
                if (!success) {
                    print("Couldn't open Document: \(document.description)")
                    return
                }
                
                let metaData = document.metaData
                let fileURL = document.fileURL
                let state = document.documentState
                let version = NSFileVersion.currentVersionOfItemAtURL(fileURL)
                
                document.closeWithCompletionHandler({ (sucess) -> Void in
                    dispatch_async(dispatch_get_main_queue(),{
                        self.updateObject(fileURL, metaData: metaData, state: state, version: version,downloaded: true)
                    })
                })
            }
        } else {
            
        }

    }
    
    func deleteObject(object: DocumentsOverviewObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            let fileCoordinator = NSFileCoordinator(filePresenter: nil)
            var error: NSError?
            fileCoordinator.coordinateWritingItemAtURL(object.fileURL, options: .ForDeleting, error: &error, byAccessor: { (url) -> Void in
                let fileManager = NSFileManager()
                try! fileManager.removeItemAtURL(object.fileURL)
            })
            
        }
        
        removeObjectFromArray(object.fileURL)
    }
    
    // MARK: - Array Handling
    
    func updateObject(object: DocumentsOverviewObject) {
        updateObject(object.fileURL, metaData: nil, state: nil, version: nil,downloaded: object.downloaded)
    }
    
    func updateObject(fileURL: NSURL, metaData: DocumentMetaData?, state: UIDocumentState?, version: NSFileVersion?, downloaded: Bool) {
        if let index = indexOf(fileURL) {
            let entry = objects[index]
            entry.metaData = metaData
            entry.version = version
            entry.state = state
            entry.downloaded = downloaded
            delegate?.reloadObjects()
        } else {
            let entry = DocumentsOverviewObject(fileURL: fileURL, state: state, metaData: metaData, version: version)
            entry.downloaded = downloaded
            objects.append(entry)
            delegate?.reloadObjects()
        }
    }
    
    func removeObjectFromArray(fileURL: NSURL) {
        guard let index = indexOf(fileURL) else {
            // file does not exists
            return
        }

        objects.removeAtIndex(index)
        delegate?.reloadObjects()
    }
    
    func indexOf(fileURL: NSURL) -> Int? {
        for (index, object) in objects.enumerate() {
            if object.fileURL == fileURL {
                return index
            }
        }
        return nil
    }
    
    // MARK - Filename Handling
    
    func getDocumentURL(fileName: String) -> NSURL {
        let uniqueName = getUniqueFileName(fileName)+"."+fileExtension
        if useiCloud() {
            if let docsDir = iCloudRootURL?.URLByAppendingPathComponent("Documents", isDirectory: true) {
                return docsDir.URLByAppendingPathComponent(uniqueName)
            }
        }
        return documentsRootURL.URLByAppendingPathComponent(uniqueName)
    }
    
    func getUniqueFileName(fileName: String) -> String {
        fileName
        // TODO improve
        if fileNameExistsInObjects(fileName) {
            return getUniqueFileName(fileName+String(objects.count))
        }
        return fileName
    }
    
    func fileNameExistsInObjects(fileName: String) -> Bool{
        for entry in objects {
            if entry.fileURL.fileName() == fileName {
                return true
            }
        }
        return false
    }
    
    // MARK - iCloud Query
    
    func initializeiCLoud(completion: (success :Bool) ->()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            self.iCloudRootURL = NSFileManager.defaultManager().URLForUbiquityContainerIdentifier(nil)
            if self.iCloudRootURL != nil {
                dispatch_async(dispatch_get_main_queue(),{
                    completion(success: true)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(),{
                    completion(success: false)
                })
            }
        }
    }
    
    func startQuery() {
        stopQuery()
        
        query = documentQuery
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleQueryNotification:", name: NSMetadataQueryDidFinishGatheringNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleQueryNotification:", name: NSMetadataQueryDidUpdateNotification, object: nil)
        query?.startQuery()
        
    }
    
    func stopQuery() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSMetadataQueryDidFinishGatheringNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSMetadataQueryDidUpdateNotification, object: nil)
    
        query?.stopQuery()
        query = nil
    }
    
    func handleQueryNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            for item in (userInfo[NSMetadataQueryUpdateRemovedItemsKey] as? [NSMetadataItem]) ?? [NSMetadataItem]() where item.fileURL != nil {
                removeObjectFromArray(item.fileURL!)
            }
            for item in (userInfo[NSMetadataQueryUpdateAddedItemsKey] as? [NSMetadataItem]) ?? [NSMetadataItem]() where item.fileURL != nil {
                updateMetadata(item.fileURL!)
            }
            for item in (userInfo[NSMetadataQueryUpdateChangedItemsKey] as? [NSMetadataItem]) ?? [NSMetadataItem]() where item.fileURL != nil {
                updateMetadata(item.fileURL!)
            }
        } else {
            checkFiles()
        }
    }
    
    var documentQuery: NSMetadataQuery {
        get {
            let query = NSMetadataQuery()
            query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
            let filePattern = "*."+fileExtension
            query.predicate = NSPredicate(format: "%K Like %@", NSMetadataItemFSNameKey, filePattern)
            return query
        }
    }
    
}

