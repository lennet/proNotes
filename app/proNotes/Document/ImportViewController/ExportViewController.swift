//
//  ExportViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 22/04/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class ExportViewController: ImportExportBaseViewController {
    
    override func setUpDataSource() {
        dataSourceObjects.append(TableViewMainObject(title: NSLocalizedString("As Images", comment: ""), collapsed: true, subObjects: nil, action: handleExportImages))
        dataSourceObjects.append(TableViewMainObject(title: NSLocalizedString("As PDF", comment: ""), collapsed: true, subObjects: nil, action: handleExportPDF))
        dataSourceObjects.append(TableViewMainObject(title: NSLocalizedString("As ProNote", comment: ""), collapsed: true, subObjects: nil, action: handleExportProNote))
    }
    
    func handleExportImages() {
        delegate?.exportAsImages()
    }
    
    func handleExportPDF() {
        delegate?.exportAsPDF()
    }
    
    func handleExportProNote() {
        delegate?.exportAsProNote()
    }

}
