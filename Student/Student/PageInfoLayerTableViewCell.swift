//
//  PageInfoLayerTableViewCell.swift
//  Student
//
//  Created by Leo Thomas on 11/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PageInfoLayerTableViewCell: UITableViewCell {

    static let identifier = "PageInfoLayerTableViewCellIdentifier"

    @IBOutlet weak var visibilityButton: UIButton!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    var documentLayer: DocumentLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCellWithLayer(documentLayer: DocumentLayer){
        self.documentLayer = documentLayer
        indexLabel.text = String(documentLayer.index+1)
        typeLabel.text = String(documentLayer.type)
        if documentLayer.hidden {
            visibilityButton.setTitle("visible", forState: .Normal)
        } else {
            visibilityButton.setTitle("hidden", forState: .Normal)
        }
    }
    
    @IBAction func handleVisibilityButtonPressed(sender: AnyObject) {
        documentLayer?.docPage.changeLayerVisibility(!documentLayer!.hidden, layer: documentLayer!)
    }
    
}
