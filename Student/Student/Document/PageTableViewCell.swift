//
//  PageTableViewCell.swift
//  Student
//
//  Created by Leo Thomas on 26/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PageTableViewCell: UITableViewCell, PDFViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var pageView: PageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    static let identifier = "PageTableViewCellIdentifier"

    var heightConstraint: NSLayoutConstraint?
    var widthConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        heightConstraint = pageView.getConstraint(.Height)
        widthConstraint = pageView.getConstraint(.Width)
        updateHeight(UIScreen.mainScreen().bounds.height)
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateHeight(height: CGFloat) {
        if height != heightConstraint?.constant {
            heightConstraint?.constant = height
            setNeedsLayout()
            layoutIfNeeded()
            pageView.setNeedsDisplay()
        }
    }

    
    // MARK: - UIScrollView 
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return pageView
    }
}
