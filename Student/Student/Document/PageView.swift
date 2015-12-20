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
    
    var page : DocumentPage? {
        didSet{
            setUpLayer()
        }
    }
    
    var selectedSubView: PageSubView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpTouchRecognizer()
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
        
        pinchGestureRecognizer =  UIPinchGestureRecognizer(target: self, action: Selector("handlePinch:"))
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
            view.removeFromSuperview()
        }
        
        for layer in page!.layers where !layer.hidden {
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
        setNeedsDisplay()
    }
    
    func addPDFView(layer: DocumentPDFLayer) {
        let view = PDFView(page: layer.page, frame: bounds)
        view.backgroundColor = UIColor.clearColor()
        view.delegate = pdfViewDelegate
        addSubview(view)
    }
    
    func addDrawingView(drawLayer: DocumentDrawLayer) {
        let view = DrawingView(drawLayer: drawLayer, frame: bounds)
        view.backgroundColor = UIColor.clearColor()
        addSubview(view)
    }
    
    func addImageLayer(imageLayer :ImageLayer){
        let frame = CGRect(origin: imageLayer.origin, size: imageLayer.size)
        let view = MovableImageView(image: imageLayer.image, frame: frame, movableLayer: imageLayer)
        addSubview(view)
        view.setUpImageView()
    }
    
    func addTextLayer(textLayer: TextLayer) {
        let frame = CGRect(origin: textLayer.origin, size: textLayer.size)
        let view = MovableTextView(text: textLayer.text, frame: frame, movableLayer: textLayer)
        addSubview(view)
        view.setUpTextView()
    }
    
    func addPlotLayer(plotLayer: PlotLayer) {
        let frame = CGRect(origin: plotLayer.origin, size: plotLayer.size)
        let view = MovablePlotView(frame: frame, movableLayer: plotLayer)
        addSubview(view)
        view.setUpPlotView()
    }
    
    func getDrawingViews() -> [DrawingView]{
        var result = [DrawingView]()
        for view in subviews {
            if let drawingView = view as? DrawingView {
                result.append(drawingView)
            }
        }
        return result
    }
    
    func handleDrawButtonPressed() {
        guard subviews.count > 0 ,
            let subview = subviews.last as? DrawingView else {
            if let drawLayer = page?.addDrawingLayer(nil){
                addDrawingView(drawLayer)
                DocumentSynchronizer.sharedInstance.updatePage(page!, forceReload: false)
            }
            return
        }
        
        selectedSubView = subview
    }
    
    func setLayerSelected(index: Int){
        if index < subviews.count {
            selectedSubView?.handleTap(nil)
            selectedSubView = nil
            if let subview = subviews[index] as? PageSubView {
                selectedSubView = subview
                if let movableView = subview as? MovableView {
                    movableView.setSelected()
                }
                setSubviewsTransparent(index+1, alphaValue: 0.5)
            }
        }
    }
    
    
    func setSubviewsTransparent(startIndex: Int, alphaValue: CGFloat){
        print(startIndex)
        let transparentSubviews = subviews[startIndex..<subviews.count]
        for subview in transparentSubviews {
            subview.alpha = alphaValue
        }
    }
    
    func deselectSelectedSubview() {
        selectedSubView?.handleTap(nil)
        selectedSubView = nil
        setSubviewsTransparent(0, alphaValue: 1)
    }
    
    func swapLayerPositions(firstIndex: Int, secondIndex: Int){
        if firstIndex != secondIndex && firstIndex >= 0 && secondIndex >= 0 && firstIndex < subviews.count && secondIndex < subviews.count {
            exchangeSubviewAtIndex(firstIndex, withSubviewAtIndex: secondIndex)
            page?.swapLayerPositions(firstIndex, secondIndex: secondIndex)
        }
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
    
}
