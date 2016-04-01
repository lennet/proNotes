//
//  RetainCycleTests.swift
//  proNotes
//
//  Created by Leo Thomas on 05/03/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import XCTest
import UIKit

@testable import proNotes
import proNotes

class RetainCycleTests: XCTestCase {

    let deviance = 1.02
    
    func testDocumentViewController() {
        // todo edit document (add pages, images etc..)
        let expectation = self.expectationWithDescription("Open Document")
        let storyboard = UIStoryboard(name: "DocumentOverview", bundle: NSBundle.mainBundle())
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        let documentOverViewController = navigationController.visibleViewController

        let oldMemoryUsage = Double(getMemoryUsage()!)
        
        let fileURL = NSBundle(forClass: self.dynamicType).URLForResource("test", withExtension: "ProNote")
        let document = Document(fileURL: fileURL!)
        
        document.openWithCompletionHandler { (success) -> Void in
            DocumentInstance.sharedInstance.document = document

            documentOverViewController!.performSegueWithIdentifier("showDocumentSegue", sender: nil)
            sleep(1)
            XCTAssertGreaterThan(Double(getMemoryUsage()!), oldMemoryUsage)
            
            navigationController.popViewControllerAnimated(false)
            sleep(1)
            document.closeWithCompletionHandler({ (success) -> Void in
                XCTAssertLessThanOrEqual(Double(getMemoryUsage()!), oldMemoryUsage*self.deviance)
                expectation.fulfill()
            })
        }

        self.waitForExpectationsWithTimeout(5, handler: nil)

    }
    
}
