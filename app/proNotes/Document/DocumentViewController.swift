//
//  DocumentViewController.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController, PagesOverviewTableViewCellDelegate, UITextFieldDelegate, ImportExportDataViewControllerDelgate, SettingsViewControllerDelegate {

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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotifications()
        updateUndoButton()
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            setUpForIphone()
        }
        isLoadingData = false
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        titleTextField.delegate = self
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if !isLoadingData {
            titleTextField.delegate = nil
            
            document?.closeWithCompletionHandler({
                (Bool) -> Void in
            })
            removeNotifications()
            undoManager?.removeAllActions()
        }
    }
    
    func setUpForIphone() {
        titleTextField.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        DocumentInstance.sharedInstance.flushUndoManager()
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    private func setUpTitle() {
        titleTextField.text = document?.name
        titleTextField.sizeToFit()
    }

    private func registerNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DocumentViewController.updateUndoButton), name: NSUndoManagerWillUndoChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DocumentViewController.updateUndoButton), name: NSUndoManagerCheckpointNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DocumentViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DocumentViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    private func removeNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func toggleFullScreen(animated: Bool = true) {
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
        UIView.animateWithDuration(animated ? standardAnimationDuration : 0, delay: 0, options: .CurveEaseInOut, animations: {
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

    func keyboardWillShow(notification: NSNotification){
        return
        let info = notification.userInfo
        guard let duration = info![UIKeyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        guard let keyboardSize = (info?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue().size else {
            return
        }
        
        for constraint in bottomConstraints {
            constraint.constant = keyboardSize.height
        }
        
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseInOut, animations: { 
            self.view.layoutIfNeeded()
            PagesTableViewController.sharedInstance?.layoutDidChange()
            }, completion: nil)
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        return
        
        let info = notification.userInfo
        let duration = info![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        for constraint in bottomConstraints {
            constraint.constant = 0
        }
        
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            PagesTableViewController.sharedInstance?.layoutDidChange()
            }, completion: nil)
    }
    
    // MARK: - Actions

    @IBAction func handleSketchButtonPressed(sender: UIBarButtonItem) {
        isSketchMode = !isSketchMode
        if isSketchMode {
            PagesTableViewController.sharedInstance?.currentPageView?.handleSketchButtonPressed()
        } else {
            PagesTableViewController.sharedInstance?.currentPageView?.deselectSelectedSubview()
        }
    }

    @IBAction func handlePageInfoButtonPressed(sender: AnyObject) {
        PagesTableViewController.sharedInstance?.currentPageView?.deselectSelectedSubview()
        SettingsViewController.sharedInstance?.currentSettingsType = .PageInfo
        if isFullScreen {
            toggleFullScreen()
        }
    }

    @IBAction func handleFullscreenToggleButtonPressed(sender: UIBarButtonItem) {
        toggleFullScreen()
    }

    @IBAction func handleUndoButtonPressed(sender: AnyObject) {
        undoManager?.undo()
    }

    func updateUndoButton() {
        undoButton.enabled = undoManager?.canUndo ?? false
    }

    // MARK: - PagesOverViewDelegate

    func showPage(index: Int) {
        PagesTableViewController.sharedInstance?.showPage(index)
    }

    // MARK: - UIKeyCommands

    override var keyCommands: [UIKeyCommand]? {
        var commands = [UIKeyCommand]()

        if let settingsViewController = SettingsViewController.sharedInstance {
            switch settingsViewController.currentSettingsType {
            case .Image:
                commands.append(UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: .Control, action: #selector(DocumentViewController.handleRotateImageKeyPressed(_:)), discoverabilityTitle: "Rotate Image Right"))
                commands.append(UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags: .Control, action: #selector(DocumentViewController.handleRotateImageKeyPressed(_:)), discoverabilityTitle: "Rotate Image Left"))
                break
            default:
                break
            }
        }

        if let _ = PagesTableViewController.sharedInstance?.currentPageView?.selectedSubView as? MovableView {
            commands.append(UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: .Command, action: #selector(DocumentViewController.handleMoveMovableViewKeyPressed(_:)), discoverabilityTitle: "Move Right"))
            commands.append(UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags: .Command, action: #selector(DocumentViewController.handleMoveMovableViewKeyPressed(_:)), discoverabilityTitle: "Move Left"))
            commands.append(UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: .Command, action: #selector(DocumentViewController.handleMoveMovableViewKeyPressed(_:)), discoverabilityTitle: "Move Up"))
            commands.append(UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: .Command, action: #selector(DocumentViewController.handleMoveMovableViewKeyPressed(_:)), discoverabilityTitle: "Move Down"))
        } else {
            commands.append(UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: [], action: #selector(DocumentViewController.handleDownKeyPressed(_:)), discoverabilityTitle: "Scroll Down"))
            commands.append(UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: [], action: #selector(DocumentViewController.handleUpKeyPressed(_:)), discoverabilityTitle: "Scroll Up"))
        }

        return commands
    }

    func handleRotateImageKeyPressed(sender: UIKeyCommand) {
        if let imageSettingsViewController = SettingsViewController.sharedInstance?.currentChildViewController as? ImageSettingsViewController {
            imageSettingsViewController.rotateImage(sender.input == UIKeyInputRightArrow ? .Right : .Left)
        }
    }

    func handleDownKeyPressed(sender: UIKeyCommand) {
        PagesTableViewController.sharedInstance?.scroll(true)
    }

    func handleUpKeyPressed(sender: UIKeyCommand) {
        PagesTableViewController.sharedInstance?.scroll(false)
    }

    func handleMoveMovableViewKeyPressed(sender: UIKeyCommand) {
        guard let movableView = PagesTableViewController.sharedInstance?.currentPageView?.selectedSubView as? MovableView else {
            return
        }
        let offSet = 10
        var translation = CGPointZero
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
        movableView.selectedTouchControl = .Center
        movableView.handlePanTranslation(translation)
        movableView.handlePanEnded()
    }

    // MARK: - UITextfieldDelegate

    func textFieldDidBeginEditing(textField: UITextField) {
        textField.borderStyle = .RoundedRect
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(textField: UITextField) {
        if let newName = textField.text {
            DocumentInstance.sharedInstance.renameDocument(newName, forceOverWrite: false, viewController: self, completion: {
                (success) -> Void in
                if !success {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.setUpTitle()
                    })
                }
            })
            textField.borderStyle = .None
        }
    }

    // MARK: - ImportDataViewControllerDelegate
    
    weak var importDataNavigationController: UINavigationController?

    func addEmptyPage() {
        document?.addEmptyPage()
        dismiss()
    }

    func addTextField() {
        if let textLayer = DocumentInstance.sharedInstance.currentPage?.addTextLayer("") {
            if let currentPageView = PagesTableViewController.sharedInstance?.currentPageView {
                currentPageView.addTextLayer(textLayer)
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

    func addPDF(url: NSURL) {
        document?.addPDF(url)
        dismiss()
    }

    func addImage(image: UIImage) {
        if let imageLayer = DocumentInstance.sharedInstance.currentPage?.addImageLayer(image) {
            if let currentPageView = PagesTableViewController.sharedInstance?.currentPageView {
                currentPageView.addImageLayer(imageLayer)
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
    
    func exportAsPDF(data: NSData) {
        dismiss()
        DocumentExporter.presentActivityViewController(self, sourceView: nil, barbuttonItem: actionBarButtonItem, items: [data])
    }
    
    func exportAsImages(images: [UIImage]) {
        dismiss(false)
        DocumentExporter.presentActivityViewController(self, sourceView: nil, barbuttonItem: actionBarButtonItem, items: images)
    }
    
    func exportAsProNote(url: NSURL) {
        dismiss()
                DocumentExporter.presentActivityViewController(self, sourceView: nil, barbuttonItem: actionBarButtonItem, items: [url])
        
    }

    func dismiss(animated: Bool = true) {
        importDataNavigationController?.dismissViewControllerAnimated(animated, completion: nil)
        importDataNavigationController = nil
    }
    
    // MARK: - SettingsViewControllerDelegate
    
    func didChangeSettingsType(newType: SettingsViewControllerType) {
        pageInfoButton.setHidden(newType == .PageInfo)
        isSketchMode = newType == .Sketch
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let viewController = segue.destinationViewController as? PagesOverviewTableViewController {
            viewController.pagesOverViewDelegate = self
            pagesOverviewController = viewController
        } else if let viewController = segue.destinationViewController as? PagesTableViewController {
            PagesTableViewController.sharedInstance = viewController
        } else if let viewController = segue.destinationViewController as? SettingsViewController {
            viewController.delegate = self
        } else if let navigationController = segue.destinationViewController as? UINavigationController {
            if let viewController = navigationController.visibleViewController as? ImportExportBaseViewController {
                isLoadingData = true
                viewController.delegate = self
            }
            if importDataNavigationController != nil {
                dismiss()
            }
            importDataNavigationController = navigationController
        }
    }
    
    @IBAction func unwind(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}
