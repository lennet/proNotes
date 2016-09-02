//
//  DocumentLayerTests.swift
//  proNotes
//
//  Created by Leo Thomas on 06/07/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import XCTest

@testable import proNotes
class DocumentLayerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTextLayer() {
        let documentPage = DocumentPage(index: 0)
        let textLayer = TextLayer(index: 0, docPage: documentPage, origin: .zero, size: .zero, text: "")
        
        XCTAssertEqual(textLayer.name, String(describing: textLayer.type))
        
        textLayer.text = "Test 124"
        XCTAssertNotEqual(textLayer.name, String(describing: textLayer.type))
        XCTAssert(textLayer.name.contains(textLayer.text))
        
        textLayer.text = "Foo525"
        XCTAssertNotEqual(textLayer.name, String(describing: textLayer.type))
        XCTAssert(textLayer.name.contains(textLayer.text))
        
        let newName = "Test Name"
        textLayer.name  = newName
        XCTAssertNotEqual(textLayer.name, String(describing: textLayer.type))
        XCTAssertFalse(textLayer.name.contains(textLayer.text))
        XCTAssertEqual(textLayer.name, newName)
        textLayer.text = "Bar 987"
        XCTAssertNotEqual(textLayer.name, String(describing: textLayer.type))
        XCTAssertFalse(textLayer.name.contains(textLayer.text))
        XCTAssertEqual(textLayer.name, newName)
        
        textLayer.text = ""
        textLayer.name = ""
        XCTAssertEqual(textLayer.name, String(describing: textLayer.type))
        XCTAssertFalse(textLayer.name.contains(textLayer.text))
        XCTAssertNotEqual(textLayer.name, "")
        
        textLayer.text = "BlaBla"
        XCTAssertNotEqual(textLayer.name, String(describing: textLayer.type))
        XCTAssert(textLayer.name.contains(textLayer.text))
        XCTAssertNotEqual(textLayer.name, "")
    }
    
}
