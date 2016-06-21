//
//  FileManager.swift
//  proNotes
//
//  Created by Leo Thomas on 17/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit
import CloudKit

enum RenameError: ErrorProtocol {
    case alreadyExists
    case objectNotFound
    case writingError
    case overwritingError
}

protocol FileManagerDelegate: class {

    func reloadObjects()

    func reloadObjectAtIndex(_ index: Int)

    func insertObjectAtIndex(_ index: Int)

    func removeObjectAtIndex(_ index: Int)

}

class FileManager {

    static let sharedInstance = FileManager()

    private final let fileExtension = "proNote"
    private final let defaultName = NSLocalizedString("Note", comment: "default file name")

    weak var delegate: FileManagerDelegate?

    var objects = [DocumentsOverviewObject]()
    var query: NSMetadataQuery?

    var iCloudAvailable = false

    private var _documentsRootUrl: URL?
    var documentsRootURL: URL! {
        get {
            if _documentsRootUrl == nil {
                let paths = Foundation.FileManager.default().urlsForDirectory(.documentDirectory, inDomains: .userDomainMask)
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
            let allFilesArray = try Foundation.FileManager.default().contentsOfDirectory(atPath: documentsRootURL.path!)
            for fileName in allFilesArray {
                let fileURL = URL(fileURLWithPath: documentsRootURL.path! + "/" + fileName)
                updateMetadata(fileURL)
            }
        } catch {
            print("Error occured while fetching local files: \(error)")
        }

    }

    func useiCloud() -> Bool {
        return true
    }

    func downloadObject(_ object: DocumentsOverviewObject) {
        do {
            try Foundation.FileManager.default().startDownloadingUbiquitousItem(at: object.fileURL as URL)
        } catch {
            print("Error: \(error)")
        }
    }

    // MARK: - CRUD

    func renameObject(_ fileURL: URL, fileName: String, forceOverWrite: Bool, completion: ((Bool, ErrorProtocol?) -> Void)?) {
        guard let index = indexOf(fileURL) else {
            completion?(false, RenameError.objectNotFound)
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
                completion?(false, RenameError.alreadyExists)
                return
            }
        }

        let fileCoordinator = NSFileCoordinator(filePresenter: nil)
        var error: NSError?

        fileCoordinator.coordinate(writingItemAt: fileURL, options: .forMoving, writingItemAt: newURL, options: .forReplacing, error: &error) {
            (newURL1, newURL2) -> Void in
            fileCoordinator.item(at: fileURL, willMoveTo: newURL)
            do {
                try Foundation.FileManager.default().moveItem(at: fileURL, to: newURL)
            } catch {
                completion?(false, error)
            }
            fileCoordinator.item(at: fileURL, didMoveTo: newURL)
        }

        if error == nil {
            removeObjectFromArray(fileURL)
            updateObject(newURL, metaData: object.metaData, state: object.state, version: object.version, downloaded: object.downloaded)
            completion?(true, nil)
        } else {
            completion?(false, RenameError.writingError)
        }

    }

    func createDocument(_ completionHandler: (URL) -> Void) {
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
        guard let path = fileURL.path else {
            return
        }
        if Foundation.FileManager.default().fileExists(atPath: path) {
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
        } else {

        }

    }

    func deleteObject(_ object: DocumentsOverviewObject, completion: ((Bool, ErrorProtocol?) -> Void)?) {
        DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosDefault).async {
            () -> Void in
            let fileCoordinator = NSFileCoordinator(filePresenter: nil)
            var error: NSError?
            fileCoordinator.coordinate(writingItemAt: object.fileURL as URL, options: .forDeleting, error: &error, byAccessor: {
                (url) -> Void in
                let fileManager = Foundation.FileManager()
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

    private func objectForURL(_ fileURL: URL) -> DocumentsOverviewObject? {
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
            if let docsDir = try! iCloudRootURL?.appendingPathComponent("Documents", isDirectory: true) {
                return try! docsDir.appendingPathComponent(newFileName)
            }
        }
        return try! documentsRootURL.appendingPathComponent(newFileName)
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

    private func initializeiCLoud(_ completion: (success:Bool) -> ()) {
        DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosDefault).async {
            () -> Void in
            self.iCloudRootURL = Foundation.FileManager.default().urlForUbiquityContainerIdentifier(nil)
            if self.iCloudRootURL != nil {
                DispatchQueue.main.async(execute: {
                    completion(success: true)
                })
            } else {
                DispatchQueue.main.async(execute: {
                    completion(success: false)
                })
            }
        }
    }

    private func startQuery() {
        stopQuery()

        query = documentQuery
        NotificationCenter.default().addObserver(self, selector: #selector(handleQueryNotification(_:)), name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: nil)
        NotificationCenter.default().addObserver(self, selector: #selector(handleQueryNotification(_:)), name: NSNotification.Name.NSMetadataQueryDidUpdate, object: nil)
        query?.start()

    }

    private func stopQuery() {
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: nil)
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name.NSMetadataQueryDidUpdate, object: nil)

        query?.stop()
        query = nil
    }

    dynamic func handleQueryNotification(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo {
            guard let items = userInfo[NSMetadataQueryUpdateRemovedItemsKey] as? [NSMetadataItem] where items.count > 0 else {
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
            query.predicate = Predicate(format: "%K Like %@", NSMetadataItemFSNameKey, filePattern)
            return query
        }
    }

}

