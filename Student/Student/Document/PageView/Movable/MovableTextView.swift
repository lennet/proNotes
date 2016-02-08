//
//  MovableTextView.swift
//  Student
//
//  Created by Leo Thomas on 09/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class MovableTextView: MovableView, UITextViewDelegate, TextSettingsDelegate {

    var text = ""
    weak var textView: UITextView?

    init(text: String, frame: CGRect, movableLayer: MovableLayer) {
        self.text = text
        super.init(frame: frame, movableLayer: movableLayer)
        widthResizingOnly = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        widthResizingOnly = true
    }

    func setUpTextView() {
        clipsToBounds = true
        if self.textView == nil {
            let textView = UITextView()
            textView.userInteractionEnabled = false
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.backgroundColor = UIColor.clearColor()
            textView.delegate = self
            
            addSubview(textView)

            self.textView = textView
        }
        

        textView?.text = text
    }

    override func handlePanTranslation(translation: CGPoint) -> CGRect {
        let rect = super.handlePanTranslation(translation)
        updateTextView()
        return rect
    }

    func handleDoubleTap(tapGestureRecognizer: UITapGestureRecognizer) {
        textView?.becomeFirstResponder()
    }

    override func setUpSettingsViewController() {
        TextSettingsViewController.delegate = self
        SettingsViewController.sharedInstance?.currentSettingsType = .Text
    }

    override func setDeselected() {
        textView?.resignFirstResponder()
    }

    // MARK: - TextSettingsDelegate 

    func changeTextColor(color: UIColor) {
        textView?.textColor = color
    }

    func changeBackgroundColor(color: UIColor) {
        textView?.backgroundColor = color
    }

    func changeAlignment(textAlignment: NSTextAlignment) {
        textView?.textAlignment = textAlignment
    }

    func changeFont(font: UIFont) {
        textView?.font = font
    }

    func disableAutoCorrect(disable: Bool) {
        if disable {
            textView?.autocorrectionType = .No
        } else {
            textView?.autocorrectionType = .Yes
        }
    }

    func removeText() {
        textView?.text = ""
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
                DocumentSynchronizer.sharedInstance.registerUndoAction(textLayer.text, pageIndex: textLayer.docPage.index, layerIndex: textLayer.index)
            }
            textLayer.text = textView?.text ?? textLayer.text
            saveChanges()
        }

    }

    override func saveChanges() {
        super.saveChanges()
    }

    func updateTextView() {
        guard textView != nil else {
            return
        }
        let heightOffset = textView!.contentSize.height - textView!.bounds.size.height
        if heightOffset > 0 {
            let origin = frame.origin
            var size = bounds.size
            size.height += heightOffset
            frame = CGRect(origin: origin, size: size)
            layoutIfNeeded()
            setNeedsDisplay()
        }
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(textView: UITextView) {
        updateTextView()
    }

    func textViewDidEndEditing(textView: UITextView) {
        updateText(textView.text)
    }

}
