//
//  UITestsHelper.swift
//  proNotes
//
//  Created by Leo Thomas on 15/06/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import XCTest

    /// Creates and opens a document if the app is currently in the document overview
    ///
    /// - returns: the name of the new created document
    func createAndOpenDocument() -> String {
        let app = XCUIApplication()
        app.navigationBars["proNotes.DocumentOverviewView"].buttons["Add"].tap()
        sleep(1)
        let pronotesDocumentviewNavigationBar = app.navigationBars["proNotes.DocumentView"]
        let documentName = pronotesDocumentviewNavigationBar.children(matching: .other).element.children(matching: .textField).element.value as! String
        return documentName
    }


    /// Closes the document if the document editor is currently opened
    func closeDocument() {
        let app = XCUIApplication()
        let pronotesDocumentviewNavigationBar = app.navigationBars["proNotes.DocumentView"]
        pronotesDocumentviewNavigationBar.buttons["Documents"].tap()
        sleep(1)
    }

    /// Renames the document if the document editor is currently opened
    ///
    /// - parameter newName: of the document
    func renameDocument(newName: String) {
        let app = XCUIApplication()
        let pronotesDocumentviewNavigationBar = app.navigationBars["proNotes.DocumentView"]
        let textField = pronotesDocumentviewNavigationBar.children(matching: .other).element.children(matching: .textField).element
        textField.tap()
        textField.clearAndEnterText(newName)
        app.buttons["Return"].tap()
    }


// From StackOverflow User bay.phillips http://stackoverflow.com/a/32894080

extension XCUIElement {
    
    /// Removes any current text in the field before typing in the new value
    ///
    /// - parameter text: the text to enter into the field
    func clearAndEnterText(_ text: String) -> Void {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        
        self.tap()
        
        var deleteString: String = ""
        for _ in stringValue.characters {
            deleteString += "\u{8}"
        }
        self.typeText(deleteString)
        
        self.typeText(text)
    }
}
