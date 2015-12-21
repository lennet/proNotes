//
//  MovableTextView.swift
//  Student
//
//  Created by Leo Thomas on 09/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class MovableTextView: MovableView, TextSettingsDelegate {

    var text = ""
    var textView = UITextView()
    
    init(text: String, frame: CGRect, movableLayer: MovableLayer) {
        self.text = text
        super.init(frame: frame, movableLayer: movableLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUpTextView() {
        clipsToBounds = true

        textView.text = text
        textView.userInteractionEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor.clearColor()
        
        addSubview(textView)
        addAutoLayoutConstraints(textView)
    }
    
    override func handleDoubleTap(tapGestureRecognizer: UITapGestureRecognizer) {
        textView.becomeFirstResponder()
    }
    
    override func setUpSettingsViewController() {
        DocumentSynchronizer.sharedInstance.settingsViewController?.currentSettingsType = .Text
        TextSettingsViewController.delegate = self
    }
    
    override func setDeselected() {
        textView.resignFirstResponder()
    }
    
    // MARK: - TextSettingsDelegate 
    
    func changeTextColor(color: UIColor) {
        textView.textColor = color
    }
    
    func changeBackgroundColor(color: UIColor) {
        textView.backgroundColor = color
    }
    
    func changeAlignment(textAlignment: NSTextAlignment) {
        textView.textAlignment = textAlignment
    }
    
    func removeText() {
        // TODO
    }
    

    
}
