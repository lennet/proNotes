//
//  FileManager.swift
//  proNotes
//
//  Created by Leo Thomas on 17/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit
import CloudKit

enum RenameError: Error {
    case alreadyExists
    case objectNotFound
    case writingError
    case overwritingError
}

protocol DocumentManagerDelegate: class {

    func reloadObjects()

    func reloadObjectAtIndex(_ index: Int)

    func insertObjectAtIndex(_ index: Int)

    func removeObjectAtIndex(_ index: Int)

}

class DocumentManager {

    static let sharedInstance = DocumentManager()

    private final let fileExtension = "proNote"
    private final let defaultName = NSLocalizedString("Note", comment: "default file name")

    weak var delegate: DocumentManagerDelegate?

    var objects = [DocumentsOverviewObject]()
    var query: NSMetadataQuery?

    var iCloudAvailable = false

    private var _documentsRootUrl: URL?
    var documentsRootURL: URL! {
        get {
            if _documentsRootUrl == nil {
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                _documentsRootUrl = paths.first
            }
            return _documentsRootUrl
        }

        set {
            _documentsRootUrl = newValue
        }
    }

    var iCloudRootURL: URL?

    init() {
        reload()
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
        checkForLocalFiles()
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
                        try (fileURL as NSURL).getResourceValue(&resource, forKey: URLResourceKey.isHiddenKey)
                        if let isHidden = resource as? NSNumber {
                            if !isHidden.boolValue {
                                updateMetadata(fileURL as URL)
                            }
                        }
                    } catch {
                        print("Error: \(error)")
                    }

                } else {
                    updateObject(fileURL as URL, metaData: nil, state: nil, version: nil, downloaded: false)
                }
            }
        }
        query?.enableUpdates()
    }
    
    func checkForLocalFiles() {
        do {
            let documentsPath = documentsRootURL.path
            let allFilesArray = try FileManager.default.contentsOfDirectory(atPath: documentsPath)
            for fileName in allFilesArray {
                let fileURL = URL(fileURLWithPath: documentsPath + "/" + fileName)
                updateMetadata(fileURL)
            }
        } catch {
            print("Error occured while fetching local files: \(error)")
        }

    }

    func useiCloud() -> Bool {
        return Preferences.iCloudActive
    }

    func downloadObject(_ object: DocumentsOverviewObject) {
        do {
            try FileManager.default.startDownloadingUbiquitousItem(at: object.fileURL as URL)
        } catch {
            print("Error: \(error)")
        }
    }

    // MARK: - CRUD
    
    func moveObject(fromURL: URL, to newURL: URL, completion: ((Bool, Error?) -> Void)?) {
        guard let index = indexOf(fromURL) else {
            completion?(false, RenameError.objectNotFound)
            return
        }
        let object = objects[index]
        
        let fileCoordinator = NSFileCoordinator(filePresenter: nil)
        var error: NSError?
        fileCoordinator.coordinate(writingItemAt: fromURL, options: .forMoving, writingItemAt: newURL, options: .forReplacing, error: &error) {
            (newURL1, newURL2) -> Void in
            fileCoordinator.item(at: fromURL, willMoveTo: newURL)
            do {
                try FileManager.default.moveItem(at: fromURL, to: newURL)
            } catch {
                completion?(false, error)
                return
            }
            fileCoordinator.item(at: fromURL, didMoveTo: newURL)
        }
        
        if error == nil {
            removeObjectFromArray(fromURL)
            updateObject(newURL, metaData: object.metaData, state: object.state, version: object.version, downloaded: object.downloaded)
            completion?(true, nil)
        } else {
            completion?(false, RenameError.writingError)
        }
    }
    
    func createDocument(_ completionHandler: @escaping (URL) -> Void) {
        let fileUrl = getDocumentURL(defaultName, uniqueFileName: true)
        print(fileUrl)
        let document = Document(fileURL: fileUrl)
        document.addEmptyPage()
        document.save(to: fileUrl, for: .forCreating) {
            (success) -> Void in
            if !success {
                print("Couldn't create Document: \(document.description)")
                return
            }
            let metaData = document.metaData
            metaData?.fileModificationDate = document.fileModificationDate
            let fileURL = document.fileURL
            let state = document.documentState
            let version = NSFileVersion.currentVersionOfItem(at: fileURL)


            document.close(completionHandler: {
                (sucess) -> Void in
                DispatchQueue.main.async(execute: {
                    self.updateObject(fileURL, metaData: metaData, state: state, version: version, downloaded: true)
                    completionHandler(fileURL)
                })
            })
        }
    }

    private func updateMetadata(_ fileURL: URL) {
        let path = fileURL.path
        
        if FileManager.default.fileExists(atPath: path) {
            let document = Document(fileURL: fileURL)
            document.open {
                (success) -> Void in
                if (!success) {
                    print("Couldn't open Document: \(document.description)")
                    return
                }

                let metaData = document.metaData
                metaData?.fileModificationDate = document.fileModificationDate
                let fileURL = document.fileURL
                let state = document.documentState
                let version = NSFileVersion.currentVersionOfItem(at: fileURL)

                document.close(completionHandler: {
                    (sucess) -> Void in
                    DispatchQueue.main.async(execute: {
                        self.updateObject(fileURL, metaData: metaData, state: state, version: version, downloaded: true)
                    })
                })
            }
        }
    }

    func deleteObject(_ object: DocumentsOverviewObject, completion: ((Bool, Error?) -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            () -> Void in
            let fileCoordinator = NSFileCoordinator(filePresenter: nil)
            var error: NSError?
            fileCoordinator.coordinate(writingItemAt: object.fileURL as URL, options: .forDeleting, error: &error, byAccessor: {
                (url) -> Void in
                let fileManager = FileManager()
                do {
                    try fileManager.removeItem(at: object.fileURL as URL)
                    completion?(true, nil)
                } catch {
                    completion?(false, error)
                }
            })
        }
        removeObjectFromArray(object.fileURL as URL)
    }

    // MARK: - Array Handling

    private func updateObject(_ fileURL: URL, metaData: DocumentMetaData?, state: UIDocumentState?, version: NSFileVersion?, downloaded: Bool) {
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

    func objectForURL(_ fileURL: URL) -> DocumentsOverviewObject? {
        guard let index = indexOf(fileURL) else {
            // file does not exists
            return nil
        }
        return objects[index]
    }

    private func removeObjectFromArray(_ fileURL: URL) {
        guard let index = indexOf(fileURL) else {
            // file does not exists
            return
        }

        objects.remove(at: index)
        delegate?.removeObjectAtIndex(index)
    }

    private func indexOf(_ fileURL: URL) -> Int? {
        for (index, object) in objects.enumerated() {
            if object.fileURL == fileURL {
                return index
            }
        }
        return nil
    }

    // MARK - Filename Handling

    func getDocumentURL(_ fileName: String, uniqueFileName: Bool) -> URL {
        var newFileName = fileName
        if uniqueFileName {
            newFileName = getUniqueFileName(newFileName) + "." + fileExtension
        } else {
            newFileName = newFileName + "." + fileExtension
        }

        if useiCloud() {
            if let docsDir = iCloudRootURL?.appendingPathComponent("Documents", isDirectory: true) {
                return docsDir.appendingPathComponent(newFileName)
            }
        }
        return documentsRootURL.appendingPathComponent(newFileName)
    }

    func getUniqueFileName(_ fileName: String, attempts: Int = 0) -> String {
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

    func fileNameExistsInObjects(_ fileName: String) -> Bool {
        for entry in objects {
            if entry.fileURL.fileName(false) == fileName {
                return true
            }
        }
        return false
    }

    // MARK - iCloud Query

    private func initializeiCLoud(_ completion: @escaping (_ success:Bool) -> ()) {
        guard Preferences.iCloudActive else {
            completion(false)
            return
        }
        DispatchQueue.global(qos: .background).async {
            () -> Void in
            
            self.iCloudRootURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)
            if self.iCloudRootURL != nil {
                DispatchQueue.main.async(execute: {
                    completion(true)
                })
            } else {
                DispatchQueue.main.async(execute: {
                    completion(false)
                })
            }
        }
    }

    private func startQuery() {
        stopQuery()

        query = documentQuery
        NotificationCenter.default.addObserver(self, selector: #selector(handleQueryNotification(_:)), name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleQueryNotification(_:)), name: NSNotification.Name.NSMetadataQueryDidUpdate, object: nil)
        query?.start()

    }

    private func stopQuery() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSMetadataQueryDidUpdate, object: nil)

        query?.stop()
        query = nil
    }

    dynamic func handleQueryNotification(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo {
            guard let items = userInfo[NSMetadataQueryUpdateRemovedItemsKey] as? [NSMetadataItem] , items.count > 0 else {
                checkFiles()
                return
            }
            for item in items where item.fileURL != nil {
                removeObjectFromArray(item.fileURL! as URL)
            }
            for item in items where item.fileURL != nil {
                updateMetadata(item.fileURL! as URL)
            }
            for item in items where item.fileURL != nil {
                updateMetadata(item.fileURL! as URL)
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

