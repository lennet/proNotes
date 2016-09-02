//
//  SettingsViewControllerTests.swift
//  proNotes
//
//  Created by Leo Thomas on 02/09/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import XCTest
@testable import proNotes

class SettingsViewControllerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDidChangeTypeDelegate() {
        class FakeDelegate: SettingsViewControllerDelegate {
            var didCalledChangeSettingsType = false
            
            func didChangeSettingsType(to newType: SettingsType) {
                didCalledChangeSettingsType = true
            }
        }
    
        let settingsViewController = SettingsViewController()
        let delegate = FakeDelegate()
        settingsViewController.delegate = delegate
        
        XCTAssertFalse(delegate.didCalledChangeSettingsType)
        
        settingsViewController.currentType = .image
        
        XCTAssertTrue(delegate.didCalledChangeSettingsType)
    }
    
    func testDefaultSetup() {
        let settingsViewController = SettingsViewController()
        _ = settingsViewController.view
        
        XCTAssertTrue(settingsViewController.currentType == .pageInfo)
        
        XCTAssertTrue(settingsViewController.currentChildViewController is PageInfoViewController)
    }
    
    func testChangeChildViewController() {
        let settingsViewController = SettingsViewController()
        _ = settingsViewController.view
        
        XCTAssertFalse(settingsViewController.currentType == .image)
        
        XCTAssertFalse(settingsViewController.currentChildViewController is ImageSettingsViewController)
        
        settingsViewController.currentType = .image
        
        XCTAssertTrue(settingsViewController.currentType == .image)
        
        XCTAssertTrue(settingsViewController.currentChildViewController is ImageSettingsViewController)
    }
    
}
