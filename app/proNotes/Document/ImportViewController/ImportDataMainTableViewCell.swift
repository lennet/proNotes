//
//  ImportDataMainTableViewCell.swift
//  proNotes
//
//  Created by Leo Thomas on 17/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class ImportDataMainTableViewCell: UITableViewCell {

    static let cellIdentifier = "ImportDataMainCellIdentifier"

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var accessoryImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
