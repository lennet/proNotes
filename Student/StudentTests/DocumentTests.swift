//
//  DocumentTests.swift
//  Student
//
//  Created by Leo Thomas on 11/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import XCTest

@testable import Student
class DocumentTests: XCTestCase {
    
    var document: Document!
    var pagesCount = 4
    
    // todo test save and reload operation
    
    override func setUp() {
        super.setUp()
        let expectation = self.expectationWithDescription("Open Document")
        
        let fileURL = NSBundle(forClass: self.dynamicType).URLForResource("test", withExtension: "ProNote")
        document = Document(fileURL: fileURL!)
        
        document.openWithCompletionHandler { (success) -> Void in
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(0.5, handler: nil)
    }
    
    override func tearDown() {
        let expectation = self.expectationWithDescription("Open Document")
        document.closeWithCompletionHandler({ (success) -> Void in
            XCTAssertTrue(success)
            expectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(0.5, handler: nil)
        super.tearDown()
    }
    
    func testOpenDocument() {
        XCTAssertEqual(document.pages.count, pagesCount)
        XCTAssertEqual(document[0]?.layers.count, 3)
        XCTAssertEqual(document[0]?[0]?.type, DocumentLayerType.Drawing)
        XCTAssertEqual(document[0]?[1]?.type, DocumentLayerType.Image)
        XCTAssertEqual(document[0]?[2]?.type, DocumentLayerType.Drawing)
    }
    
    func testDocumentManipulation() {
        document.addEmptyPage()
        
        pagesCount += 1
        XCTAssertEqual(document.pages.count, pagesCount)
        XCTAssertEqual(document.pages.last?.layers.count, 0)
        
        let pdfURL = NSBundle(forClass: self.dynamicType).URLForResource("test", withExtension: "pdf")!
        document.addPDF(pdfURL)
        
        pagesCount += 3
        XCTAssertEqual(document.pages.count, pagesCount)
        XCTAssertEqual(document.pages.last?.layers.count, 1)
        XCTAssertEqual(document.pages[pagesCount-2].layers.count, 1)
        XCTAssertEqual(document.pages[pagesCount-3].layers.count, 1)
        
        XCTAssertEqual(document.pages.last?.layers.first?.type, DocumentLayerType.PDF)
        XCTAssertEqual(document.pages[pagesCount-2].layers.first?.type, DocumentLayerType.PDF)
        XCTAssertEqual(document.pages[pagesCount-3].layers.first?.type, DocumentLayerType.PDF)
        
    }
    
}
