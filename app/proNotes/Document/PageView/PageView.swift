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
    
    weak var page: DocumentPage? {
        didSet {
            if oldValue == nil {
//                setUpLayer()
            }
        }
    }

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
        super.init(frame: CGRect(origin: CGPoint.zero, size: page.size))
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

    func commonInit(_ renderMode: Bool = false) {
        if !renderMode {
            setUpTouchRecognizer()
        }
        
        clearsContextBeforeDrawing = true
        backgroundColor = UIColor.white()
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

    func setUpLayer(_ renderMode: Bool = false) {
        for view in subviews {
            view.removeFromSuperview()
        }
        guard page != nil else {
            return
        }

        frame.size = page!.size

        for layer in page!.layers {
            switch layer.type {
            case .pdf:
                addPDFView(layer as! PDFLayer)
                break
            case .sketch:
                addSketchView(layer as! SketchLayer)
                break
            case .image:
                addImageLayer(layer as! ImageLayer, renderMode: renderMode)
                break
            case .text:
                addTextLayer(layer as! TextLayer, renderMode: renderMode)
                break
            }
        }
    }

    func addPDFView(_ pdfLayer: PDFLayer) {
        let view = PDFView(pdfData: pdfLayer.pdfData!, frame: bounds)
        view.backgroundColor = UIColor.clear()
        view.isHidden = pdfLayer.hidden
        addSubview(view)
    }

    func addSketchView(_ sketchLayer: SketchLayer) {
        let view = SketchView(sketchLayer: sketchLayer, frame: bounds)
        view.backgroundColor = UIColor.clear()
        view.isHidden = sketchLayer.hidden
        addSubview(view)
    }

    func addImageLayer(_ imageLayer: ImageLayer, renderMode: Bool = false) {
        let frame = CGRect(origin: imageLayer.origin, size: imageLayer.size)
        let view = MovableImageView(frame: frame, movableLayer: imageLayer, renderMode: renderMode)
        view.isHidden = imageLayer.hidden
        addSubview(view)
        view.setUpImageView()
    }

    func addTextLayer(_ textLayer: TextLayer, renderMode: Bool = false) {
        let frame = CGRect(origin: textLayer.origin, size: textLayer.size)
        let view = MovableTextView(frame: frame, movableLayer: textLayer, renderMode: renderMode)
        view.isHidden = textLayer.hidden
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

    func setLayerSelected(_ index: Int) {
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

    func swapLayerPositions(_ firstIndex: Int, secondIndex: Int) {
        if firstIndex != secondIndex && firstIndex >= 0 && secondIndex >= 0 && firstIndex < subviews.count && secondIndex < subviews.count {
            exchangeSubview(at: firstIndex, withSubviewAt: secondIndex)
        } else {
            print("Swap Layerpositions failed with firstIndex:\(firstIndex) and secondIndex\(secondIndex) and subviewsCount \(subviews.count)")
        }
    }

    func changeLayerVisibility(_ docLayer: DocumentLayer) {
        let isHidden = !docLayer.hidden
        if let subview = self[docLayer.index] as? UIView {
            subview.isHidden = isHidden
        }
        page?.changeLayerVisibility(isHidden, layer: docLayer)
    }

    func removeLayer(_ docLayer: DocumentLayer) {
        if let subview = self[docLayer.index] as? UIView {
            subview.removeFromSuperview()
        }
        docLayer.removeFromPage()
    }

    // MARK: - UIGestureRecognizer

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        (selectedSubView as? SketchView)?.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        (selectedSubView as? SketchView)?.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        (selectedSubView as? SketchView)?.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>,
                                   with event: UIEvent?) {
        (selectedSubView as? SketchView)?.touchesCancelled(touches, with: event)
    }

    func handlePan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        selectedSubView?.handlePan?(panGestureRecognizer)
    }

    func handleTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
        if selectedSubView != nil {
            deselectSelectedSubview()
        } else {
            let location = tapGestureRecognizer.location(in: self)
            for case let subview as MovableView in subviews.reversed() {
                let pageSubview = subview as PageSubView
                if !subview.isHidden && (pageSubview as? UIView)?.frame.contains(location) ?? false {
                    selectedSubView = pageSubview
                    return
                }
            }
        }
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(selectedSubView is SketchView)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // check if the user is currently selecting text
        if otherGestureRecognizer.view is UITextView {
            return false
        }
        return true
        
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
}
