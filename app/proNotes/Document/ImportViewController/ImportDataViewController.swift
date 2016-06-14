//
//  ImportDataViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 17/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class ImportDataViewController: ImportExportBaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {

    final let pdfUTI = "com.adobe.pdf"
    final let imageUTI = "public.image"

    override func setUpDataSource() {
        dataSourceObjects.append(TableViewMainObject(title: NSLocalizedString("Image", comment: ""), collapsed: true, subObjects: [TableViewSubObject(title: NSLocalizedString("Photos", comment: ""), action: handleAddPictureCameraRoll), TableViewSubObject(title: NSLocalizedString("Camera", comment: ""), action: handleAddPictureCamera), TableViewSubObject(title: NSLocalizedString("iCloudDrive", comment: ""), action: handleAddImageiCloudDrive)], action: nil))
        dataSourceObjects.append(TableViewMainObject(title: NSLocalizedString("PDF", comment: ""), collapsed: true, subObjects: nil, action: handleAddPdf))
        dataSourceObjects.append(TableViewMainObject(title: NSLocalizedString("Textfield", comment: ""), collapsed: true, subObjects: nil, action: handleAddTextField))
        dataSourceObjects.append(TableViewMainObject(title: NSLocalizedString("SketchCanvas", comment: ""), collapsed: true, subObjects: nil, action: handleAddSketchLayer))
        dataSourceObjects.append(TableViewMainObject(title: NSLocalizedString("EmptyPage", comment: ""), collapsed: true, subObjects: nil, action: handleAddPage))
    }

    private func showDocumentPicker(_ documentTypes: [String]) {
        let documentPicker = CustomDocumentPickerViewController(documentTypes: documentTypes, in: .import)
        documentPicker.delegate = self;
        documentPicker.modalPresentationStyle = .pageSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    // MARK: - Actions 

    func handleAddPictureCameraRoll() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }

    func handleAddPictureCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }

    func handleAddImageiCloudDrive() {
        showDocumentPicker([imageUTI])
    }

    func handleAddPdf() {
        showDocumentPicker([pdfUTI])
    }

    func handleAddTextField() {
        delegate?.addTextField()
    }

    func handleAddPage() {
        delegate?.addEmptyPage()
    }
    
    func handleAddSketchLayer() {
        delegate?.addSketchLayer()
    }
    
    // MARK: - UIDocumentPickerDelegate

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {

        if let customDocumentPicker = controller as? CustomDocumentPickerViewController {
            if customDocumentPicker.documentTypes.contains(imageUTI) {
                if let imageData = try? Data(contentsOf: url) {
                    if let image = UIImage(data: imageData) {
                        delegate?.addImage(image.resetRoation())
                    }
                }
            } else {
                delegate?.addPDF(url)
            }
        }

        dismiss(animated: false, completion: nil)
    }

    // MARK: - UIImagePickerControllerDelegate
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismiss(animated: false, completion: nil)
//        delegate?.addImage(image.resetRoation())
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: false, completion: nil)
        delegate?.dismiss(true)
    }


}
