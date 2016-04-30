//
//  FileManager.swift
//  proNotes
//
//  Created by Leo Thomas on 17/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit
import CloudKit

enum RenameError: ErrorType {
    case AlreadyExists
    case ObjectNotFound
    case WritingError
    case OverwritingError
}

protocol FileManagerDelegate: class {

    func reloadObjects()

    func reloadObjectAtIndex(index: Int)

    func insertObjectAtIndex(index: Int)

    func removeObjectAtIndex(index: Int)

}

class FileManager: NSObject {

    static let sharedInstance = FileManager()

    private final let fileExtension = "ProNote"
    private final let defaultName = NSLocalizedString("Note", comment: "default file name")

    weak var delegate: FileManagerDelegate?

    var objects = [DocumentsOverviewObject]()
    var query: NSMetadataQuery?

    var iCloudAvailable = false

    private var _documentsRootUrl: NSURL?
    var documentsRootURL: NSURL! {
        get {
            if _documentsRootUrl == nil {
                let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
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
        downloadFromCloudKit()
    }
    
    func downloadFromCloudKit() {
        guard !Preferences.AlreadyDownloadedDefaultNote() else {
            return 
        }
        let taskID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
        let container = CKContainer.defaultContainer()
        let publicDataBase = container.publicCloudDatabase
        let predicate = NSPredicate(value: true)
    
        let query = CKQuery(recordType: "Document", predicate: predicate)
        publicDataBase.performQuery(query, inZoneWithID: nil) { (records, error) in
            if let record = records?.first {
                if let asset = record.objectForKey("data") as? CKAsset {
                    let newURL = self.getDocumentURL("HelloWorld🦄", uniqueFileName: true)
                    try!  NSFileManager.defaultManager().copyItemAtURL(asset.fileURL, toURL: newURL)
                    NotifyHelper.fireNotification(false, url: newURL)
                    Preferences.setAlreadyDownloadedDefaultNote(true)
                    WelcomeViewController.sharedInstance?.alredyDownloaded = true
                }
            } else {
                NotifyHelper.fireNotification(true)
            }
            UIApplication.sharedApplication().endBackgroundTask(taskID)
        }
    }

    func reload() {
        objects.removeAll()

        initializeiCLoud {
            (success) -> () in
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
                if result.isLocalAvailable() {
                    do {
                        var resource: AnyObject?
                        try fileURL.getResourceValue(&resource, forKey: NSURLIsHiddenKey)
                        if let isHidden = resource as? NSNumber {
                            if !isHidden.boolValue {
                                updateMetadata(fileURL)
                            }
                        }
                    } catch {
                        print("Error: \(error)")
                    }

                } else {
                    updateObject(fileURL, metaData: nil, state: nil, version: nil, downloaded: false)
                }
            }
        }
        query?.enableUpdates()
    }

    func useiCloud() -> Bool {
        return true
    }

    func downloadObject(object: DocumentsOverviewObject) {
        do {
            try NSFileManager.defaultManager().startDownloadingUbiquitousItemAtURL(object.fileURL)
        } catch {
            print("Error: \(error)")
        }
    }

    // MARK: - CRUD

    func renameObject(fileURL: NSURL, fileName: String, forceOverWrite: Bool, completion: ((Bool, ErrorType?) -> Void)?) {
        guard let index = indexOf(fileURL) else {
            completion?(false, RenameError.ObjectNotFound)
            return
        }
        let object = objects[index]

        if object.description == fileName {
            // nothing changed
            return
        }

        let newURL = getDocumentURL(fileName, uniqueFileName: false)

        if fileNameExistsInObjects(fileName) {
            if forceOverWrite {
                if let object = objectForURL(newURL) {
                    deleteObject(object, completion: {
                        (success, error) -> Void in
                        if success {
                            // set forceOverWrite false to avoid endless recursive loops
                            self.renameObject(fileURL, fileName: fileName, forceOverWrite: false, completion: completion)
                        } else {
                            completion?(false, error)
                        }
                    })
                }
            } else {
                completion?(false, RenameError.AlreadyExists)
                return
            }
        }

        let fileCoordinator = NSFileCoordinator(filePresenter: nil)
        var error: NSError?

        fileCoordinator.coordinateWritingItemAtURL(fileURL, options: .ForMoving, writingItemAtURL: newURL, options: .ForReplacing, error: &error) {
            (newURL1, newURL2) -> Void in
            fileCoordinator.itemAtURL(fileURL, willMoveToURL: newURL)
            do {
                try NSFileManager.defaultManager().moveItemAtURL(fileURL, toURL: newURL)
            } catch {
                completion?(false, error)
            }
            fileCoordinator.itemAtURL(fileURL, didMoveToURL: newURL)
        }

        if error == nil {
            removeObjectFromArray(fileURL)
            updateObject(newURL, metaData: object.metaData, state: object.state, version: object.version, downloaded: object.downloaded)
            completion?(true, nil)
        } else {
            completion?(false, RenameError.WritingError)
        }

    }

    func createDocument(completionHandler: (NSURL) -> Void) {
        let fileUrl = getDocumentURL(defaultName, uniqueFileName: true)

        let document = Document(fileURL: fileUrl)
        document.addEmptyPage()
        document.saveToURL(fileUrl, forSaveOperation: .ForCreating) {
            (success) -> Void in
            if !success {
                print("Couldn't create Document: \(document.description)")
                return
            }
            let metaData = document.metaData
            metaData?.fileModificationDate = document.fileModificationDate
            let fileURL = document.fileURL
            let state = document.documentState
            let version = NSFileVersion.currentVersionOfItemAtURL(fileURL)


            document.closeWithCompletionHandler({
                (sucess) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.updateObject(fileURL, metaData: metaData, state: state, version: version, downloaded: true)
                    completionHandler(fileURL)
                })
            })
        }
    }

    private func updateMetadata(fileURL: NSURL) {
        guard let path = fileURL.path else {
            return
        }
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            let document = Document(fileURL: fileURL)
            document.openWithCompletionHandler {
                (success) -> Void in
                if (!success) {
                    print("Couldn't open Document: \(document.description)")
                    return
                }

                let metaData = document.metaData
                metaData?.fileModificationDate = document.fileModificationDate
                let fileURL = document.fileURL
                let state = document.documentState
                let version = NSFileVersion.currentVersionOfItemAtURL(fileURL)

                document.closeWithCompletionHandler({
                    (sucess) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        self.updateObject(fileURL, metaData: metaData, state: state, version: version, downloaded: true)
                    })
                })
            }
        } else {

        }

    }

    func deleteObject(object: DocumentsOverviewObject, completion: ((Bool, ErrorType?) -> Void)?) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            () -> Void in
            let fileCoordinator = NSFileCoordinator(filePresenter: nil)
            var error: NSError?
            fileCoordinator.coordinateWritingItemAtURL(object.fileURL, options: .ForDeleting, error: &error, byAccessor: {
                (url) -> Void in
                let fileManager = NSFileManager()
                do {
                    try fileManager.removeItemAtURL(object.fileURL)
                    completion?(true, nil)
                } catch {
                    completion?(false, error)
                }
            })

        }

        removeObjectFromArray(object.fileURL)
    }

    // MARK: - Array Handling

    private func updateObject(fileURL: NSURL, metaData: DocumentMetaData?, state: UIDocumentState?, version: NSFileVersion?, downloaded: Bool) {
        if let index = indexOf(fileURL) {
            let entry = objects[index]
            entry.metaData = metaData
            entry.version = version
            entry.state = state
            entry.downloaded = downloaded
            delegate?.reloadObjectAtIndex(index)
        } else {
            let entry = DocumentsOverviewObject(fileURL: fileURL, state: state, metaData: metaData, version: version)
            entry.downloaded = downloaded
            objects.append(entry)
            delegate?.insertObjectAtIndex(objects.count - 1)
        }
    }

    private func objectForURL(fileURL: NSURL) -> DocumentsOverviewObject? {
        guard let index = indexOf(fileURL) else {
            // file does not exists
            return nil
        }
        return objects[index]
    }

    private func removeObjectFromArray(fileURL: NSURL) {
        guard let index = indexOf(fileURL) else {
            // file does not exists
            return
        }

        objects.removeAtIndex(index)
        delegate?.removeObjectAtIndex(index)
    }

    private func indexOf(fileURL: NSURL) -> Int? {
        for (index, object) in objects.enumerate() {
            if object.fileURL == fileURL {
                return index
            }
        }
        return nil
    }

    // MARK - Filename Handling

    func getDocumentURL(fileName: String, uniqueFileName: Bool) -> NSURL {
        var newFileName = fileName
        if uniqueFileName {
            newFileName = getUniqueFileName(newFileName) + "." + fileExtension
        } else {
            newFileName = newFileName + "." + fileExtension
        }

        if useiCloud() {
            if let docsDir = iCloudRootURL?.URLByAppendingPathComponent("Documents", isDirectory: true) {
                return docsDir.URLByAppendingPathComponent(newFileName)
            }
        }
        return documentsRootURL.URLByAppendingPathComponent(newFileName)
    }

    func getUniqueFileName(fileName: String, attempts: Int = 0) -> String {
        var attemptCounter = attempts
        if fileNameExistsInObjects(fileName) {
            attemptCounter += 1
            if fileNameExistsInObjects(fileName + String(attemptCounter)) {
                return getUniqueFileName(fileName, attempts: attemptCounter)
            }
            return fileName + String(attemptCounter)
        }
        return fileName
    }

    func fileNameExistsInObjects(fileName: String) -> Bool {
        for entry in objects {
            if entry.fileURL.fileName(false) == fileName {
                return true
            }
        }
        return false
    }

    // MARK - iCloud Query

    private func initializeiCLoud(completion: (success:Bool) -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            () -> Void in
            self.iCloudRootURL = NSFileManager.defaultManager().URLForUbiquityContainerIdentifier(nil)
            if self.iCloudRootURL != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    completion(success: true)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    completion(success: false)
                })
            }
        }
    }

    private func startQuery() {
        stopQuery()

        query = documentQuery
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FileManager.handleQueryNotification(_:)), name: NSMetadataQueryDidFinishGatheringNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FileManager.handleQueryNotification(_:)), name: NSMetadataQueryDidUpdateNotification, object: nil)
        query?.startQuery()

    }

    private func stopQuery() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSMetadataQueryDidFinishGatheringNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSMetadataQueryDidUpdateNotification, object: nil)

        query?.stopQuery()
        query = nil
    }

    func handleQueryNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            guard let items = userInfo[NSMetadataQueryUpdateRemovedItemsKey] as? [NSMetadataItem] where items.count > 0 else {
                checkFiles()
                return
            }
            for item in items where item.fileURL != nil {
                removeObjectFromArray(item.fileURL!)
            }
            for item in items where item.fileURL != nil {
                updateMetadata(item.fileURL!)
            }
            for item in items where item.fileURL != nil {
                updateMetadata(item.fileURL!)
            }
        } else {
            checkFiles()
        }
    }

    private var documentQuery: NSMetadataQuery {
        get {
            let query = NSMetadataQuery()
            query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
            let filePattern = "*." + fileExtension
            query.predicate = NSPredicate(format: "%K Like %@", NSMetadataItemFSNameKey, filePattern)
            return query
        }
    }

}

