//
//  PageView.swift
//  proNotes
//
//  Created by Leo Thomas on 29/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PageView: UIView, UIGestureRecognizerDelegate {

    var panGestureRecognizer: UIPanGestureRecognizer?
    var tapGestureRecognizer: UITapGestureRecognizer?
    var doubleTapGestureRecognizer: UITapGestureRecognizer?
    
    weak var page: DocumentPage? {
        didSet {
            if oldValue == nil {
                setUpLayer()
            }
        }
    }

    weak var selectedSubView: PageSubView?

    subscript(subViewIndex: Int) -> PageSubView? {
        get {
            if subViewIndex < subviews.count {
                return subviews[subViewIndex] as? PageSubView
            }
            return nil
        }
    }
    
     /**
     - parameter page:       DocumentPage to display
     - parameter renderMode: Optional Bool var which disables autolayout and GestureRecognizers for better render Perfomance & Background Thread support
     */
    init(page: DocumentPage, renderMode: Bool = false) {
        super.init(frame: CGRect(origin: CGPointZero, size: page.size))
        self.page = page
        commonInit(renderMode)
        setUpLayer(renderMode)
        setNeedsDisplay()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit(renderMode: Bool = false) {
        if !renderMode {
            setUpTouchRecognizer()
        }
        
        clearsContextBeforeDrawing = true
        backgroundColor = UIColor.whiteColor()
    }

    func setUpTouchRecognizer() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PageSubView.handlePan(_:)))
        panGestureRecognizer?.cancelsTouchesInView = true
        panGestureRecognizer?.delegate = self
        panGestureRecognizer?.maximumNumberOfTouches = 1
        addGestureRecognizer(panGestureRecognizer!)

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PageSubView.handleTap(_:)))
        tapGestureRecognizer?.cancelsTouchesInView = true
        tapGestureRecognizer?.delegate = self
        addGestureRecognizer(tapGestureRecognizer!)

        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PageSubView.handleDoubleTap(_:)))
        doubleTapGestureRecognizer?.numberOfTapsRequired = 2
        doubleTapGestureRecognizer?.cancelsTouchesInView = true
        doubleTapGestureRecognizer?.delegate = self
        addGestureRecognizer(doubleTapGestureRecognizer!)

        tapGestureRecognizer?.requireGestureRecognizerToFail(doubleTapGestureRecognizer!)
    }

    func setUpLayer(renderMode: Bool = false) {
        guard page != nil else {
            return
        }

        frame.size = page!.size

        for view in subviews {
            // could be improved with recycling existings views
            view.removeFromSuperview()
        }

        for layer in page!.layers {
            switch layer.type {
            case .PDF:
                addPDFView(layer as! DocumentPDFLayer)
                break
            case .Drawing:
                addDrawingView(layer as! DocumentDrawLayer)
                break
            case .Image:
                addImageLayer(layer as! ImageLayer, renderMode: renderMode)
                break
            case .Text:
                addTextLayer(layer as! TextLayer, renderMode: renderMode)
                break
            }
        }
    }

    func addPDFView(pdfLayer: DocumentPDFLayer) {
        let view = PDFView(pdfData: pdfLayer.pdfData!, frame: bounds)
        view.backgroundColor = UIColor.clearColor()
        view.hidden = pdfLayer.hidden
        addSubview(view)
    }

    func addDrawingView(drawLayer: DocumentDrawLayer) {
        let view = DrawingView(drawLayer: drawLayer, frame: bounds)
        view.backgroundColor = UIColor.clearColor()
        view.hidden = drawLayer.hidden
        addSubview(view)
    }

    func addImageLayer(imageLayer: ImageLayer, renderMode: Bool = false) {
        let frame = CGRect(origin: imageLayer.origin, size: imageLayer.size)
        let view = MovableImageView(image: imageLayer.image, frame: frame, movableLayer: imageLayer, renderMode: renderMode)

        view.hidden = imageLayer.hidden
        if renderMode {
            print(imageLayer.size)
            print(view.bounds.size)
        }
        addSubview(view)
        view.setUpImageView()
    }

    func addTextLayer(textLayer: TextLayer, renderMode: Bool = false) {
        let frame = CGRect(origin: textLayer.origin, size: textLayer.size)
        let view = MovableTextView(text: textLayer.text, frame: frame, movableLayer: textLayer, renderMode: renderMode)
        view.hidden = textLayer.hidden
        addSubview(view)
        view.setUpTextView()
    }

    func getDrawingViews() -> [DrawingView] {
        var result = [DrawingView]()
        for view in subviews {
            if let drawingView = view as? DrawingView {
                result.append(drawingView)
            }
        }
        return result
    }

    func handleDrawButtonPressed() {
        guard subviews.count > 0,
        let subview = subviews.last as? DrawingView else {
            if let drawLayer = page?.addDrawingLayer(nil) {
                addDrawingView(drawLayer)
                handleDrawButtonPressed()
            }
            return
        }

        selectedSubView = subview
        selectedSubView?.setSelected?()
    }

    func setLayerSelected(index: Int) {

        selectedSubView?.handleTap?(nil)
        selectedSubView = nil
        if let subview = self[index] {
            subview.setSelected?()
            selectedSubView = subview
            setSubviewsAlpha(index + 1, alphaValue: 0.5)
        } else {
            print("Selecting Layer failed with index:\(index) and subviewsCount \(subviews.count)")
        }
    }

    func deselectSelectedSubview() {
        selectedSubView?.handleTap?(nil)
        selectedSubView = nil
        setSubviewsAlpha(0, alphaValue: 1)
    }

    func swapLayerPositions(firstIndex: Int, secondIndex: Int) {
        if firstIndex != secondIndex && firstIndex >= 0 && secondIndex >= 0 && firstIndex < subviews.count && secondIndex < subviews.count {
            exchangeSubviewAtIndex(firstIndex, withSubviewAtIndex: secondIndex)
        } else {
            print("Swap Layerpositions failed with firstIndex:\(firstIndex) and secondIndex\(secondIndex) and subviewsCount \(subviews.count)")
        }
    }

    func changeLayerVisibility(docLayer: DocumentLayer) {
        let isHidden = !docLayer.hidden
        if let subview = self[docLayer.index] as? UIView {
            subview.hidden = isHidden
        }
        page?.changeLayerVisibility(isHidden, layer: docLayer)
    }

    func removeLayer(docLayer: DocumentLayer) {
        if let subview = self[docLayer.index] as? UIView {
            subview.removeFromSuperview()
        }
        docLayer.removeFromPage()
    }

//    override func drawRect(rect: CGRect) {
//        let path = UIBezierPath()
//
//        let xOffset: CGFloat = 20
//        let yOffset: CGFloat = 20
//
//        var currentXPos = xOffset
//        var currentYPos = yOffset
//
//        while (currentXPos < rect.width) {
//            path.moveToPoint(CGPoint(x: currentXPos, y: 0))
//            path.addLineToPoint(CGPoint(x: currentXPos, y: rect.height))
//
//            currentXPos += xOffset
//        }
//
//        while (currentYPos < rect.height) {
//            path.moveToPoint(CGPoint(x: 0, y: currentYPos))
//            path.addLineToPoint(CGPoint(x: rect.width, y: currentYPos))
//            currentYPos += yOffset
//        }
//
//        path.stroke()
//    }

    // MARK: - UIGestureRecognizer

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        (selectedSubView as? DrawingView)?.touchesBegan(touches, withEvent: event)
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        (selectedSubView as? DrawingView)?.touchesMoved(touches, withEvent: event)
    }

    override func touchesEnded(touches: Set<UITouch>,
                               withEvent event: UIEvent?) {
        (selectedSubView as? DrawingView)?.touchesEnded(touches, withEvent: event)
    }

    override func touchesCancelled(touches: Set<UITouch>?,
                                   withEvent event: UIEvent?) {
        (selectedSubView as? DrawingView)?.touchesCancelled(touches, withEvent: event)
    }

    func handlePan(panGestureRecognizer: UIPanGestureRecognizer) {
        selectedSubView?.handlePan?(panGestureRecognizer)
    }

    func handleTap(tapGestureRecognizer: UITapGestureRecognizer) {
        if selectedSubView != nil {
            deselectSelectedSubview()
        } else {
            let location = tapGestureRecognizer.locationInView(self)
            for subview in subviews.reverse() where subview.isKindOfClass(MovableView) {
                let pageSubview = subview as! PageSubView
                if (pageSubview as? UIView)?.frame.contains(location) ?? false {
                    pageSubview.handleTap?(tapGestureRecognizer)
                    selectedSubView = pageSubview
                    return
                }
            }
        }

    }

    func handleDoubleTap(tapGestureRecognizer: UITapGestureRecognizer) {
        selectedSubView?.handleDoubleTap?(tapGestureRecognizer)
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let _ = selectedSubView as? DrawingView {
            return false
        }
        return true
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }


}
