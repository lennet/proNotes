//
//  DocumentPageTests.swift
//  proNotes
//
//  Created by Leo Thomas on 12/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import XCTest

@testable import proNotes
class DocumentPageTests: XCTestCase {
    
    func testEquals() {
        let firstPage = DocumentPage(index: 0)
        let secondPage = DocumentPage(index: 1)
        
        XCTAssertEqual(firstPage, firstPage)
        XCTAssertNotEqual(firstPage, secondPage)

        firstPage.addSketchLayer(nil)
        firstPage.index = 1
        XCTAssertNotEqual(firstPage, secondPage)

        secondPage.addSketchLayer(nil)
        XCTAssertEqual(firstPage, secondPage)
    }
    
    func testRemoveLayer() {
        let page = DocumentPage(index: 0)
        page.addSketchLayer(nil)
        page.addTextLayer("Text testlayer")
        
        let layerCount = page.layers.count

        let layer = TextLayer(index: 1, docPage: page, origin: CGPoint.zero, size: CGSize.zero, text: "This ist not the orginal Textlayer")
        page.removeLayer(layer) // nothing should happen because layer is not in layers array
        
        XCTAssertEqual(page.layers.count, layerCount)
        
        page.removeLayer(page.layers[0])
        XCTAssertEqual(page.layers.count, layerCount-1)
        
        XCTAssertEqual(page.layers[0].type, DocumentLayerType.text)
        
    }
    
    func testSwapLayer() {
        let page = DocumentPage(index: 0)
        page.addSketchLayer(nil)
        page.addTextLayer("Text testlayer")
        
        let firstLayer = page[0]
        let secondLayer = page[1]
        
        page.swapLayerPositions(0, secondIndex: 2) // nothing should happen because secondIndex is out of range
        
        XCTAssertEqual(firstLayer, page[0])
        XCTAssertEqual(secondLayer, page[1])
        
        page.addSketchLayer(nil)
        page.addTextLayer("Text testlayer")
        page.addSketchLayer(nil)
        page.addTextLayer("Text testlayer")
        page.addSketchLayer(nil)
        page.addTextLayer("Text testlayer")
        
        let oldPage = page
        
        page.swapLayerPositions(0, secondIndex: 1)
        
        XCTAssertEqual(firstLayer, page[1])
        XCTAssertEqual(secondLayer, page[0])
        
        page.swapLayerPositions(1, secondIndex: 0)
        
        XCTAssertEqual(oldPage, page)
    }
    
    /*
     not working for swift 3 on Xcode 8 Beta 1
     
    func testEncodeDecode() {
        let page = DocumentPage(index: 0)
        page.addSketchLayer(nil)
        page.addTextLayer("Text testlayer")
        page.swapLayerPositions(0, secondIndex: 1)
        let archivedPageData = NSKeyedArchiver.archivedData(withRootObject: page)
        let unarchivedPage = NSKeyedUnarchiver.unarchiveObject(with: archivedPageData) as? DocumentPage
        XCTAssertEqual(page, unarchivedPage)
        
        
        let pdfPage =  DocumentPage(index: 0)
        let pdfURL = Bundle(for: self.dynamicType).urlForResource("test", withExtension: "pdf")!
        let documentRef = CGPDFDocument(pdfURL as CFURL)!
        pdfPage.addPDFLayer(PDFUtility.getPageAsData(1, document: documentRef)! as Data)
        
        let archivedPDFPageData = NSKeyedArchiver.archivedData(withRootObject: pdfPage)
        let unarchivedPDFPage = NSKeyedUnarchiver.unarchiveObject(with: archivedPDFPageData) as? DocumentPage

        
        XCTAssertEqual(unarchivedPDFPage, pdfPage)
    }
    */
    
}
