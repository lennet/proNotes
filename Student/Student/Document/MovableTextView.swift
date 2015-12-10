//
//  MovableTextView.swift
//  Student
//
//  Created by Leo Thomas on 09/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class MovableTextView: MovableView {

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
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleDoubleTap"))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        addGestureRecognizer(doubleTapGestureRecognizer)
        
        addSubview(textView)
        addAutoLayoutConstraints(textView)
    }
    
    func handleDoubleTap() {
        textView.becomeFirstResponder()
    }
    
    override func setUpSettingsViewController() {
        DocumentSynchronizer.sharedInstance.settingsViewController?.currentSettingsType = .Text
    }

}
