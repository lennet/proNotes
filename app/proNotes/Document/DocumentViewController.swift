//
//  DocumentViewController.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController {

    @IBOutlet weak var settingsContainerRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pagesOverViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var pageInfoButton: UIBarButtonItem!
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var sketchButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIBarButtonItem!
    @IBOutlet weak var actionBarButtonItem: UIBarButtonItem!
    
    @IBOutlet var bottomConstraints: [NSLayoutConstraint]!

    weak var pagesOverviewController: PagesOverviewTableViewController?
    weak var importDataNavigationController: UINavigationController?
    
    var isFullScreen = false
    var isSketchMode = false {
        didSet {
            if isSketchMode {
                sketchButton.image = UIImage(named: "sketchIconActive")
            } else {
                sketchButton.image = UIImage(named: "sketchIcon")
            }
        }
    }
    var isLoadingData = false

    var document: Document? {
        get {
            return DocumentInstance.sharedInstance.document
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTitle()
        pageInfoButton.setHidden(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotifications()
        updateUndoButton()
        if UIDevice.current.userInterfaceIdiom == .phone {
            setUpForIphone()
        }
        isLoadingData = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleTextField.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !isLoadingData {
            titleTextField.delegate = nil
            DocumentInstance.sharedInstance.removeAllDelegates()
            DocumentInstance.sharedInstance.save({ (_) in
                self.document?.close(completionHandler: nil)
            })
            removeNotifications()
            undoManager?.removeAllActions()
        }
    }
    
    func setUpForIphone() {
        titleTextField.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        DocumentInstance.sharedInstance.flushUndoManager()
        ImageCache.sharedInstance.clearCache()
    }

    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }

    func setUpTitle() {
        titleTextField.text = document?.name
        titleTextField.sizeToFit()
    }

    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(DocumentViewController.updateUndoButton), name: NSNotification.Name.NSUndoManagerWillUndoChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DocumentViewController.updateUndoButton), name: NSNotification.Name.NSUndoManagerCheckpoint, object: nil)
    }

    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func toggleFullScreen(_ animated: Bool = true) {
        if isFullScreen {
            settingsContainerRightConstraint.constant = 0
            pagesOverViewLeftConstraint.constant = 0
            isFullScreen = false
            SettingsViewController.sharedInstance?.view.alpha = 1
            pagesOverviewController?.view.alpha = 1
            fullScreenButton.image = UIImage(named: "fullscreenOn")
        } else {
            settingsContainerRightConstraint.constant = -SettingsViewController.sharedInstance!.view.bounds.width
            pagesOverViewLeftConstraint.constant = -pagesOverviewController!.view.bounds.width
            isFullScreen = true
            fullScreenButton.image = UIImage(named: "fullscreenOff")
        }
        UIView.animate(withDuration: animated ? standardAnimationDuration : 0, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.view.layoutIfNeeded()
            PagesTableViewController.sharedInstance?.setUpScrollView()
            PagesTableViewController.sharedInstance?.layoutDidChange()
            }, completion: { (_) in
                if self.isFullScreen {
                    SettingsViewController.sharedInstance?.view.alpha = 0
                    self.pagesOverviewController?.view.alpha = 0
                }
        })
    }

    // MARK: - Actions

    @IBAction func handleSketchButtonPressed(_ sender: UIBarButtonItem) {
        isSketchMode = !isSketchMode
        if isSketchMode {
            PagesTableViewController.sharedInstance?.currentPageView?.handleSketchButtonPressed()
        } else {
            PagesTableViewController.sharedInstance?.currentPageView?.deselectSelectedSubview()
        }
    }

    @IBAction func handlePageInfoButtonPressed(_ sender: AnyObject) {
        PagesTableViewController.sharedInstance?.currentPageView?.deselectSelectedSubview()
        SettingsViewController.sharedInstance?.currentType = .pageInfo
        if isFullScreen {
            toggleFullScreen()
        }
    }

    @IBAction func handleFullscreenToggleButtonPressed(_ sender: UIBarButtonItem) {
        toggleFullScreen()
    }

    @IBAction func handleUndoButtonPressed(_ sender: AnyObject) {
        undoManager?.undo()
    }

    func updateUndoButton() {
        undoButton.isEnabled = undoManager?.canUndo ?? false
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? PagesOverviewTableViewController {
            viewController.pagesOverViewDelegate = self
            pagesOverviewController = viewController
        } else if let viewController = segue.destination as? PagesTableViewController {
            PagesTableViewController.sharedInstance = viewController
        } else if let viewController = segue.destination as? SettingsViewController {
            viewController.delegate = self
        } else if let navigationController = segue.destination as? UINavigationController {
            if UIDevice.current.userInterfaceIdiom == .phone {
                isLoadingData = true
            }
            if let viewController = navigationController.visibleViewController as? ImportExportBaseViewController {
                viewController.delegate = self
            }
            if importDataNavigationController != nil {
                dismiss()
            }
            importDataNavigationController = navigationController
        }
    }
    
    @IBAction func unwind(_ sender: AnyObject) {
       _ = navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextfieldDelegate

extension DocumentViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.borderStyle = .roundedRect
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let newName = textField.text else { return }
        guard let fileUrl = document?.fileURL else { return }
        
        document?.close(completionHandler: { [weak self](_) in
            DocumentManager.sharedInstance.renameDocument(withurl: fileUrl, newName: newName, forceOverWrite: false, viewController: self) { (success, url) in
                if !success {
                    DispatchQueue.main.async(execute: {
                        // reset title to old name
                        self?.setUpTitle()
                        self?.alert(message: "Error Ocurred. Please Try again")
                    })
                } else if let url = url {
                    let document = Document(fileURL: url)
                    document.open(completionHandler: { (_) in
                        DocumentInstance.sharedInstance.document = document
                    })
                }
            }
        })

        textField.borderStyle = .none
    }
    
}

// MARK: - SettingsViewControllerDelegate

extension DocumentViewController: SettingsViewControllerDelegate {
    
    func didChangeSettingsType(to newType: SettingsType) {
        pageInfoButton.setHidden(newType == .pageInfo)
        isSketchMode = newType == .sketch
    }
    
}

// MARK: - ImportDataViewControllerDelegate

extension DocumentViewController: ImportExportDataViewControllerDelgate {
    
    func addEmptyPage() {
        document?.addEmptyPage()
        dismiss()
    }
    
    func addTextField() {
        dismiss()
        if let textLayer = DocumentInstance.sharedInstance.currentPage?.addTextLayer("") {
            if let currentPageView = PagesTableViewController.sharedInstance?.currentPageView {
                currentPageView.addTextView(textLayer)
                currentPageView.page = DocumentInstance.sharedInstance.currentPage
                currentPageView.setLayerSelected(currentPageView.subviews.count - 1)
                if let pageIndex = currentPageView.page?.index {
                    DocumentInstance.sharedInstance.didUpdatePage(pageIndex)
                    showPage(pageIndex)
                }
            }
        }
    }
    
    func addPDF(_ url: URL) {
        document?.addPDF(url)
        dismiss()
    }
    
    func addImage(_ image: UIImage) {
        if let imageLayer = DocumentInstance.sharedInstance.currentPage?.addImageLayer(image) {
            if let currentPageView = PagesTableViewController.sharedInstance?.currentPageView {
                currentPageView.addImageView(imageLayer)
                currentPageView.page = DocumentInstance.sharedInstance.currentPage
                currentPageView.setLayerSelected(currentPageView.subviews.count - 1)
                if let pageIndex = currentPageView.page?.index {
                    DocumentInstance.sharedInstance.didUpdatePage(pageIndex)
                    showPage(pageIndex)
                }
            }
        }
        dismiss()
    }
    
    func addSketchLayer() {
        PagesTableViewController.sharedInstance?.currentPageView?.addSketchLayer()
        dismiss()
    }
    
    func exportAsPDF(_ data: Data) {
        dismiss()
        DocumentExporter.presentActivityViewController(self, barbuttonItem: actionBarButtonItem, items: [data])
    }
    
    func exportAsImages(_ images: [UIImage]) {
        dismiss(false)
        DocumentExporter.presentActivityViewController(self, barbuttonItem: actionBarButtonItem, items: images)
    }
    
    func exportAsProNote(_ url: URL) {
        dismiss()
        DocumentExporter.presentActivityViewController(self, barbuttonItem: actionBarButtonItem, items: [url])
    }
    
    func dismiss(_ animated: Bool = true) {
        importDataNavigationController?.dismiss(animated: animated, completion: nil)
        importDataNavigationController?.delegate = nil
        importDataNavigationController = nil
    }
    
}

// MARK: - PagesOverViewDelegate

extension DocumentViewController: PagesOverviewTableViewCellDelegate {

    func showPage(_ index: Int) {
        PagesTableViewController.sharedInstance?.showPage(index)
    }

}

// MARK: - UIKeyCommands

extension DocumentViewController {
    
    override var keyCommands: [UIKeyCommand]? {
        var commands = [UIKeyCommand]()
        
        if let settingsViewController = SettingsViewController.sharedInstance,
            settingsViewController.currentType == .image{
            commands.append(UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: .control, action: #selector(DocumentViewController.handleRotateImageKeyPressed(_:)), discoverabilityTitle: "Rotate Image Right"))
            commands.append(UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags: .control, action: #selector(DocumentViewController.handleRotateImageKeyPressed(_:)), discoverabilityTitle: "Rotate Image Left"))
        }
        
        if PagesTableViewController.sharedInstance?.currentPageView?.selectedSubView is MovableView {
            commands.append(UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: .command, action: #selector(DocumentViewController.handleMoveMovableViewKeyPressed(_:)), discoverabilityTitle: "Move Right"))
            commands.append(UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags: .command, action: #selector(DocumentViewController.handleMoveMovableViewKeyPressed(_:)), discoverabilityTitle: "Move Left"))
            commands.append(UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: .command, action: #selector(DocumentViewController.handleMoveMovableViewKeyPressed(_:)), discoverabilityTitle: "Move Up"))
            commands.append(UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: .command, action: #selector(DocumentViewController.handleMoveMovableViewKeyPressed(_:)), discoverabilityTitle: "Move Down"))
        } else {
            commands.append(UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: [], action: #selector(DocumentViewController.handleDownKeyPressed(_:)), discoverabilityTitle: "Scroll Down"))
            commands.append(UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: [], action: #selector(DocumentViewController.handleUpKeyPressed(_:)), discoverabilityTitle: "Scroll Up"))
        }
        
        return commands
    }
    
    func handleRotateImageKeyPressed(_ sender: UIKeyCommand) {
        if let imageSettingsViewController = SettingsViewController.sharedInstance?.currentChildViewController as? ImageSettingsViewController {
            imageSettingsViewController.rotateImage(sender.input == UIKeyInputRightArrow ? .right : .left)
        }
    }
    
    func handleDownKeyPressed(_ sender: UIKeyCommand) {
        PagesTableViewController.sharedInstance?.scroll(true)
    }
    
    func handleUpKeyPressed(_ sender: UIKeyCommand) {
        PagesTableViewController.sharedInstance?.scroll(false)
    }
    
    func handleMoveMovableViewKeyPressed(_ sender: UIKeyCommand) {
        guard let movableView = PagesTableViewController.sharedInstance?.currentPageView?.selectedSubView as? MovableView else {
            return
        }
        let offSet = 10
        var translation: CGPoint = .zero
        switch sender.input {
        case UIKeyInputRightArrow:
            translation = CGPoint(x: offSet, y: 0)
            break
        case UIKeyInputLeftArrow:
            translation = CGPoint(x: -offSet, y: 0)
            break
        case UIKeyInputDownArrow:
            translation = CGPoint(x: 0, y: offSet)
            break
        case UIKeyInputUpArrow:
            translation = CGPoint(x: 0, y: -offSet)
            break
        default:
            break
        }
        movableView.selectedTouchControl = .center
        movableView.handlePanTranslation(translation)
        movableView.handlePanEnded()
    }
}
