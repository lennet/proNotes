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
        let touchControlView = TouchControlView(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 300)))
        
        let center = touchControlView.frame.getCenter()
        var touchedControl = touchControlView.touchedControlRect(center)
        XCTAssertEqual(touchedControl, TouchControlView.TouchControl.center)
        
        let topLeft: CGPoint = .zero
        touchedControl = touchControlView.touchedControlRect(topLeft)
        XCTAssertEqual(touchedControl, TouchControlView.TouchControl.topLeftCorner)
        
        let topRight = CGPoint(x: touchControlView.frame.width, y: 0)
        touchedControl = touchControlView.touchedControlRect(topRight)
        XCTAssertEqual(touchedControl, TouchControlView.TouchControl.topRightCorner)
        
        let topCenter = CGPoint(x: center.x, y: 0)
        touchedControl = touchControlView.touchedControlRect(topCenter)
        XCTAssertEqual(touchedControl, TouchControlView.TouchControl.topSide)
        
        let bottomLeft = CGPoint(x: 0, y: touchControlView.frame.height)
        touchedControl = touchControlView.touchedControlRect(bottomLeft)
        XCTAssertEqual(touchedControl, TouchControlView.TouchControl.bottomLeftCorner)
        
        let bottomRight = CGPoint(x: touchControlView.frame.width, y: touchControlView.frame.height)
        touchedControl = touchControlView.touchedControlRect(bottomRight)
        XCTAssertEqual(touchedControl, TouchControlView.TouchControl.bottomRightCorner)
        
        let bottomCenter = CGPoint(x: center.x, y: touchControlView.frame.height)
        touchedControl = touchControlView.touchedControlRect(bottomCenter)
        XCTAssertEqual(touchedControl, TouchControlView.TouchControl.bottomSide)
        
        let leftCenter = CGPoint(x: 0, y: center.y)
        touchedControl = touchControlView.touchedControlRect(leftCenter)
        XCTAssertEqual(touchedControl, TouchControlView.TouchControl.leftSide)
        
        let rightCenter = CGPoint(x: touchControlView.frame.width, y: center.y)
        touchedControl = touchControlView.touchedControlRect(rightCenter)
        XCTAssertEqual(touchedControl, TouchControlView.TouchControl.rightSide)
        
        let outside = CGPoint(x: center.x, y: touchControlView.frame.height+touchControlView.controlLength)
        touchedControl = touchControlView.touchedControlRect(outside)
        XCTAssertEqual(touchedControl, TouchControlView.TouchControl.none)
    }
    
    func testResizeWidthOnly() {
        let touchControlView = TouchControlView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        touchControlView.widthResizingOnly = true

        let translation = CGPoint(x: 20, y: 20)
        
        touchControlView.selectedTouchControl = .center
        XCTAssertEqual(touchControlView.handlePanTranslation(translation).height, touchControlView.bounds.height)
        touchControlView.selectedTouchControl = .leftSide
        XCTAssertEqual(touchControlView.handlePanTranslation(translation).height, touchControlView.bounds.height)
        touchControlView.selectedTouchControl = .rightSide
        XCTAssertEqual(touchControlView.handlePanTranslation(translation).height, touchControlView.bounds.height)
        touchControlView.selectedTouchControl = .topLeftCorner
        XCTAssertEqual(touchControlView.handlePanTranslation(translation).height, touchControlView.bounds.height)
        touchControlView.selectedTouchControl = .topRightCorner
        XCTAssertEqual(touchControlView.handlePanTranslation(translation).height, touchControlView.bounds.height)
        touchControlView.selectedTouchControl = .topSide
        XCTAssertEqual(touchControlView.handlePanTranslation(translation).height, touchControlView.bounds.height)
        touchControlView.selectedTouchControl = .bottomLeftCorner
        XCTAssertEqual(touchControlView.handlePanTranslation(translation).height, touchControlView.bounds.height)
        touchControlView.selectedTouchControl = .bottomRightCorner
        XCTAssertEqual(touchControlView.handlePanTranslation(translation).height, touchControlView.bounds.height)
        touchControlView.selectedTouchControl = .bottomSide
        XCTAssertEqual(touchControlView.handlePanTranslation(translation).height, touchControlView.bounds.height)
        touchControlView.selectedTouchControl = .none
        XCTAssertEqual(touchControlView.handlePanTranslation(translation).height, touchControlView.bounds.height)
    }
    
    func testProportionalResize() {
        let touchControlView = TouchControlView(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 200)))
        touchControlView.proportionalResize = true
        
        let translation = CGPoint(x: 20, y: 20)
        let originalRatio = touchControlView.frame.width / touchControlView.frame.height
        
        touchControlView.selectedTouchControl = .center
        var newRect = touchControlView.handlePanTranslation(translation)
        var newRatio = newRect.width / newRect.height
        XCTAssertEqual(originalRatio, newRatio)
        
        touchControlView.selectedTouchControl = .leftSide
        newRect = touchControlView.handlePanTranslation(translation)
        newRatio = newRect.width / newRect.height
        XCTAssertEqual(originalRatio, newRatio)
        
        touchControlView.selectedTouchControl = .rightSide
        newRect = touchControlView.handlePanTranslation(translation)
        newRatio = newRect.width / newRect.height
        XCTAssertEqual(originalRatio, newRatio)
        
        touchControlView.selectedTouchControl = .topLeftCorner
        newRect = touchControlView.handlePanTranslation(translation)
        newRatio = newRect.width / newRect.height
        XCTAssertEqual(originalRatio, newRatio)
        
        touchControlView.selectedTouchControl = .topRightCorner
        newRect = touchControlView.handlePanTranslation(translation)
        newRatio = newRect.width / newRect.height
        XCTAssertEqual(originalRatio, newRatio)
        
        touchControlView.selectedTouchControl = .topSide
        newRect = touchControlView.handlePanTranslation(translation)
        newRatio = newRect.width / newRect.height
        XCTAssertEqual(originalRatio, newRatio)
        
        touchControlView.selectedTouchControl = .bottomLeftCorner
        newRect = touchControlView.handlePanTranslation(translation)
        newRatio = newRect.width / newRect.height
        XCTAssertEqual(originalRatio, newRatio)
        
        touchControlView.selectedTouchControl = .bottomRightCorner
        newRect = touchControlView.handlePanTranslation(translation)
        newRatio = newRect.width / newRect.height
        XCTAssertEqual(originalRatio, newRatio)
        
        touchControlView.selectedTouchControl = .bottomSide
        newRect = touchControlView.handlePanTranslation(translation)
        newRatio = newRect.width / newRect.height
        XCTAssertEqual(originalRatio, newRatio)
        
        touchControlView.selectedTouchControl = .none
        newRect = touchControlView.handlePanTranslation(translation)
        newRatio = newRect.width / newRect.height
        XCTAssertEqual(originalRatio, newRatio)
    }
    
}
