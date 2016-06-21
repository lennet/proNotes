//
//  FileManagerUITests.swift
//  proNotes
//
//  Created by Leo Thomas on 03/06/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import XCTest

class FileManagerUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["UITEST"]
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testCreateDocument() {
        let documentName = createAndOpenDocument()
        closeDocument()
        let app = XCUIApplication()
        XCTAssertTrue(app.collectionViews.staticTexts[documentName].exists)
    }
    
    func testForDuplicates() {
        let documentName = createAndOpenDocument()
        closeDocument()
        let newDocumentName = createAndOpenDocument()
        XCTAssertTrue(newDocumentName != documentName)
    }
    
    func testRename() {
        let app = XCUIApplication()
        let documentName = createAndOpenDocument()
        let newName = UUID().uuidString
        renameDocument(newName: newName)
        closeDocument()
        XCTAssertTrue(app.collectionViews.staticTexts[newName].exists)
        XCTAssertFalse(app.collectionViews.staticTexts[documentName].exists)
    }
    
    func testRenameOverride() {
        let app = XCUIApplication()
        app.navigationBars["proNotes.DocumentOverviewView"].buttons["Add"].tap()
        let pronotesDocumentviewNavigationBar = app.navigationBars["proNotes.DocumentView"]
        let documentName = pronotesDocumentviewNavigationBar.children(matching: .other).element.children(matching: .textField).element.value as! String
        pronotesDocumentviewNavigationBar.buttons["Documents"].tap()
        sleep(1)
        XCTAssertTrue(app.collectionViews.staticTexts[documentName].exists)
        
        
        app.navigationBars["proNotes.DocumentOverviewView"].buttons["Add"].tap()
        let newName = pronotesDocumentviewNavigationBar.children(matching: .other).element.children(matching: .textField).element.value as! String
        pronotesDocumentviewNavigationBar.buttons["Documents"].tap()
        sleep(1)
        XCTAssertTrue(app.collectionViews.staticTexts[newName].exists)
        app.collectionViews.staticTexts[newName].tap()
        
        let textField = pronotesDocumentviewNavigationBar.children(matching: .other).element.children(matching: .textField).element
        textField.tap()
        textField.clearAndEnterText(documentName)
        app.buttons["Return"].tap()
        app.alerts.collectionViews.buttons["CANCEL"].tap()
        XCTAssertEqual(textField.value as? String, newName)
        
        pronotesDocumentviewNavigationBar.buttons["Documents"].tap()
        sleep(1)
        
        XCTAssertTrue(app.collectionViews.staticTexts[newName].exists)
        XCTAssertTrue(app.collectionViews.staticTexts[documentName].exists)
        
        app.collectionViews.staticTexts[newName].tap()
        
        textField.tap()
        textField.clearAndEnterText(documentName)
        app.buttons["Return"].tap()
        app.alerts.collectionViews.buttons["OVERRIDE"].tap()
    
        XCTAssertEqual(documentName, textField.value as? String)
        
        pronotesDocumentviewNavigationBar.buttons["Documents"].tap()
        sleep(1)
        
        XCTAssertFalse(app.collectionViews.staticTexts[newName].exists)
        XCTAssertTrue(app.collectionViews.staticTexts[documentName].exists)
    }
    
}
