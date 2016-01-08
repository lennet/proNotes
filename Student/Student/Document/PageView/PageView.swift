//
//  PageView.swift
//  Student
//
//  Created by Leo Thomas on 29/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PageView: UIView, UIGestureRecognizerDelegate {

    var pdfViewDelegate: PDFViewDelegate?

    var panGestureRecognizer: UIPanGestureRecognizer?
    var tapGestureRecognizer: UITapGestureRecognizer?
    var pinchGestureRecognizer: UIPinchGestureRecognizer?
    var doubleTapGestureRecognizer: UITapGestureRecognizer?


    var page: DocumentPage? {
        didSet {
            if oldValue == nil {
                setUpLayer()
            }
        }
    }

    var selectedSubView: PageSubView?

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpTouchRecognizer()
        clearsContextBeforeDrawing = true
    }

    func setUpTouchRecognizer() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
        panGestureRecognizer?.cancelsTouchesInView = true
        panGestureRecognizer?.delegate = self
        addGestureRecognizer(panGestureRecognizer!)

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        tapGestureRecognizer?.cancelsTouchesInView = true
        tapGestureRecognizer?.delegate = self
        addGestureRecognizer(tapGestureRecognizer!)

        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: Selector("handlePinch:"))
        pinchGestureRecognizer?.cancelsTouchesInView = true
        pinchGestureRecognizer?.delegate = self
        addGestureRecognizer(pinchGestureRecognizer!)

        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        doubleTapGestureRecognizer?.numberOfTapsRequired = 2
        doubleTapGestureRecognizer?.cancelsTouchesInView = true
        doubleTapGestureRecognizer?.delegate = self
        addGestureRecognizer(doubleTapGestureRecognizer!)

        tapGestureRecognizer?.requireGestureRecognizerToFail(doubleTapGestureRecognizer!)
    }

    func setUpLayer() {

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
                addImageLayer(layer as! ImageLayer)
                break
            case .Text:
                addTextLayer(layer as! TextLayer)
                break
            case .Plot:
                addPlotLayer(layer as! PlotLayer)
                break
            }
        }
//        setNeedsDisplay()
    }

    func addPDFView(pdfLayer: DocumentPDFLayer) {
        let view = PDFView(page: pdfLayer.page, frame: bounds)
        view.backgroundColor = UIColor.clearColor()
        view.delegate = pdfViewDelegate
        view.hidden = pdfLayer.hidden
        addSubview(view)
    }

    func addDrawingView(drawLayer: DocumentDrawLayer) {
        let view = DrawingView(drawLayer: drawLayer, frame: bounds)
        view.backgroundColor = UIColor.clearColor()
        view.hidden = drawLayer.hidden
        addSubview(view)
    }

    func addImageLayer(imageLayer: ImageLayer) {
        let frame = CGRect(origin: imageLayer.origin, size: imageLayer.size)
        let view = MovableImageView(image: imageLayer.image, frame: frame, movableLayer: imageLayer)
        view.hidden = imageLayer.hidden
        addSubview(view)
        view.setUpImageView()
    }

    func addTextLayer(textLayer: TextLayer) {
        let frame = CGRect(origin: textLayer.origin, size: textLayer.size)
        let view = MovableTextView(text: textLayer.text, frame: frame, movableLayer: textLayer)
        view.hidden = textLayer.hidden
        addSubview(view)
        view.setUpTextView()
    }

    func addPlotLayer(plotLayer: PlotLayer) {
        let frame = CGRect(origin: plotLayer.origin, size: plotLayer.size)
        let view = MovablePlotView(frame: frame, movableLayer: plotLayer)
        view.hidden = plotLayer.hidden
        addSubview(view)
        view.setUpPlotView()
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
                DocumentSynchronizer.sharedInstance.updatePage(page!, forceReload: false)
                handleDrawButtonPressed()
            }
            return
        }
        subview.setSelected()
        selectedSubView = subview
    }

    func setLayerSelected(index: Int) {
        if index < subviews.count {
            selectedSubView?.handleTap(nil)
            selectedSubView = nil
            if let subview = subviews[index] as? PageSubView {
                subview.setSelected()
                selectedSubView = subview
                setSubviewsTransparent(index + 1, alphaValue: 0.5)
            }
        } else {
            print("Selecting Layer failed with index:\(index) and subviewsCount \(subviews.count)")
        }
    }

    func setSubviewsTransparent(startIndex: Int, alphaValue: CGFloat) {
        let transparentSubviews = subviews[startIndex ..< subviews.count]
        for subview in transparentSubviews {
            subview.alpha = alphaValue
        }
    }

    func deselectSelectedSubview() {
        selectedSubView?.handleTap(nil)
        selectedSubView = nil
        setSubviewsTransparent(0, alphaValue: 1)
    }

    func swapLayerPositions(firstIndex: Int, secondIndex: Int) {
        if firstIndex != secondIndex && firstIndex >= 0 && secondIndex >= 0 && firstIndex < subviews.count && secondIndex < subviews.count {
            exchangeSubviewAtIndex(firstIndex, withSubviewAtIndex: secondIndex)
            page?.swapLayerPositions(firstIndex, secondIndex: secondIndex)
        } else {
            print("Swap Layerpositions failed with firstIndex:\(firstIndex) and secondIndex\(secondIndex) and subviewsCount \(subviews.count)")
        }
    }

    func changeLayerVisibility(docLayer: DocumentLayer) {
        let isHidden = !docLayer.hidden
        if docLayer.index < subviews.count {
            if let subview = subviews[docLayer.index] as? PageSubView {
                subview.hidden = isHidden
            }
        }
        page?.changeLayerVisibility(isHidden, layer: docLayer)
    }

    func removeLayer(docLayer: DocumentLayer) {
        if docLayer.index < subviews.count {
            if let subview = subviews[docLayer.index] as? PageSubView {
                subview.removeFromSuperview()
            }
        }
        page?.removeLayer(docLayer, forceReload: false)
    }

    override func drawRect(rect: CGRect) {
        let path = UIBezierPath()

        let xOffset: CGFloat = 20
        let yOffset: CGFloat = 20

        var currentXPos = xOffset
        var currentYPos = yOffset

        while (currentXPos < rect.width) {
            path.moveToPoint(CGPoint(x: currentXPos, y: 0))
            path.addLineToPoint(CGPoint(x: currentXPos, y: rect.height))

            currentXPos += xOffset
        }

        while (currentYPos < rect.height) {
            path.moveToPoint(CGPoint(x: 0, y: currentYPos))
            path.addLineToPoint(CGPoint(x: rect.width, y: currentYPos))
            currentYPos += yOffset
        }

        path.stroke()
    }

    // MARK: - UIGestureRecognizer

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let drawingView = selectedSubView as? DrawingView {
            drawingView.touchesBegan(touches, withEvent: event)
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let drawingView = selectedSubView as? DrawingView {
            drawingView.touchesMoved(touches, withEvent: event)
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let drawingView = selectedSubView as? DrawingView {
            drawingView.touchesEnded(touches, withEvent: event)
        }
    }

    func handlePan(panGestureRecognizer: UIPanGestureRecognizer) {
        selectedSubView?.handlePan(panGestureRecognizer)
    }

    func handleTap(tapGestureRecognizer: UITapGestureRecognizer) {
        if selectedSubView != nil {
            // todo improve
            deselectSelectedSubview()
        } else {
            let location = tapGestureRecognizer.locationInView(self)
            for subview in subviews.reverse() where subview.isKindOfClass(MovableView) {
                let pageSubview = subview as! PageSubView
                if pageSubview.frame.contains(location) {
                    pageSubview.handleTap(tapGestureRecognizer)
                    selectedSubView = pageSubview
                    return
                }
            }
        }

    }

    func handlePinch(pinchGestureRecognizer: UIPinchGestureRecognizer) {
        selectedSubView?.handlePinch(pinchGestureRecognizer)
    }

    func handleDoubleTap(tapGestureRecognizer: UITapGestureRecognizer) {
        selectedSubView?.handleDoubleTap(tapGestureRecognizer)
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

}
