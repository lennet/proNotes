//
//  LayerTableViewUITests.swift
//  proNotes
//
//  Created by Leo Thomas on 07/07/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import XCTest

class LayerTableViewUITests: XCTestCase {
        
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
    
    func testDeleteLayer() {
        createAndOpenDocument()
        addTextField()
        pressLayerButton()
        let app = XCUIApplication()
        let layerTableView = app.scrollViews.otherElements.tables
        let textFieldCell = layerTableView.cells.matching(identifier: "LayerTableViewCell").element(boundBy: 0)
        textFieldCell.buttons.matching(identifier: "deleteLayerButton").element.tap()
        sleep(1)
        XCTAssertEqual(layerTableView.cells.matching(identifier: "LayerTableViewCell").count, 0)
    }
    
    /*
     not working in current Xcode/ Swift Beta 3
    func testHideLayer() {
        createAndOpenDocument()
        addTextField()
        let app = XCUIApplication()
        let testInput = UUID().uuidString
        app.typeText(testInput)
        pressLayerButton()
        XCTAssertTrue(app.otherElements.staticTexts[testInput].exists, "Changed Text exists")
        let layerTableView = app.scrollViews.otherElements.tables
        let textFieldCell = layerTableView.cells.matching(identifier: "LayerTableViewCell").element(boundBy: 0)
        textFieldCell.buttons.matching(identifier: "hideLayerButton").element.tap()
        XCTAssertTrue(!app.otherElements.staticTexts[testInput].exists, "Changed is not hidden")
        textFieldCell.buttons.matching(identifier: "hideLayerButton").element.tap()
        XCTAssertTrue(app.otherElements.staticTexts[testInput].exists, "Changed is still hidden")
    }
     */
}
