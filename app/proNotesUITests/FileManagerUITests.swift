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
       
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        app.launchArguments = ["UITEST"]
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCreateDocument() {
        let documentName = createAndOpenDocument()
        closeDocument()
        let app = XCUIApplication()
        XCTAssertTrue(app.collectionViews.staticTexts[documentName].exists)
    }
    
    func testForDuplicates() {
        let app = XCUIApplication()
        app.navigationBars["proNotes.DocumentOverviewView"].buttons["Add"].tap()
        let pronotesDocumentviewNavigationBar = app.navigationBars["proNotes.DocumentView"]
        let documentName = pronotesDocumentviewNavigationBar.children(matching: .other).element.children(matching: .textField).element.value as! String
        pronotesDocumentviewNavigationBar.buttons["Documents"].tap()
        sleep(1)
        app.navigationBars["proNotes.DocumentOverviewView"].buttons["Add"].tap()
        let newDocumentName = pronotesDocumentviewNavigationBar.children(matching: .other).element.children(matching: .textField).element.value as! String
        
        XCTAssertTrue(newDocumentName != documentName)
    }
    
    func testRename() {
        let app = XCUIApplication()
        app.navigationBars["proNotes.DocumentOverviewView"].buttons["Add"].tap()
        let pronotesDocumentviewNavigationBar = app.navigationBars["proNotes.DocumentView"]
        let textField = pronotesDocumentviewNavigationBar.children(matching: .other).element.children(matching: .textField).element
        textField.tap()
        let documentName = textField.value as! String
        let newName = UUID().uuidString
        textField.clearAndEnterText(newName)
        app.buttons["Return"].tap()
        pronotesDocumentviewNavigationBar.buttons["Documents"].tap()
        sleep(1)
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
