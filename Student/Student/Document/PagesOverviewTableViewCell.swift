//
//  PagesOverviewTableViewCell.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

protocol PagesOverviewTableViewCellDelegate {
    func showPage(index: Int)
}

class PagesOverviewTableViewCell: UITableViewCell {
    
    static let identifier = "PagesOverViewTableViewCellIdentifier"

    @IBOutlet weak var pageThumbView: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    var index = 0
    var delegate: PagesOverviewTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pageThumbView.layer.setUpDefaultShaddow()
        backgroundColor = UIColor.clearColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func handlePageButtonPressed(sender: AnyObject) {
        delegate?.showPage(index)
    }

}
