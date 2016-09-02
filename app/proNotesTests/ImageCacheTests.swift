//
//  ImageCacheTests.swift
//  proNotes
//
//  Created by Leo Thomas on 02/09/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import XCTest
@testable import proNotes

class ImageCacheTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStoreImage() {
        let image = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100))).toImage()
        let key = "testKey"
        XCTAssertNil(ImageCache.sharedInstance[key])
        
        ImageCache.sharedInstance[key] = image
        XCTAssertNotNil(ImageCache.sharedInstance[key])
    }
    
    func testClearCache() {
        let image = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100))).toImage()
        let key = "testKey"
        XCTAssertNil(ImageCache.sharedInstance[key])
        
        ImageCache.sharedInstance[key] = image
        XCTAssertNotNil(ImageCache.sharedInstance[key])
        
        ImageCache.sharedInstance.clearCache()
        XCTAssertNil(ImageCache.sharedInstance[key])
    }
    
}
