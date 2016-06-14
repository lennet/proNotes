//
//  Document.swift
//  proNotes
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class Document: UIDocument {

    private final let fileExtension = "ProNote"
    private final let metaDataFileName = "note.metaData"
    private final let pagesDataFileName = "note.pagesData"

    var name: String {
        get {
            return fileURL.fileName(true) ?? ""
        }
    }

    var fileWrapper: FileWrapper?

    override init(fileURL url: URL) {
        super.init(fileURL: url)
    }

    override var description: String {
        get {
            return fileURL.fileName(true) ?? super.description
        }
    }

    var _metaData: DocumentMetaData?
    var metaData: DocumentMetaData? {
        get {
            guard _metaData == nil else {
                return _metaData
            }
            if fileWrapper != nil {
                _metaData = decodeObject(metaDataFileName) as? DocumentMetaData
            }
            if _metaData == nil {
                _metaData = DocumentMetaData()
            }
            return _metaData
        }

        set {
            _metaData = newValue
        }
    }

    var _pages: [DocumentPage]?
    var pages: [DocumentPage] {
        get {
            if _pages == nil {
                if fileWrapper != nil {
                    _pages = decodeObject(pagesDataFileName) as? [DocumentPage]
                }
                if _pages == nil {
                    _pages = [DocumentPage]()
                }
            }
            return _pages!
        }

        set {
            _pages = newValue
        }
    }

    subscript(pageIndex: Int) -> DocumentPage? {
        get {
            if pageIndex < pages.count {
                return pages[pageIndex]
            }
            return nil
        }
    }

    // MARK - Load Document

    override func load(fromContents contents: AnyObject, ofType typeName: String?) throws {
        if let wrapper = decodeData(contents as! Data) as? FileWrapper {
            fileWrapper = wrapper
        } else {
//            print(contents)
        }
    }

    func decodeObject(_ fileName: String) -> AnyObject? {
        guard let wrapper = fileWrapper?.fileWrappers?[fileName] else {
            return nil
        }
        guard let data = wrapper.regularFileContents else {
            return nil
        }

        return decodeData(data)
    }

    func decodeData(_ data: Data) -> AnyObject? {
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        return unarchiver.decodeObject(forKey: "data")
    }

    override func save(to url: URL, for saveOperation: UIDocumentSaveOperation, completionHandler: ((Bool) -> Void)?) {
        forceSave = true
        super.save(to: url, for: saveOperation, completionHandler: completionHandler)
        forceSave = false
    }
        
    // MARK - Store Document

    override func contents(forType typeName: String) throws -> AnyObject {
        if metaData == nil {
            return Data()
        }

        var wrappers = [String: FileWrapper]()
        metaData?.thumbImage = pages.first?.previewImage
        encodeObject(metaData!, prefferedFileName: metaDataFileName, wrappers: &wrappers)
        encodeObject(pages, prefferedFileName: pagesDataFileName, wrappers: &wrappers)

        let fileWrapper = FileWrapper(directoryWithFileWrappers: wrappers)
        return encodeObject(fileWrapper)
    }

    func encodeObject(_ object: NSObject, prefferedFileName: String, wrappers: inout [String:FileWrapper]) {
        let data = encodeObject(object)
        let wrapper = FileWrapper(regularFileWithContents: data)
        wrappers[prefferedFileName] = wrapper
    }

    func encodeObject(_ object: NSObject) -> Data {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(object, forKey: "data")
        archiver.finishEncoding()

        return data as Data
    }
    
    var forceSave: Bool = false
    override func hasUnsavedChanges() -> Bool {
        return forceSave
    }

    func getNumberOfPages() -> Int {
        return pages.count;
    }

    func getMaxWidth() -> CGFloat {
        return (pages.sorted(isOrderedBefore: { $0.size.width > $1.size.width }).first?.size.width ?? 0)
    }
    
    override func close(completionHandler: ((Bool) -> Void)?) {
        if DocumentInstance.sharedInstance.document == self {
            DocumentInstance.sharedInstance.document = nil
        }
        super.close(completionHandler: completionHandler)
    }

    // MARK - Pages Manipulation

    func addPDF(_ url: URL) {
        guard let pdf = CGPDFDocument(url as CFURL) else {
            return
        }

        let numberOfPages = pdf.numberOfPages
        for i in 1 ..< numberOfPages + 1 {
            if let pdfData = PDFUtility.getPageAsData(i, document: pdf) {
                let size = PDFUtility.getPDFRect(pdf, pageIndex: i).size
                let page = DocumentPage(pdfData: pdfData as Data, index: pages.count, pdfSize: size)
                pages.append(page)
            }
        }
        DocumentInstance.sharedInstance.informDelegateDidAddPage(pages.count - 1)
    }

    func addEmptyPage() {
        let page = DocumentPage(index: pages.count)
        pages.append(page)
        DocumentInstance.sharedInstance.informDelegateDidAddPage(pages.count - 1)
    }

    func swapPagePositions(_ firstIndex: Int, secondIndex: Int) {
        guard _pages != nil else {
            return
        }

        if firstIndex != secondIndex && firstIndex >= 0 && secondIndex >= 0 && firstIndex < pages.count && secondIndex < pages.count {
            let tmp = firstIndex
            pages[firstIndex].index = secondIndex
            pages[secondIndex].index = tmp
            swap(&_pages![firstIndex], &_pages![secondIndex])
        }
    }

}
