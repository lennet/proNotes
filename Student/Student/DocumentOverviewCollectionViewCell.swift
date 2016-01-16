//
//  DocumentOverviewCollectionViewCell.swift
//  Student
//
//  Created by Leo Thomas on 16/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class DocumentOverviewCollectionViewCell: UICollectionViewCell {
    static let reusableIdentifier = "DocumentOverviewCollectionViewCellIdentifier"
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
}
