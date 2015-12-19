//
//  PageView.swift
//  Student
//
//  Created by Leo Thomas on 29/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PageView: UIView {
    
    var pdfViewDelegate: PDFViewDelegate?
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
        let panRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
        addGestureRecognizer(panRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        addGestureRecognizer(tapRecognizer)
        
        let pinchRecognizer =  UIPinchGestureRecognizer(target: self, action: Selector("handlePinch:"))
        addGestureRecognizer(pinchRecognizer)
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
    
    func setLayerSelected(index: Int){
        if index < subviews.count {
            selectedSubView?.handleTap(nil)
            selectedSubView = nil
            if let subview = subviews[index] as? PageSubView {
                selectedSubView = subview
                if let movableView = subview as? MovableView {
                    movableView.setSelected()
                    setSubviewsTransparent(index+1, alphaValue: 0.5)
                } else  if let drawingView = subview as? DrawingView {
                    print(drawingView)
                }
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
    
    // MARK: - UIGestureRecognizer
    
    func handlePan(panGestureRecognizer: UIPanGestureRecognizer) {
        if selectedSubView != nil {
            selectedSubView?.handlePan(panGestureRecognizer)
        }
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
        if selectedSubView != nil {
            selectedSubView?.handlePinch(pinchGestureRecognizer)
        }
    }
    
}
