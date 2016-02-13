//
//  PageTableViewCell.swift
//  Student
//
//  Created by Leo Thomas on 26/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PageTableViewCell: UITableViewCell, PDFViewDelegate {

    static let identifier = "PageTableViewCellIdentifier"
    
    @IBOutlet weak var pageView: PageView!
    weak var tableView: UITableView?

    var heightConstraint: NSLayoutConstraint?
    var widthConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()

        heightConstraint = pageView.getConstraint(.Height)
        widthConstraint = pageView.getConstraint(.Width)
        updateHeight(UIScreen.mainScreen().bounds.height)
        
        for case let scrollView as UIScrollView in self.subviews {
            scrollView.delaysContentTouches = false
        }
    }

    func updateHeight(height: CGFloat) {
        if height != heightConstraint?.constant {
            heightConstraint?.constant = height
            setNeedsLayout()
            layoutIfNeeded()
            pageView.setNeedsDisplay()
        }
    }

}
