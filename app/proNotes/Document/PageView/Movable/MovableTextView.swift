//
//  MovableTextView.swift
//  proNotes
//
//  Created by Leo Thomas on 09/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class MovableTextView: MovableView, UITextViewDelegate, TextSettingsDelegate {
    
    weak var textView: UITextView?
    var renderMode: Bool
    
    var textLayer: TextLayer? {
        return movableLayer as? TextLayer
    }

    override init(frame: CGRect, movableLayer: MovableLayer, renderMode: Bool = false) {
        self.renderMode = renderMode
        super.init(frame: frame, movableLayer: movableLayer, renderMode: renderMode)
        widthResizingOnly = true
    }

    required init?(coder aDecoder: NSCoder) {
        renderMode = false
        super.init(coder: aDecoder)
        widthResizingOnly = true
    }

    func setUpTextView() {
        clipsToBounds = true
        if self.textView == nil {
            let textView = NoScrollingTextView()
            
            textView.isUserInteractionEnabled = false
            textView.isScrollEnabled = !renderMode
            textView.delegate = self
            textView.isAccessibilityElement = true
            
            addSubview(textView)
            self.textView = textView
            accessibilityIdentifier = "MovableTextView"
        }
        
        textView?.backgroundColor = textLayer?.backgroundColor
        
        textView?.textColor = textLayer?.textColor
        textView?.text = textLayer?.text
        textView?.accessibilityLabel = textLayer?.text
        textView?.font = textLayer?.font
        textView?.textAlignment = textLayer?.alignment ?? .left
    }

    override func handlePanTranslation(_ translation: CGPoint) -> CGRect {
        let rect = super.handlePanTranslation(translation)
        updateTextView()
        return rect
    }

    override func setUpSettingsViewController() {
        TextSettingsViewController.delegate = self
        SettingsViewController.sharedInstance?.currentType = .text
    }
    
    override func setSelected() {
        super.setSelected()
        textView?.becomeFirstResponder()
        textView?.isUserInteractionEnabled = true
    }

    override func setDeselected() {
        super.setDeselected()
        textView?.resignFirstResponder()
        textView?.isUserInteractionEnabled = false
    }

    // MARK: - TextSettingsDelegate 

    func changeTextColor(_ color: UIColor) {
        textLayer?.textColor = color
        textView?.textColor = color
        saveChanges()
    }

    func changeBackgroundColor(_ color: UIColor) {
        textLayer?.backgroundColor = color
        textView?.backgroundColor = color
        saveChanges()
    }

    func changeAlignment(_ textAlignment: NSTextAlignment) {
        textLayer?.alignment = textAlignment
        textView?.textAlignment = textAlignment
        updateTextView()
        saveChanges()
    }

    func changeFont(_ font: UIFont) {
        textLayer?.font = font
        textView?.font = font
        updateTextView()
        saveChanges()
    }

    func removeText() {
        textView?.text = ""
        updateTextView()
    }
    
    func removeLayer() {
        removeFromSuperview()
        textLayer?.removeFromPage()
        movableLayer = nil
        SettingsViewController.sharedInstance?.currentType = .pageInfo
    }
    
    func getTextLayer() -> TextLayer? {
        return textLayer
    }

    override func undoAction(_ oldObject: Any?) {
        guard let text = oldObject as? String else {
            super.undoAction(oldObject)
            return
        }
        textView?.text = text
        updateText(text)
    }

    func updateText(_ newText: String) {
        textView?.accessibilityLabel = newText
        if let textLayer = movableLayer as? TextLayer {
            if textLayer.docPage != nil {
                DocumentInstance.sharedInstance.registerUndoAction(textLayer.text, pageIndex: textLayer.docPage.index, layerIndex: textLayer.index)
            }
            textLayer.text = textView?.text ?? textLayer.text
            saveChanges()
        }

    }
    
    override func saveChanges() {
        textLayer?.size = textView?.bounds.size ?? bounds.size
        super.saveChanges()
    }

    func updateTextView() {
        guard let textView = textView else {
            return
        }
        textView.layoutIfNeeded()
        let heightOffset = textView.contentSize.height - textView.bounds.size.height
        
        let origin = frame.origin
        var size = bounds.size
        size.height += heightOffset
        frame = CGRect(origin: origin, size: size)
        layoutIfNeeded()
        setNeedsDisplay()
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        updateTextView()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        updateText(textView.text)
    }

}
