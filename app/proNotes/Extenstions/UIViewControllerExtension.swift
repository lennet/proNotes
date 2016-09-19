//
//  UIViewControllerExtension.swift
//  proNotes
//
//  Created by Leo Thomas on 07/07/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

extension UIViewController {

    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment:""), style: .default, handler: nil))
        navigationController?.present(alertController, animated: true, completion: nil)
    }
    
}
