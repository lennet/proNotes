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
    
    var textLayer: TextLayer? {
        return movableLayer as? TextLayer
    }

    override init(frame: CGRect, movableLayer: MovableLayer, renderMode: Bool = false) {
        super.init(frame: frame, movableLayer: movableLayer, renderMode: renderMode)
        widthResizingOnly = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        widthResizingOnly = true
    }

    func setUpTextView() {
        clipsToBounds = true
        if self.textView == nil {
            let textView = NoScrollingTextView()
            textView.userInteractionEnabled = false
            textView.scrollEnabled = false
            textView.delegate = self
            addSubview(textView)

            self.textView = textView
        }
        
        textView?.backgroundColor = textLayer?.backgroundColor
        
        textView?.textColor = textLayer?.textColor
        textView?.text = textLayer?.text
        textView?.font = textLayer?.font
        textView?.textAlignment = textLayer?.alignment ?? .Left
    }

    override func handlePanTranslation(translation: CGPoint) -> CGRect {
        let rect = super.handlePanTranslation(translation)
        updateTextView()
        return rect
    }

    override func setUpSettingsViewController() {
        TextSettingsViewController.delegate = self
        SettingsViewController.sharedInstance?.currentSettingsType = .Text
    }
    
    override func setSelected() {
        super.setSelected()
        textView?.becomeFirstResponder()
    }

    override func setDeselected() {
        super.setDeselected()
        textView?.resignFirstResponder()
    }

    // MARK: - TextSettingsDelegate 

    func changeTextColor(color: UIColor) {
        textLayer?.textColor = color
        textView?.textColor = color
        saveChanges()
    }

    func changeBackgroundColor(color: UIColor) {
        textLayer?.backgroundColor = color
        textView?.backgroundColor = color
        saveChanges()
    }

    func changeAlignment(textAlignment: NSTextAlignment) {
        textLayer?.alignment = textAlignment
        textView?.textAlignment = textAlignment
        updateTextView()
        saveChanges()
    }

    func changeFont(font: UIFont) {
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
        SettingsViewController.sharedInstance?.currentSettingsType = .PageInfo
    }
    
    func getTextLayer() -> TextLayer? {
        return textLayer
    }

    override func undoAction(oldObject: AnyObject?) {
        guard let text = oldObject as? String else {
            super.undoAction(oldObject)
            return
        }
        textView?.text = text
        updateText(text)
    }

    func updateText(newText: String) {
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
        guard textView != nil else {
            return
        }
        textView?.layoutIfNeeded()
        let heightOffset = textView!.contentSize.height - textView!.bounds.size.height
        
        let origin = frame.origin
        var size = bounds.size
        size.height += heightOffset
        frame = CGRect(origin: origin, size: size)
        layoutIfNeeded()
        setNeedsDisplay()
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(textView: UITextView) {
        updateTextView()
    }

    func textViewDidEndEditing(textView: UITextView) {
        updateText(textView.text)
    }

}
