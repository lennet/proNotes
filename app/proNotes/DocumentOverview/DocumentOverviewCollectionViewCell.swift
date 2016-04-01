//
//  DocumentOverviewCollectionViewCell.swift
//  proNotes
//
//  Created by Leo Thomas on 16/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class DocumentOverviewCollectionViewCell: UICollectionViewCell {

    static let reusableIdentifier = "DocumentOverviewCollectionViewCellIdentifier"

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var downloadIndicator: CloudDownloadingIndicator!

    @IBOutlet weak var thumbImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbImageViewHeightConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        thumbImageView.layer.setUpDefaultShaddow()
    }
    
    override func prepareForReuse() {
        thumbImageViewWidthConstraint.constant = 65
        thumbImageViewHeightConstraint.constant = 100
        thumbImageView.image = nil
    }
}
