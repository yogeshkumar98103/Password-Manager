//
//  Testing.swift
//  Password Manager
//
//  Created by Yogesh Kumar on 12/12/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import Cocoa

class CredentialInput: NSView{
    var isSecureCell: Bool = false{
        didSet{
            input.isSecure = isSecureCell
            if !isSecureCell {
                checkBox?.removeFromSuperview()
                checkBox = nil
                inputRightConstraintWithCheckBox?.isActive = false
                inputRightConstraintWithoutCheckBox?.isActive = true
                return
            }
            else{
                checkBox = NSButton(checkboxWithTitle: "Show", target: self, action: #selector(handleSecureButton))
                guard let box = checkBox else{return}
                self.addSubview(box)
                inputRightConstraintWithCheckBox = input.trailingAnchor.constraint(equalTo: box.leadingAnchor, constant: -10)
                inputRightConstraintWithCheckBox?.isActive = true
                inputRightConstraintWithoutCheckBox?.isActive = false
                
                box.anchor(right: self.trailingAnchor, paddingRight: 5)
                box.centerY(input.centerYAnchor)
            }
        }
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
    
    var input: CustomTextField!
    var checkBox: NSButton?
    
    var inputRightConstraintWithCheckBox: NSLayoutConstraint?
    var inputRightConstraintWithoutCheckBox: NSLayoutConstraint?
    var inputTopConstraint: NSLayoutConstraint?
    var inputBottomConstraint: NSLayoutConstraint?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: .zero)
        setupConstraints()
    }
    
    init(wantsCopyButton: Bool){
        super.init(frame: .zero)
        setupConstraints(wantsCopyButton)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setupConstraints()
    }
    
    func setupConstraints(_ wantsCopyButton: Bool = true){
        input = CustomTextField(wantsCopyButton: wantsCopyButton)
        self.addSubview(input)
        
        input.anchor(left: self.leadingAnchor, paddingLeft: 10)
        
        inputRightConstraintWithoutCheckBox = input.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5)
        inputTopConstraint = input.topAnchor.constraint(equalTo: self.topAnchor, constant: 0)
        inputBottomConstraint = input.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        
        inputRightConstraintWithoutCheckBox?.isActive = true
        inputTopConstraint?.isActive = true
        inputBottomConstraint?.isActive = true
    }
    
    @objc func handleSecureButton(){
        input.isSecure = (checkBox?.state == .off)
    }
}
