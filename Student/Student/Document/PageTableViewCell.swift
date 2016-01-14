//
//  PageTableViewCell.swift
//  Student
//
//  Created by Leo Thomas on 26/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PageTableViewCell: UITableViewCell, PDFViewDelegate {

    @IBOutlet weak var pageView: PageView!
    
    static let identifier = "PageTableViewCellIdentifier"

    var heightConstraint: NSLayoutConstraint?
    var widthConstraint: NSLayoutConstraint?
    var tableView: UITableView?

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        
        heightConstraint = pageView.getConstraint(.Height)
        widthConstraint = pageView.getConstraint(.Width)
        updateHeight(UIScreen.mainScreen().bounds.height)

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

}
