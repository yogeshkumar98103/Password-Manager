//
//  Cerdential View.swift
//  Password Manager
//
//  Created by Yogesh Kumar on 12/12/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import Cocoa

// Feature :- Add Horizontal Scrolling in CustomTextField

class FocusTextFeld: NSTextField{
    var focusDelegate: CustomTextField?
    override func mouseDown(with event: NSEvent) {
        focusDelegate?.changeFocus()
    }
}

class FocusSecureTextFeld: NSSecureTextField{
    var focusDelegate: CustomTextField?
    override func mouseDown(with event: NSEvent) {
        focusDelegate?.changeFocus()
    }
}

class CustomTextField: NSView, NSTextFieldDelegate{
    var isSecure: Bool = false{
        didSet{
            if(isSecure){
                secureInput.isHidden = false
                normalInput.isHidden = true
                secureInput.stringValue = normalInput.stringValue
            }
            else{
                secureInput.isHidden = true
                normalInput.isHidden = false
                normalInput.stringValue = secureInput.stringValue
            }
        }
    }
    
    var isEditable: Bool = false{
        didSet{
            secureInput.isEditable = isEditable
            normalInput.isEditable = isEditable
        }
    }
    
    var stringValue: String{
        get{
            if isSecure{
                return secureInput.stringValue
            }
            return normalInput.stringValue
        }
    }
    
    var secureInput = FocusSecureTextFeld()
    var normalInput = FocusTextFeld()
    var delegate: NSTableView?
    var selectionIndexDelegate: DetailViewController?
    var copyButton: NSButton!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    init(wantsCopyButton: Bool){
        super.init(frame: .zero)
        setup(false)
    }
    
    func setup(_ wantsCopyButton: Bool = true) {
        secureInput.font = NSFont.systemFont(ofSize: 14)
        normalInput.font = NSFont.systemFont(ofSize: 16)
        secureInput.focusRingType = .none
        normalInput.focusRingType = .none
        normalInput.backgroundColor = .clear
        secureInput.backgroundColor = .clear
        normalInput.isBezeled = false
        secureInput.isBezeled = false
        normalInput.delegate = self
        secureInput.delegate = self
        secureInput.focusDelegate = self
        normalInput.focusDelegate = self
        isSecure = false
        
        if(wantsCopyButton){
            let image = NSImage(imageLiteralResourceName: "Copy").with(tintColor: NSColor.controlTextColor)
            let highlightImage = NSImage(imageLiteralResourceName: "Copy")
            copyButton = NSButton(image: image, target: self, action: #selector(handleCopy))
            copyButton.setButtonType(.momentaryChange)
            copyButton.bezelStyle = .regularSquare
            if let cell = copyButton.cell as? NSButtonCell{
                cell.isBordered = false
                cell.backgroundColor = .clear
            }
            copyButton.alternateImage = highlightImage
        }
        
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.controlHighlightColor.cgColor
        self.layer?.borderWidth = 0
        self.layer?.borderColor = NSColor.controlAccentColor.cgColor
        self.layer?.cornerRadius = 5
        setupConstraints(wantsCopyButton)
    }
    
    func setupConstraints(_ wantsCopyButton: Bool){
        self.addSubview(secureInput)
        self.addSubview(normalInput)
        if(wantsCopyButton){
            self.addSubview(copyButton)
            copyButton.anchor(right: trailingAnchor, paddingRight: 5, height: 24, width: 24)
            copyButton.anchor(height: 24, width: 24)
            copyButton.centerY(centerYAnchor)
            normalInput.anchor(left: leadingAnchor, right: copyButton.leadingAnchor, paddingTop: 5, paddingBottom: 5, paddingLeft: 5, paddingRight: 10)
        }
        else{
            normalInput.anchor(left: leadingAnchor, right: trailingAnchor, paddingTop: 5, paddingBottom: 5, paddingLeft: 5, paddingRight: 10)
        }

        normalInput.centerY(centerYAnchor)
        secureInput.anchor(left: normalInput.leadingAnchor, right: normalInput.trailingAnchor)
        secureInput.centerY(centerYAnchor)
    }
    
    var index: Int?
    func changeFocus(){
        if let index = self.index{
            guard let delegate = delegate else {return}
//            print("Before Selecting", delegate.selectedRow)
            if(selectionIndexDelegate?.isEditing ?? false){
                delegate.selectRowIndexes(.init(integer: index), byExtendingSelection: false)
                _ = delegate.delegate?.tableView!(delegate, shouldSelectRow: index)
//                print("After Selecting", delegate.selectedRow)
//                selectionIndexDelegate?.selectedRow = index
            }
        }
    }
    
    @objc func handleCopy(){
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        let text = isSecure ? secureInput.stringValue : normalInput.stringValue
        pasteBoard.setString(text, forType: .string)
    }
    
    func shouldHighlight(_ highlight: Bool){
        if(highlight){
//            self.layer?.borderWidth = 2
            self.selectionIndexDelegate?.selectedRow = index ?? -1
        }
        else{
//            self.layer?.borderWidth = 0
            self.selectionIndexDelegate?.selectedRow = -1
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CredentialLabelCell: NSTableCellView{
    var label = NSTextField()
    
    func setupUI(){
        label.isEditable = false
        label.isBezeled = false
        label.drawsBackground = false
        label.backgroundColor = .clear
        label.focusRingType = .none
        label.font = .systemFont(ofSize: 16)
    }
    
    var shouldApplyTopPadding: Bool = false{
        didSet{
            centerConstraint?.constant = shouldApplyTopPadding ? +2.5 : 0
        }
    }
    
    var shouldApplyBottomPadding: Bool = false{
        didSet{
            centerConstraint?.constant = shouldApplyBottomPadding ? -2.5 : 0
        }
    }
    
    var centerConstraint: NSLayoutConstraint!
    
    func setupConstraints(){
        self.addSubview(label)
        
        label.anchor(left: self.leadingAnchor, right: self.trailingAnchor, paddingLeft: 5, paddingRight: 5)
        centerConstraint = label.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0)
        centerConstraint.isActive = true
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setupUI()
        setupConstraints()
    }
}

class CredentialInputCell: NSTableCellView{
    var input = CustomTextField()
    var inputTopConstraint: NSLayoutConstraint?
    var inputBottomConstraint: NSLayoutConstraint?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: .zero)
        setupConstraints()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setupConstraints()
    }
    
    func setupConstraints(){
        input.isEditable = false
        self.addSubview(input)
        
        input.anchor(left: self.leadingAnchor, paddingLeft: 10)
        inputTopConstraint = input.topAnchor.constraint(equalTo: self.topAnchor, constant: 0)
        inputBottomConstraint = input.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        
        inputTopConstraint?.isActive = true
        inputBottomConstraint?.isActive = true
    }
    
    var shouldApplyTopPadding: Bool = false{
        didSet{
            inputTopConstraint?.constant = shouldApplyTopPadding ? 10 : 5
        }
    }
    
    var shouldApplyBottomPadding: Bool = false{
        didSet{
            inputBottomConstraint?.constant = shouldApplyBottomPadding ? -10 : -5
        }
    }
}

class SafeCredentialInputCell: CredentialInputCell{
    lazy var checkBox: NSButton = {
        return NSButton(checkboxWithTitle: "Show", target: self, action: #selector(handleSecureButton))
    }()
    
    override func setupConstraints(){
        super.setupConstraints()
        self.addSubview(checkBox)
        input.isSecure = true
        input.anchor(right: checkBox.leadingAnchor, paddingRight: 10)
        checkBox.anchor(right: self.trailingAnchor, paddingRight: 5, width: 55)
        checkBox.centerY(input.centerYAnchor)
    }
    
    @objc func handleSecureButton(){
        input.isSecure = (checkBox.state == .off)
    }
}

class NormalCredentialInputCell: CredentialInputCell{
    override func setupConstraints(){
        super.setupConstraints()
        input.anchor(right: trailingAnchor, paddingRight: 5)
    }
}
