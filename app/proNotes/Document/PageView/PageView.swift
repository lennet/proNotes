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
    
    weak var page: DocumentPage?

    weak var selectedSubView: PageSubView? {
        didSet {
            oldValue?.setDeselected?()
            selectedSubView?.setSelected?()
            if selectedSubView == nil {
                SettingsViewController.sharedInstance?.currentSettingsType = .PageInfo
            }
            PagesTableViewController.sharedInstance?.twoTouchesForScrollingRequired = selectedSubView != nil
        }
    }

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
     - parameter renderMode: Optional Bool var which disables GestureRecognizers and AutoLayout for better render Perfomance
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
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PageView.handlePan(_:)))
        panGestureRecognizer?.cancelsTouchesInView = true
        panGestureRecognizer?.delegate = self
        panGestureRecognizer?.maximumNumberOfTouches = 1
        addGestureRecognizer(panGestureRecognizer!)

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PageView.handleTap(_:)))
        tapGestureRecognizer?.cancelsTouchesInView = true
        tapGestureRecognizer?.delegate = self
        addGestureRecognizer(tapGestureRecognizer!)
    }

    func setUpLayer(renderMode: Bool = false) {
        for view in subviews {
            view.removeFromSuperview()
        }
        guard page != nil else {
            return
        }

        frame.size = page!.size

        for layer in page!.layers {
            switch layer.type {
            case .PDF:
                addPDFView(layer as! PDFLayer)
                break
            case .Sketch:
                addSketchView(layer as! SketchLayer)
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

    func addPDFView(pdfLayer: PDFLayer) {
        let view = PDFView(pdfData: pdfLayer.pdfData!, frame: bounds)
        view.backgroundColor = UIColor.clearColor()
        view.hidden = pdfLayer.hidden
        addSubview(view)
    }

    func addSketchView(sketchLayer: SketchLayer) {
        let view = SketchView(sketchLayer: sketchLayer, frame: bounds)
        view.backgroundColor = UIColor.clearColor()
        view.hidden = sketchLayer.hidden
        addSubview(view)
    }

    func addImageLayer(imageLayer: ImageLayer, renderMode: Bool = false) {
        let frame = CGRect(origin: imageLayer.origin, size: imageLayer.size)
        let view = MovableImageView(frame: frame, movableLayer: imageLayer, renderMode: renderMode)
        view.hidden = imageLayer.hidden
        addSubview(view)
        view.setUpImageView()
    }

    func addTextLayer(textLayer: TextLayer, renderMode: Bool = false) {
        let frame = CGRect(origin: textLayer.origin, size: textLayer.size)
        let view = MovableTextView(frame: frame, movableLayer: textLayer, renderMode: renderMode)
        view.hidden = textLayer.hidden
        addSubview(view)
        view.setUpTextView()
    }

    func getSketchViews() -> [SketchView] {
        var result = [SketchView]()
        for view in subviews {
            if let sketchView = view as? SketchView {
                result.append(sketchView)
            }
        }
        return result
    }

    func handleSketchButtonPressed() {
        guard subviews.count > 0,
        let subview = subviews.last as? SketchView else {
            addSketchLayer()
            return
        }

        selectedSubView = subview
        selectedSubView?.setSelected?()
    }
    
    func addSketchLayer() {
        if let sketchLayer = page?.addSketchLayer(nil) {
            addSketchView(sketchLayer)
            handleSketchButtonPressed()
        }
    }

    func setLayerSelected(index: Int) {
        selectedSubView?.setSelected?()
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
        selectedSubView?.setDeselected?()
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

    // MARK: - UIGestureRecognizer

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        (selectedSubView as? SketchView)?.touchesBegan(touches, withEvent: event)
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        (selectedSubView as? SketchView)?.touchesMoved(touches, withEvent: event)
    }

    override func touchesEnded(touches: Set<UITouch>,
                               withEvent event: UIEvent?) {
        (selectedSubView as? SketchView)?.touchesEnded(touches, withEvent: event)
    }

    override func touchesCancelled(touches: Set<UITouch>?,
                                   withEvent event: UIEvent?) {
        (selectedSubView as? SketchView)?.touchesCancelled(touches, withEvent: event)
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
                if !subview.hidden && (pageSubview as? UIView)?.frame.contains(location) ?? false {
                    selectedSubView = pageSubview
                    return
                }
            }
        }
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let _ = selectedSubView as? SketchView {
            return false
        }
        
        return true
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // check if the user is currently selecting text
        if otherGestureRecognizer.view is UITextView {
            return false
        }
        return true
        
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
}
