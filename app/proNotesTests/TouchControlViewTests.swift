//
//  TouchControlViewTests.swift
//  proNotes
//
//  Created by Leo Thomas on 28/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import XCTest

@testable import proNotes
class TouchControlViewTests: XCTestCase {
    
    func testTouchedControlView() {
        let touchControlView = TouchControlView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 300, height: 300)))
        
        let center = touchControlView.frame.getCenter()
        var touchedControl = touchControlView.touchedControlRect(center)
        XCTAssertEqual(touchedControl, TouchControlView.TouchControl.Center)
        
        let topLeft = CGPoint.zero
        touchedControl = touchControlView.touchedControlRect(topLeft)
        XCTAssertEqual(touchedControl, TouchControlView.TouchControl.TopLeftCorner)
        
        let topRight = CGPoint(x: touchControlView.frame.width, y: 0)
        touchedControl = touchControlView.touchedControlRect(topRight)
        XCTAssertEqual(touchedControl, TouchControlView.TouchControl.TopRightCorner)
        
        let topCenter = CGPoint(x: center.x, y: 0)
        touchedControl = touchControlView.touchedControlRect(topCenter)
        XCTAssertEqual(touchedControl, TouchControlView.TouchControl.TopSide)
        
        let bottomLeft = CGPoint(x: 0, y: touchControlView.frame.height)
        touchedControl = touchControlView.touchedControlRect(bottomLeft)
        XCTAssertEqual(touchedControl, TouchControlView.TouchControl.BottomLeftCorner)
        
        let bottomRight = CGPoint(x: touchControlView.frame.width, y: touchControlView.frame.height)
        touchedControl = touchControlView.touchedControlRect(bottomRight)
        XCTAssertEqual(touchedControl, TouchControlView.TouchControl.BottomRightCorner)
        
        let bottomCenter = CGPoint(x: center.x, y: touchControlView.frame.height)
        touchedControl = touchControlView.touchedControlRect(bottomCenter)
        XCTAssertEqual(touchedControl, TouchControlView.TouchControl.BottomSide)
        
        let leftCenter = CGPoint(x: 0, y: center.y)
        touchedControl = touchControlView.touchedControlRect(leftCenter)
        XCTAssertEqual(touchedControl, TouchControlView.TouchControl.LeftSide)
        
        let rightCenter = CGPoint(x: touchControlView.frame.width, y: center.y)
        touchedControl = touchControlView.touchedControlRect(rightCenter)
        XCTAssertEqual(touchedControl, TouchControlView.TouchControl.RightSide)
        
        let outside = CGPoint(x: center.x, y: touchControlView.frame.height+touchControlView.controlLength)
        touchedControl = touchControlView.touchedControlRect(outside)
        XCTAssertEqual(touchedControl, TouchControlView.TouchControl.None)
    }
    
    func testResizeWidthOnly() {
        let touchControlView = TouchControlView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 100)))
        touchControlView.widthResizingOnly = true

        let translation = CGPoint(x: 20, y: 20)
        
        touchControlView.selectedTouchControl = .Center
        XCTAssertEqual(touchControlView.handlePanTranslation(translation).height, touchControlView.bounds.height)
        touchControlView.selectedTouchControl = .LeftSide
        XCTAssertEqual(touchControlView.handlePanTranslation(translation).height, touchControlView.bounds.height)
        touchControlView.selectedTouchControl = .RightSide
        XCTAssertEqual(touchControlView.handlePanTranslation(translation).height, touchControlView.bounds.height)
        touchControlView.selectedTouchControl = .TopLeftCorner
        XCTAssertEqual(touchControlView.handlePanTranslation(translation).height, touchControlView.bounds.height)
        touchControlView.selectedTouchControl = .TopRightCorner
        XCTAssertEqual(touchControlView.handlePanTranslation(translation).height, touchControlView.bounds.height)
        touchControlView.selectedTouchControl = .TopSide
        XCTAssertEqual(touchControlView.handlePanTranslation(translation).height, touchControlView.bounds.height)
        touchControlView.selectedTouchControl = .BottomLeftCorner
        XCTAssertEqual(touchControlView.handlePanTranslation(translation).height, touchControlView.bounds.height)
        touchControlView.selectedTouchControl = .BottomRightCorner
        XCTAssertEqual(touchControlView.handlePanTranslation(translation).height, touchControlView.bounds.height)
        touchControlView.selectedTouchControl = .BottomSide
        XCTAssertEqual(touchControlView.handlePanTranslation(translation).height, touchControlView.bounds.height)
        touchControlView.selectedTouchControl = .None
        XCTAssertEqual(touchControlView.handlePanTranslation(translation).height, touchControlView.bounds.height)
    }
    
    func testProportionalResize() {
        let touchControlView = TouchControlView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 300, height: 200)))
        touchControlView.proportionalResize = true
        
        let translation = CGPoint(x: 20, y: 20)
        let originalRatio = touchControlView.frame.width / touchControlView.frame.height
        
        touchControlView.selectedTouchControl = .Center
        var newRect = touchControlView.handlePanTranslation(translation)
        var newRatio = newRect.width / newRect.height
        XCTAssertEqual(originalRatio, newRatio)
        
        touchControlView.selectedTouchControl = .LeftSide
        newRect = touchControlView.handlePanTranslation(translation)
        newRatio = newRect.width / newRect.height
        XCTAssertEqual(originalRatio, newRatio)
        
        touchControlView.selectedTouchControl = .RightSide
        newRect = touchControlView.handlePanTranslation(translation)
        newRatio = newRect.width / newRect.height
        XCTAssertEqual(originalRatio, newRatio)
        
        touchControlView.selectedTouchControl = .TopLeftCorner
        newRect = touchControlView.handlePanTranslation(translation)
        newRatio = newRect.width / newRect.height
        XCTAssertEqual(originalRatio, newRatio)
        
        touchControlView.selectedTouchControl = .TopRightCorner
        newRect = touchControlView.handlePanTranslation(translation)
        newRatio = newRect.width / newRect.height
        XCTAssertEqual(originalRatio, newRatio)
        
        touchControlView.selectedTouchControl = .TopSide
        newRect = touchControlView.handlePanTranslation(translation)
        newRatio = newRect.width / newRect.height
        XCTAssertEqual(originalRatio, newRatio)
        
        touchControlView.selectedTouchControl = .BottomLeftCorner
        newRect = touchControlView.handlePanTranslation(translation)
        newRatio = newRect.width / newRect.height
        XCTAssertEqual(originalRatio, newRatio)
        
        touchControlView.selectedTouchControl = .BottomRightCorner
        newRect = touchControlView.handlePanTranslation(translation)
        newRatio = newRect.width / newRect.height
        XCTAssertEqual(originalRatio, newRatio)
        
        touchControlView.selectedTouchControl = .BottomSide
        newRect = touchControlView.handlePanTranslation(translation)
        newRatio = newRect.width / newRect.height
        XCTAssertEqual(originalRatio, newRatio)
        
        touchControlView.selectedTouchControl = .None
        newRect = touchControlView.handlePanTranslation(translation)
        newRatio = newRect.width / newRect.height
        XCTAssertEqual(originalRatio, newRatio)
    }
    
}
