//
//  DocumentPageTests.swift
//  Student
//
//  Created by Leo Thomas on 12/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import XCTest

@testable import Student
class DocumentPageTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    func testEquals() {
        let firstPage = DocumentPage(index: 0)
        let secondPage = DocumentPage(index: 1)
        
        XCTAssertEqual(firstPage, firstPage)
        XCTAssertNotEqual(firstPage, secondPage)

        firstPage.addDrawingLayer(nil)
        firstPage.index = 1
        XCTAssertNotEqual(firstPage, secondPage)

        secondPage.addDrawingLayer(nil)
        XCTAssertEqual(firstPage, secondPage)
    }
    
    func testRemoveLayer() {
        let page = DocumentPage(index: 0)
        page.addDrawingLayer(nil)
        page.addTextLayer("Text testlayer")
        
        let layerCount = page.layers.count

        let layer = TextLayer(index: 1, docPage: page, origin: CGPointZero, size: CGSizeZero, text: "This ist not the orginal Textlayer")
        page.removeLayer(layer) // nothing should happen because layer is not in layers array
        
        XCTAssertEqual(page.layers.count, layerCount)
        
        page.removeLayer(page.layers[0])
        XCTAssertEqual(page.layers.count, layerCount-1)
        
        XCTAssertEqual(page.layers[0].type, DocumentLayerType.Text)
        
    }
    
    func testSwapLayer() {
        let page = DocumentPage(index: 0)
        page.addDrawingLayer(nil)
        page.addTextLayer("Text testlayer")
        
        let firstLayer = page[0]
        let secondLayer = page[1]
        
        page.swapLayerPositions(0, secondIndex: 2) // nothing should happen because secondIndex is out of range
        
        XCTAssertEqual(firstLayer, page[0])
        XCTAssertEqual(secondLayer, page[1])
        
        page.addDrawingLayer(nil)
        page.addTextLayer("Text testlayer")
        page.addDrawingLayer(nil)
        page.addTextLayer("Text testlayer")
        page.addDrawingLayer(nil)
        page.addTextLayer("Text testlayer")
        
        let oldPage = page
        
        page.swapLayerPositions(0, secondIndex: 1)
        
        XCTAssertEqual(firstLayer, page[1])
        XCTAssertEqual(secondLayer, page[0])
        
        page.swapLayerPositions(1, secondIndex: 0)
        
        XCTAssertEqual(oldPage, page)
    }
    
    func testEncodeDecode() {
        let page = DocumentPage(index: 0)
        page.addDrawingLayer(nil)
        page.addTextLayer("Text testlayer")
        page.swapLayerPositions(0, secondIndex: 1)
        let archivedPageData = NSKeyedArchiver.archivedDataWithRootObject(page)
        let unarchivedPage = NSKeyedUnarchiver.unarchiveObjectWithData(archivedPageData) as? DocumentPage
        XCTAssertEqual(page, unarchivedPage)
    }
    
    
}
