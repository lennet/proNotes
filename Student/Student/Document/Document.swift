//
//  Document.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class Document: UIDocument {

    var name = ""
    var pages = [DocumentPage]()
    var url: NSURL
    
    override init(fileURL url: NSURL) {
        self.url = url
        super.init(fileURL: url)
    }
    
    override func contentsForType(typeName: String) throws -> AnyObject {
        var fileWrappers: [String: NSFileWrapper] = [String: NSFileWrapper]()
        for page in pages {
            fileWrappers[String(page.index)] = page.getFileWrapper()
        }
        let contents = NSFileWrapper(directoryWithFileWrappers: fileWrappers)
        let directoryData = NSKeyedArchiver.archivedDataWithRootObject(contents)
//        let compressedData = directoryData.compress(.Compress)
        return directoryData
    }
    
    override func loadFromContents(contents: AnyObject, ofType typeName: String?) throws {
        if let compressedData = contents as? NSData {
//            let directoryData = compressedData.compress(.Decompress)
            let directoryData = compressedData

            if let directoryFileWrapper = NSKeyedUnarchiver.unarchiveObjectWithData(directoryData) as? NSFileWrapper {
                guard let fileWrappers = directoryFileWrapper.fileWrappers else {
                    // todo handle Error
                    return
                }
                for fileWrapper in fileWrappers {
                    let page = DocumentPage(fileWrapper: fileWrapper.1, index: Int(fileWrapper.0)!)
                    pages.append(page)
                }
                pages.sortInPlace({ (firstPage, secondPage) -> Bool in
                    return firstPage.index < secondPage.index
                })

            } else {
                _  = NSKeyedUnarchiver.unarchiveObjectWithData(directoryData)
            }
        }
    }
    
    func addPDF(url: NSURL){
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
        updatePageIndex()
    }
    
    func addImageToPage(image: UIImage, pageIndex: Int){
        if pages.count > pageIndex{
            pages[pageIndex].addImageLayer(image)
            DocumentSynchronizer.sharedInstance.document = self
        }
    }
    
    func addTextToPage(text: String, pageIndex: Int) {
        if pages.count > pageIndex{
            pages[pageIndex].addTextLayer(text)
            DocumentSynchronizer.sharedInstance.document = self
        }
    }
    
    func addPlotToPage(pageIndex: Int) {
        if pages.count > pageIndex{
            pages[pageIndex].addPlotLayer()
            DocumentSynchronizer.sharedInstance.document = self
        }
    }
    
    func getNumberOfPages() -> Int {
        return pages.count;
    }
    
    func updatePageIndex(){
        for (index, page) in pages.enumerate() {
            page.index = index
        }
    }
    
}
