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
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            dispatch_async(dispatch_get_main_queue()) {
                let images = DocumentExporter.exportAsImages { (progress) in
                    self.exportProgressView.progress = progress
                }
                self.delegate?.exportAsImages(images)
            }
        }

    }
    
    func handleExportPDF() {
        animateProgressBarIn()
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            dispatch_async(dispatch_get_main_queue()) {
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
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            dispatch_async(dispatch_get_main_queue()) {
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
        dispatch_async(dispatch_get_main_queue(),{
            self.view.layoutIfNeeded()
            self.progressBarHeight.constant = 44
            UIView.animateWithDuration(standardAnimationDuration, delay: 0, options: .CurveEaseInOut, animations: { 
                self.view.layoutIfNeeded()
                }, completion: nil)
        })

    }

}
