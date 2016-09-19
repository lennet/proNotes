//
//  PageViewTests.swift
//  proNotes
//
//  Created by Leo Thomas on 02/09/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import XCTest
@testable import proNotes

class PageViewTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAddSketchLayer() {
        
        let page = DocumentPage(index: 0)
        
        let pageView = PageView(page: page)
        
        XCTAssertTrue(page.layers.count == 0)
        
        XCTAssertTrue(pageView.subviews.count == 0)
        
        pageView.addSketchLayer()
        
        XCTAssertNotNil(pageView.subviews.first is SketchView)
        
        XCTAssertNotNil(page.layers.first is SketchLayer)
        
        XCTAssertTrue(pageView.selectedSubView is SketchView)
    }
    
    func testGetSketchViews() {
        let page = DocumentPage(index: 0)
        
        let pageView = PageView(page: page)
        
        XCTAssertTrue(pageView.getSketchViews().count == 0)
        
        let firstSketchView = SketchView(sketchLayer: SketchLayer(index: 0, image: nil, docPage: page), frame: .zero)
        let secondSketchView = SketchView(sketchLayer: SketchLayer(index: 0, image: nil, docPage: page), frame: .zero)
        let imageLayer = MovableImageView(frame: .zero, movableLayer: MovableLayer(index: 0, type: .image, docPage: page, origin: .zero, size: .zero))
        
        pageView.addSubview(firstSketchView)
        pageView.addSubview(imageLayer)
        pageView.addSubview(secondSketchView)
        
        XCTAssertTrue(pageView.getSketchViews().count == 2)
        XCTAssertTrue(pageView.getSketchViews().first == firstSketchView)
        XCTAssertTrue(pageView.getSketchViews().last == secondSketchView)
    }
    
    
    func testAddSubViewForLayer() {
        class FakePageView: PageView {
            
            var calledAddSketchView = false
            
            
            private override func addSketchView(_ sketchLayer: SketchLayer) {
                calledAddSketchView = true
            }
            
            var calledAddTextView = false
            
            private override func addTextView(_ textLayer: TextLayer, renderMode: Bool) {
                calledAddTextView = true
            }
            
            var calledAddImageView = false
            
            private override func addImageView(_ imageLayer: ImageLayer, renderMode: Bool) {
                calledAddImageView = true
            }
            
            var calledAddPdfView = false
            
            private override func addPDFView(_ pdfLayer: PDFLayer) {
                calledAddPdfView = true
            }
            
        }
        
        let pageView = FakePageView()
        
        XCTAssertFalse(pageView.calledAddPdfView)
        XCTAssertFalse(pageView.calledAddImageView)
        XCTAssertFalse(pageView.calledAddSketchView)
        XCTAssertFalse(pageView.calledAddTextView)
        
        let page = DocumentPage(index: 0)
        
        pageView.addSubView(for:  PDFLayer(index: 0, pdfData: Data(), docPage: page))
        pageView.addSubView(for:  ImageLayer(index: 0, docPage: page, origin: .zero, size: .zero, image: UIImage()))
        pageView.addSubView(for: TextLayer(index: 0, docPage: page, origin: .zero, size: .zero, text: "Test"))
        pageView.addSubView(for: SketchLayer(index: 0, image: nil, docPage: page))
        
        XCTAssertTrue(pageView.calledAddPdfView)
        XCTAssertTrue(pageView.calledAddImageView)
        XCTAssertTrue(pageView.calledAddSketchView)
        XCTAssertTrue(pageView.calledAddTextView)
    }

    class FakeAddSubViewPageView: PageView {
        
        var addedSubView: UIView?
        
        override func addSubview(_ view: UIView) {
            addedSubView = view
        }
    }
    
    func testAddSketchView() {
        let pageView = FakeAddSubViewPageView()
        XCTAssertNil(pageView.addedSubView)
        
        let sketchLayer = SketchLayer(index: 0, image: UIImage(), docPage: DocumentPage(index: 0))
        pageView.addSketchView(sketchLayer)
        
        let sketchView = pageView.addedSubView as! SketchView
        XCTAssertEqual(sketchView.sketchLayer , sketchLayer)
    }
    
    func testAddTextView() {
        let pageView = FakeAddSubViewPageView()
        XCTAssertNil(pageView.addedSubView)
        
        let textLayer = TextLayer(index: 0, docPage: DocumentPage(index: 0), origin: .zero, size: .zero, text: "Test")
        pageView.addTextView(textLayer)
        
        let textView = pageView.addedSubView as! MovableTextView
        XCTAssertEqual(textView.textLayer , textLayer)
    }
    
    func testAddImageView() {
        let pageView = FakeAddSubViewPageView()
        XCTAssertNil(pageView.addedSubView)
        
        let imageLayer = ImageLayer(index: 0, docPage: DocumentPage(index: 0), origin: .zero, size: .zero, image: UIImage())
        pageView.addImageView(imageLayer)
        
        let imageView = pageView.addedSubView as! MovableImageView
        XCTAssertEqual(imageView.imageLayer, imageLayer)
    }
    
    func testAddPDfView() {
        let pageView = FakeAddSubViewPageView()
        XCTAssertNil(pageView.addedSubView)
        
        let pdfLayer = PDFLayer(index: 0, pdfData: Data(), docPage: DocumentPage(index: 0))
        pageView.addPDFView(pdfLayer)
        
        XCTAssertNotNil(pageView.addedSubView as? PDFView)
    }
    
}
