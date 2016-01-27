//
//  Document.swift
//  Student
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
    
    var fileWrapper: NSFileWrapper?

    override init(fileURL url: NSURL) {
        super.init(fileURL: url)
    }
    
    override var description: String {
        get {
            return fileURL.fileName(true) ?? super.description
        }
    }
    
    var _metaData :DocumentMetaData?
    var metaData: DocumentMetaData? {
        get {
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
    
    // MARK - Load Document
    
    override func loadFromContents(contents: AnyObject, ofType typeName: String?) throws {
        if let wrapper = decodeData(contents as! NSData) as? NSFileWrapper {
            fileWrapper = wrapper
        } else {
            print(contents)
        }
    }
    
    func decodeObject(fileName: String) -> AnyObject? {
        guard let wrapper = fileWrapper?.fileWrappers?[fileName] else {
            return nil
        }
        guard let data =  wrapper.regularFileContents else {
            return nil
        }
        
        return decodeData(data)
    }
    
    func decodeData(data: NSData) -> AnyObject? {
        let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
        return unarchiver.decodeObjectForKey("data")
    }
    
    // MARK - Store Document
    
    override func contentsForType(typeName: String) throws -> AnyObject {
        if metaData == nil {
            return NSData()
        }
        
        var wrappers = [String: NSFileWrapper]()
        encodeObject(metaData!, prefferedFileName: metaDataFileName, wrappers: &wrappers)
        encodeObject(pages, prefferedFileName: pagesDataFileName, wrappers: &wrappers)
        
        let fileWrapper = NSFileWrapper(directoryWithFileWrappers: wrappers)
        return encodeObject(fileWrapper)
    }
    
    func encodeObject(object: NSObject, prefferedFileName: String, inout wrappers:[String: NSFileWrapper]){
        let data = encodeObject(object)
        let wrapper = NSFileWrapper(regularFileWithContents: data)
        wrappers[prefferedFileName] = wrapper
    }
    
    func encodeObject(object: NSObject) -> NSData {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(object, forKey: "data")
        archiver.finishEncoding()

        return data
    }

    // MARK - Pages Manipulation
    // export to custom object ?
    
    func addPDF(url: NSURL) {
        let pdf = CGPDFDocumentCreateWithURL(url as CFURLRef)
        for var i = 1; i <= CGPDFDocumentGetNumberOfPages(pdf); i++ {
            if let page = CGPDFDocumentGetPage(pdf, i) {
                let page = DocumentPage(PDF: page, index: pages.count)
                pages.append(page)
            }
        }
    }

    func addEmptyPage() {
        let page = DocumentPage(index: pages.count)
        pages.append(page)
    }

    func addImageToPage(image: UIImage, pageIndex: Int) {
        if pages.count > pageIndex {
            pages[pageIndex].addImageLayer(image)
            DocumentSynchronizer.sharedInstance.document = self
        }
    }

    func addTextToPage(text: String, pageIndex: Int) {
        if pages.count > pageIndex {
            pages[pageIndex].addTextLayer(text)
            DocumentSynchronizer.sharedInstance.document = self
        }
    }

    func addPlotToPage(pageIndex: Int) {
        if pages.count > pageIndex {
            pages[pageIndex].addPlotLayer()
            DocumentSynchronizer.sharedInstance.document = self
        }
    }

    func getNumberOfPages() -> Int {
        return pages.count;
    }
}
