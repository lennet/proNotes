//
//  MovableImageView.swift
//  Student
//
//  Created by Leo Thomas on 06/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class MovableImageView: MovableView {

    var image: UIImage
    
    init(image: UIImage, frame: CGRect, movableLayer: MovableLayer) {
        self.image = image
        super.init(frame: frame, movableLayer: movableLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.image = UIImage()
        super.init(coder: aDecoder)
    }
    
    func setUpImageView() {
        clipsToBounds = true
        let imageView = UIImageView()

        imageView.image = image
//        imageView.contentMode = .ScaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        addAutoLayoutConstraints(imageView)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
