//
//  ExportViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 22/04/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class ExportViewController: ImportExportBaseViewController {
    
    @IBOutlet weak var progressBarHeight: NSLayoutConstraint!
    @IBOutlet weak var exportProgressView: UIProgressView!
    override func setUpDataSource() {
        dataSourceObjects.append(TableViewMainObject(title: NSLocalizedString("As Images", comment: ""), collapsed: true, subObjects: nil, action: handleExportImages))
        dataSourceObjects.append(TableViewMainObject(title: NSLocalizedString("As PDF", comment: ""), collapsed: true, subObjects: nil, action: handleExportPDF))
        dataSourceObjects.append(TableViewMainObject(title: NSLocalizedString("As ProNote", comment: ""), collapsed: true, subObjects: nil, action: handleExportProNote))
    }
    
    func handleExportImages() {
        animateProgressBarIn()
        
        let priority = DispatchQueue.GlobalAttributes.qosDefault
        DispatchQueue.global(attributes: priority).async {
            DispatchQueue.main.async {
                let images = DocumentExporter.exportAsImages { (progress) in
                    self.exportProgressView.progress = progress
                }
                self.delegate?.exportAsImages(images)
            }
        }

    }
    
    func handleExportPDF() {
        animateProgressBarIn()
        let priority = DispatchQueue.GlobalAttributes.qosDefault
        DispatchQueue.global(attributes: priority).async {
            DispatchQueue.main.async {
                guard let data = DocumentExporter.exportAsPDF ({ (progress) in
                    self.exportProgressView.progress = progress
                }) else {
                    self.delegate?.dismiss(true)
                    return
                }
                self.delegate?.exportAsPDF(data)
            }
        }
    }
    
    func handleExportProNote() {
        animateProgressBarIn()
        let priority = DispatchQueue.GlobalAttributes.qosDefault
        DispatchQueue.global(attributes: priority).async {
            DispatchQueue.main.async {
                DocumentExporter.exportAsProNote({ (progress) in
                    self.exportProgressView.progress = progress
                }) { (url) in
                    if url != nil {
                        self.delegate?.exportAsProNote(url!)
                    }
                }
            }
        }

    }
    
    func animateProgressBarIn() {
        DispatchQueue.main.async(execute: {
            self.view.layoutIfNeeded()
            self.progressBarHeight.constant = 44
            UIView.animate(withDuration: standardAnimationDuration, delay: 0, options: UIViewAnimationOptions(), animations: { 
                self.view.layoutIfNeeded()
                }, completion: nil)
        })

    }

}
