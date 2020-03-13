//
//  AddCredViewController.swift
//  Password Manager
//
//  Created by Yogesh Kumar on 13/12/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import Cocoa

protocol NextProtocol: class {
    func sendBack(_ data: Credential)
}

class AddCredViewController: NSViewController, NSTextFieldDelegate{

    var informativeText = NSTextField()
    var label = NSTextField()
    var warningLabel = NSTextField()
    var input = CredentialInput(wantsCopyButton: false)
    var secureField: NSButton!
    var addButton: NSButton!
    var cancelButton: NSButton!
    weak var delegate: NextProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        input.isSecureCell = true
        input.input.secureInput.placeholderString = "Enter Corresponding Value"
        input.input.normalInput.placeholderString = "Enter Corresponding Value"
        label.placeholderString = "Enter a Key"
        informativeText.stringValue = "Add New Field"
        informativeText.isBezeled = false
        informativeText.backgroundColor = .clear
        informativeText.font = NSFont.systemFont(ofSize: 22)
        informativeText.isSelectable = false
        
        warningLabel.stringValue = "Empty fields are not allowed"
        warningLabel.isBezeled = false
        warningLabel.backgroundColor = .clear
        warningLabel.wantsLayer = true
        warningLabel.layer?.cornerRadius = 8
        warningLabel.font = NSFont.systemFont(ofSize: 16, weight: .medium)
        warningLabel.isSelectable = false
        warningLabel.isHidden = true
        warningLabel.textColor = NSColor(red:0.94, green:0.20, blue:0.20, alpha:1.0)
        
        secureField = NSButton(checkboxWithTitle: "Make This Secure Field", target: nil, action: nil)
        
        addButton = NSButton(title: "Add", target: self, action: #selector(addCred))
        addButton.isHighlighted = true
        cancelButton = NSButton(title: "Cancel", target: self, action: #selector(cancel))
        
        view.addSubview(informativeText)
        view.addSubview(label)
        view.addSubview(input)
        view.addSubview(secureField)
        view.addSubview(addButton)
        view.addSubview(cancelButton)
        view.addSubview(warningLabel)
        
        informativeText.anchor(top: view.topAnchor, paddingTop: 30, height: 35)
        informativeText.centerX(view.centerXAnchor)
        
        label.font = NSFont.systemFont(ofSize: 16)
        label.isEditable = true
        input.input.normalInput.font = NSFont.systemFont(ofSize: 16)
        input.input.secureInput.font = NSFont.systemFont(ofSize: 15)
        
        input.anchor(top: informativeText.bottomAnchor, left: label.trailingAnchor, right: view.trailingAnchor, paddingTop: 30, paddingLeft: 20, paddingRight: 30, height: 34)
        
        label.anchor(left: view.leadingAnchor, paddingLeft: 30, height: 28, width: 120)
        label.centerY(input.centerYAnchor)
        
        secureField.anchor(top: input.bottomAnchor, left: view.leadingAnchor, paddingTop: 20, paddingLeft: 40)
        addButton.anchor(bottom: view.bottomAnchor, right: view.trailingAnchor, paddingBottom: 20 , paddingRight: 20)
        cancelButton.anchor(bottom: view.bottomAnchor, right: addButton.leadingAnchor, paddingBottom: 20, paddingRight: 20)
        warningLabel.anchor(bottom: addButton.topAnchor, right: view.trailingAnchor, paddingBottom: 20, paddingRight: 20)
        
        input.input.secureInput.delegate = self
        input.input.normalInput.delegate = self
        label.delegate = self
        
        // Do view setup here.
    }
    
    @objc func addCred(){
        if(label.stringValue.isEmpty || (input.input?.stringValue.isEmpty ?? false)){
            warningLabel.isHidden = false
            return
        }
        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let data = Credential(context: context)
        data.isSecureType = (secureField.state == .on)
        data.key = label.stringValue
        data.value = input.input.stringValue
        delegate?.sendBack(data)
        dismiss(nil)
    }
    
    @objc func cancel(){
        dismiss(nil)
    }
    
    func controlTextDidChange(_ obj: Notification) {
        if(!warningLabel.isHidden && !(label.stringValue.isEmpty || (input.input?.stringValue.isEmpty ?? false))){
            warningLabel.isHidden = true
        }
    }
    
}
