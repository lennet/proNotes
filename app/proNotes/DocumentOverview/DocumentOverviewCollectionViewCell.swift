//
//  DocumentOverviewCollectionViewCell.swift
//  proNotes
//
//  Created by Leo Thomas on 16/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

protocol DocumentOverviewCollectionViewCellDelegate: class {
    
    func didPressedDeleteButton(forCell cell: DocumentOverviewCollectionViewCell)
    
    func didRenamedDocument(forCell cell: DocumentOverviewCollectionViewCell, newName: String)
    
}

class DocumentOverviewCollectionViewCell: UICollectionViewCell {

    static let reusableIdentifier = "DocumentOverviewCollectionViewCellIdentifier"

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var thumbImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbImageViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: DocumentOverviewCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        thumbImageView.layer.setUpDefaultShaddow()
        
        let renameMenutItem = UIMenuItem(title: "Rename", action: #selector(rename))
        UIMenuController.shared().menuItems = [renameMenutItem]
        
    }
    
    override func prepareForReuse() {
        thumbImageViewWidthConstraint.constant = 65
        thumbImageViewHeightConstraint.constant = 100
        thumbImageView.image = nil
        thumbImageView.contentMode = .scaleToFill
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: AnyObject?) -> Bool {
        let actionString = NSStringFromSelector(action)
        return  actionString == "delete:" || actionString == "rename:"
    }
    
    override func delete(_ sender: AnyObject?) {
        delegate?.didPressedDeleteButton(forCell: self)
    }
    
    func rename(_ sender: AnyObject?) {
        nameTextField.isUserInteractionEnabled = true
        nameTextField.becomeFirstResponder()
        nameTextField.borderStyle = .roundedRect
    }
    
}

extension DocumentOverviewCollectionViewCell: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let text = textField.text else { return false }
        
        nameTextField.isUserInteractionEnabled = false
        nameTextField.borderStyle = .none

        delegate?.didRenamedDocument(forCell: self, newName: text)
        textField.resignFirstResponder()
        
        return true
    }
    

}
