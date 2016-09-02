//
//  PreferencesTests.swift
//  proNotes
//
//  Created by Leo Thomas on 02/09/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import XCTest
@testable import proNotes

class PreferencesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIsFirstRun() {
        Preferences.isFirstRun = false
        XCTAssertFalse(Preferences.isFirstRun)
        
        Preferences.isFirstRun = true
        XCTAssertTrue(Preferences.isFirstRun)
    }
    
    func testiCloudActive() {
        Preferences.iCloudActive = false
        XCTAssertFalse(Preferences.iCloudActive)
        
        Preferences.iCloudActive = true
        XCTAssertTrue(Preferences.iCloudActive)
    }
    
    func testShouldShowWelcomScreen() {
        Preferences.showWelcomeScreen = false
        XCTAssertFalse(Preferences.showWelcomeScreen)
        
        Preferences.showWelcomeScreen = true
        XCTAssertTrue(Preferences.showWelcomeScreen)
    }
}
