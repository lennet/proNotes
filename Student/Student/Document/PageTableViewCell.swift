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
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    static let identifier = "PageTableViewCellIdentifier"

    override func awakeFromNib() {
        super.awakeFromNib()
        updateHeight(UIScreen.mainScreen().bounds.height)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateHeight(height: CGFloat) {
        if height != heightConstraint.constant {
            heightConstraint.constant = height
            setNeedsLayout()
            layoutIfNeeded()
            pageView.setNeedsDisplay()
        }
    }

}
