//
//  AddLayerUITests.swift
//  proNotes
//
//  Created by Leo Thomas on 07/07/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import XCTest

class AddLayerUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["UITEST"]
        app.launch()
        XCUIDevice.shared().orientation = .landscapeLeft
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateTextLayer() {
        let app = XCUIApplication()
        createAndOpenDocument()
        let layerTableView = app.scrollViews.otherElements.tables
        XCTAssertEqual(layerTableView.cells.matching(identifier: "LayerTableViewCell").count, 0)
        addTextField()
        pressLayerButton()
        XCTAssertTrue(layerTableView.staticTexts["text"].exists, "Textlayer doesn't exists")
        XCTAssertEqual(layerTableView.cells.matching(identifier: "LayerTableViewCell").count, 1)
    }
    
    func testCreateImageLayer() {
        let app = XCUIApplication()
        createAndOpenDocument()
        let layerTableView = app.scrollViews.otherElements.tables
        XCTAssertEqual(layerTableView.cells.matching(identifier: "LayerTableViewCell").count, 0)
        addImage()
        pressLayerButton()
        XCTAssertTrue(layerTableView.staticTexts["image"].exists, "Textlayer doesn't exists")
        XCTAssertEqual(layerTableView.cells.matching(identifier: "LayerTableViewCell").count, 1)
    }
    
    func testCreateSketchCanvas() {
        let app = XCUIApplication()
        createAndOpenDocument()
        let layerTableView = app.scrollViews.otherElements.tables
        XCTAssertEqual(layerTableView.cells.matching(identifier: "LayerTableViewCell").count, 0)
        addSketchLayer()
        pressLayerButton()
        XCTAssertTrue(layerTableView.staticTexts["sketch"].exists, "Textlayer doesn't exists")
        XCTAssertEqual(layerTableView.cells.matching(identifier: "LayerTableViewCell").count, 1)
    }
    
    func testCreatePage() {
        let app = XCUIApplication()
        createAndOpenDocument()
        let layerTableView = app.scrollViews.otherElements.tables
        XCTAssertEqual(layerTableView.cells.matching(identifier: "LayerTableViewCell").count, 0)
        let tablesQuery = app.tables.matching(identifier: "PagesOverViewTableView")
        XCTAssertEqual(tablesQuery.cells.count, 1)
        XCTAssertTrue(app.scrollViews.otherElements.staticTexts["Page 1"].exists, "First Page doesnt exist")
        addEmptyPage()
        tablesQuery.cells.containing(.staticText, identifier:"2").children(matching: .button).element.tap()
        XCTAssertTrue(app.scrollViews.otherElements.staticTexts["Page 2"].exists, "Second Page doesnt exist")
        XCTAssertEqual(layerTableView.cells.matching(identifier: "LayerTableViewCell").count, 0)
        XCTAssertEqual(tablesQuery.cells.count, 2)
    }
    
}
