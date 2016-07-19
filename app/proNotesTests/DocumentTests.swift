//
//  DocumentTests.swift
//  proNotes
//
//  Created by Leo Thomas on 11/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import XCTest

@testable import proNotes
class DocumentTests: XCTestCase {
    
    var document: Document!
    var pagesCount = 4
    
    override func setUp() {
        super.setUp()
        let expectation = self.expectation(description: "Open Document")
        
        let fileURL = Bundle(for: self.dynamicType).urlForResource("test", withExtension: "ProNote")
        document = Document(fileURL: fileURL!)
        
        document.open { (success) -> Void in
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
    override func tearDown() {
        let expectation = self.expectation(description: "Open Document")
        document.close(completionHandler: { (success) -> Void in
            XCTAssertTrue(success)
            expectation.fulfill()
        })
        self.waitForExpectations(timeout: 1, handler: nil)
        super.tearDown()
    }
    
    func testOpenDocument() {
        XCTAssertEqual(document.pages.count, pagesCount)
        XCTAssertEqual(document[0]?.layers.count, 3)
        XCTAssertEqual(document[0]?[0]?.type, DocumentLayerType.sketch)
        XCTAssertEqual(document[0]?[1]?.type, DocumentLayerType.image)
        XCTAssertEqual(document[0]?[2]?.type, DocumentLayerType.sketch)
    }
    
    func testAddPage() {
        document.addEmptyPage()
        
        pagesCount += 1
        XCTAssertEqual(document.pages.count, pagesCount)
        XCTAssertEqual(document.pages.last?.layers.count, 0)
    }
    
    /*
    not working for swift 3 on Xcode 8 Beta 1
    func testAddPDF() {
        let pdfURL = Bundle(for: self.dynamicType).urlForResource("test", withExtension: "pdf")!
        document.addPDF(pdfURL)
        
        pagesCount += 3
        XCTAssertEqual(document.pages.count, pagesCount)
        XCTAssertEqual(document.pages.last?.layers.count, 1)
        XCTAssertEqual(document.pages[pagesCount-2].layers.count, 1)
        XCTAssertEqual(document.pages[pagesCount-3].layers.count, 1)
        
        XCTAssertEqual(document.pages.last?.layers.first?.type, DocumentLayerType.pdf)
        XCTAssertEqual(document.pages[pagesCount-2].layers.first?.type, DocumentLayerType.pdf)
        XCTAssertEqual(document.pages[pagesCount-3].layers.first?.type, DocumentLayerType.pdf)
        
        let lastPage = document.pages.last!
        let pdfLayer = lastPage.layers.first as! PDFLayer
        let pdfDocument = PDFUtility.createPDFFromData(data: pdfLayer.pdfData! as CFData)
        let pdfSize = PDFUtility.getPDFRect(pdfDocument!, pageIndex: 1).size
        XCTAssertEqual(pdfSize, lastPage.size)
    }
    */
    
    func testSwapPages() {
        let pages = document.pages
        
        document.swapPagePositions(0, secondIndex: 4) // nothing should happen because secondIndex is out of range
        
        XCTAssertEqual(pages, document.pages)
        
        let firstPage = document[0]
        let secondPage = document[1]
        
        document.swapPagePositions(0, secondIndex: 1)
        XCTAssertNotEqual(firstPage, document[0])
        XCTAssertNotEqual(secondPage, document[1])
        XCTAssertEqual(firstPage, document[1])
        XCTAssertEqual(secondPage, document[0])

    }
    
}
