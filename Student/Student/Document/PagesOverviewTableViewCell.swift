//
//  PagesOverviewTableViewCell.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PagesOverviewTableViewCell: UITableViewCell {
    
    static let identifier = "PagesOverViewTableViewCellIdentifier"
    @IBOutlet weak var pageThumbView: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    
    override func awakeFromNib() {

        super.awakeFromNib()
        let shadowLayer = pageThumbView.layer
        shadowLayer.masksToBounds = false;
        shadowLayer.shadowOffset = CGSize(width: 0, height: 2)
        shadowLayer.shadowRadius = 1.5
        shadowLayer.shadowOpacity = 0.6
        backgroundColor = UIColor.clearColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
