//
//  TextSettingsViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 10/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

protocol TextSettingsDelegate: class {
    func removeText()

    func removeLayer()
    
    func changeTextColor(_ color: UIColor)

    func changeBackgroundColor(_ color: UIColor)

    func changeAlignment(_ textAlignment: NSTextAlignment)

    func changeFont(_ font: UIFont)
    
    func getTextLayer() -> TextLayer?
}

class TextSettingsViewController: SettingsBaseViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    private enum ColorPickerIdentifier: String {
        case BackgroundColor = "BackgroundColorIdentifier"
        case TextColor = "TextColorIdentifier"
    }
    
    private enum FontPickerComponent: Int {
        case families
        case names
        case sizes

        static let allValues = [families, names, sizes]
    }

    @IBOutlet weak var justifiedAlignmentButton: UIButton!
    @IBOutlet weak var rightAlignmentButton: UIButton!
    @IBOutlet weak var centerAlignmentButton: UIButton!
    @IBOutlet weak var leftAlignmentButton: UIButton!
    
    var alignmentButtons: [UIButton] {
        get {
            return [leftAlignmentButton, centerAlignmentButton, rightAlignmentButton, justifiedAlignmentButton]
        }
    }
    
    @IBOutlet weak var fontPicker: UIPickerView!
    static weak var delegate: TextSettingsDelegate?

    var fontFamilies = [String]()
    var fontNames = [String]()
    var delegateEnabled = true
    
    let fontSizes = [10, 12, 14, 18, 24, 36, 48, 72]
    var selectedRow = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        fontFamilies = UIFont.familyNames
        updateFontNames()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let textLayer = TextSettingsViewController.delegate?.getTextLayer() else {
            return
        }
        for button in alignmentButtons where button.tag == textLayer.alignment.rawValue {
            button.isSelected = true
        }
        scrollToRowForFont(textLayer.font)
    }
    
    func updateFontNames() {
        fontNames = UIFont.fontNames(forFamilyName: fontFamilies[selectedRow])
    }

    // MARK: - UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return FontPickerComponent.allValues.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard  let fontPickerComponent = FontPickerComponent(rawValue: component) else {
            print("Not supported compontentnumber for Fontpicker: \(component)")
            return 0
        }
        switch fontPickerComponent {
        case .families:
            return fontFamilies.count
        case .names:
            return fontNames.count
        case .sizes:
            return fontSizes.count
        }
    }

    func getTitle(_ row: Int, forComponent component: Int) -> String {
        guard let fontPickerComponent = FontPickerComponent(rawValue: component) else {
            print("Not supported compontentnumber for Fontpicker: \(component)")
            return ""
        }
    
        switch fontPickerComponent {
        case .families:
            return fontFamilies[row]
        case .names:
            // parse userfriendly family name
            let fontFamilyName = fontFamilies[selectedRow]
            var fontNameTitle = fontNames[row].replacingOccurrences(of: fontFamilyName, with: "")
            guard !fontNameTitle.isEmpty else {
                return fontFamilyName
            }
            
            let fontFamilyNameWithoutSpaces = fontFamilyName.replacingOccurrences(of: " ", with: "")
            fontNameTitle = fontNameTitle.replacingOccurrences(of: fontFamilyNameWithoutSpaces, with: "")
            guard !fontNameTitle.isEmpty else {
                return fontNameTitle
            }
            
            guard let fistLetter = fontNameTitle.unicodeScalars.first else {
                return fontNameTitle
            }
            
            if CharacterSet.letters.inverted.contains(UnicodeScalar(fistLetter.value)) {
                fontNameTitle = String(fontNameTitle.characters.dropFirst())
            }
        
            return fontNameTitle
        case .sizes:
            return String(fontSizes[row])
        }
    }
    
    func scrollToRowForFont(_ font: UIFont) {
        delegateEnabled = false
        for (fontFamilyIndex, currentFont) in fontFamilies.enumerated() {
            if font.familyName == currentFont {
                fontPicker.selectRow(fontFamilyIndex, inComponent: FontPickerComponent.families.rawValue, animated: false)
                selectedRow = fontFamilyIndex
                updateFontNames()
                fontPicker.reloadAllComponents()
                for (fontNameIndex, currentFontName) in fontNames.enumerated() {
                    if font.fontName == currentFontName {
                        fontPicker.selectRow(fontNameIndex, inComponent: FontPickerComponent.names.rawValue, animated: false)
                        for (sizeIndex, currentSize) in fontSizes.enumerated() {
                            if Int(font.pointSize) == currentSize {
                                fontPicker.selectRow(sizeIndex, inComponent: FontPickerComponent.sizes.rawValue, animated: false)
                                delegateEnabled = true
                                return
                            }
                        }
                    }
                }
            }
        }
        delegateEnabled = true
    }

    func getFont(_ row: Int, forComponent component: Int, fontSize: CGFloat = UIFont.systemFontSize) -> UIFont {
        guard let fontPickerComponent = FontPickerComponent(rawValue: component) else {
            print("Not supported compontentnumber for Fontpicker: \(component)")
            return UIFont.systemFont(ofSize: fontSize)
        }
        
        switch fontPickerComponent {
        case .families:
            let fontName = fontFamilies[row]
            return UIFont(name: fontName, size: fontSize)!
        case .names:
            guard fontNames.count > 0 else {
                return UIFont.systemFont(ofSize: UIFont.systemFontSize)
            }
            let fontName = fontNames[row]
            return UIFont(name: fontName, size: fontSize)!
        default:
            return UIFont.systemFont(ofSize: fontSize)
        }
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel;

        if (pickerLabel == nil) {
            pickerLabel = UILabel()

            pickerLabel?.font = getFont(row, forComponent: component)
            pickerLabel?.textAlignment = .center
        }

        pickerLabel?.text = getTitle(row, forComponent: component)

        return pickerLabel!;
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        guard let fontPickerComponent = FontPickerComponent(rawValue: component) else {
            print("Not supported compontentnumber for Fontpicker: \(component)")
            return 0
        }
        let width = pickerView.bounds.width
        switch fontPickerComponent {
        case .families:
            return width / 2.5
        case .names:
            return width / 2.5
        case .sizes:
            return width / 5
        }
    }
    
    // MARK: - Actions
    
    @IBAction func handleAlignmentButtonPressed(_ sender: UIButton) {
        for button in alignmentButtons where button != sender && button.isSelected {
            button.isSelected = false
        }
        
        sender.isSelected = true
        guard let textAlignment = NSTextAlignment(rawValue: sender.tag) else {
            return
        }
        TextSettingsViewController.delegate?.changeAlignment(textAlignment)
    }

    @IBAction func handleDeleteTextButtonPressed() {
        TextSettingsViewController.delegate?.removeText()
    }
    
    @IBAction func handleDeleteLayerButtonPressed() {
        TextSettingsViewController.delegate?.removeLayer()
    }
    
    // MARK: - UIPickerViewDelegate 

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let fontPickerComponent = FontPickerComponent(rawValue: component) else {
            print("Not supported compontentnumber for Fontpicker: \(component)")
            return
        }

        switch fontPickerComponent {
        case .families:
            if selectedRow != row {
                selectedRow = row
                updateFontNames()
                pickerView.reloadComponent(FontPickerComponent.names.rawValue)
            }
        default:
            break
        }
        let familyRow = pickerView.selectedRow(inComponent: FontPickerComponent.names.rawValue)
        let fontSize = CGFloat(fontSizes[pickerView.selectedRow(inComponent: FontPickerComponent.sizes.rawValue)])
        let selectedFont = getFont(familyRow, forComponent: FontPickerComponent.names.rawValue, fontSize: fontSize)
        if delegateEnabled {
            TextSettingsViewController.delegate?.changeFont(selectedFont)
        }
    }
    
    // MARK: - ColorPickerDelegate
    
    override func didSelectColor(_ colorPicker: ColorPickerViewController, color: UIColor) {
        guard let colorPickerIdentifier = ColorPickerIdentifier(rawValue: colorPicker.identifier ?? "") else {
            return
        }
        switch colorPickerIdentifier {
        case .BackgroundColor:
            TextSettingsViewController.delegate?.changeBackgroundColor(color)
            break
        case .TextColor:
            TextSettingsViewController.delegate?.changeTextColor(color)
            break
        }
    }
    
    override func canSelectClearColor(_ colorPicker: ColorPickerViewController) -> Bool {
        guard let colorPickerIdentifier = ColorPickerIdentifier(rawValue: colorPicker.identifier ?? "") else {
            return false
        }
        switch colorPickerIdentifier {
        case .BackgroundColor:
            return true
        case .TextColor:
            return false
        }
    }
    
    func setupColorPicker(_ colorPicker: ColorPickerViewController) {
        guard let textLayer = TextSettingsViewController.delegate?.getTextLayer() else {
            return
        }
        
        guard let colorPickerIdentifier = ColorPickerIdentifier(rawValue: colorPicker.identifier ?? "") else {
            return
        }
        switch colorPickerIdentifier {
        case .BackgroundColor:
            colorPicker.setColorSelected(textLayer.backgroundColor)
            break
        case .TextColor:
            colorPicker.setColorSelected(textLayer.textColor)
            break
        }
    }
}
