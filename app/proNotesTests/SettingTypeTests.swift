//
//  SettingTypeTests.swift
//  proNotes
//
//  Created by Leo Thomas on 02/09/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import XCTest
@testable import proNotes

class SettingTypeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInstantiatePageInfoViewController() {
        XCTAssertTrue(SettingsType.pageInfo.viewController is PageInfoViewController)
    }
    
    func testInstantiateImageSettingsViewController() {
        XCTAssertTrue(SettingsType.image.viewController is ImageSettingsViewController)
    }
    
    func testInstantiateSketchSettingsViewController() {
        XCTAssertTrue(SettingsType.sketch.viewController is SketchSettingsViewController)
    }
    
    func testInstantiateTextSettingsViewController() {
        XCTAssertTrue(SettingsType.text.viewController is TextSettingsViewController)
    }
}
