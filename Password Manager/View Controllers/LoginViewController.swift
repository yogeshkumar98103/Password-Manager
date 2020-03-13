//
//  ViewController.swift
//  Password Manager
//
//  Created by Yogesh Kumar on 10/12/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import Cocoa

let greenColor = NSColor(red:0.37, green:0.80, blue:0.45, alpha:1.0)
let accentColor = greenColor


class LoginViewController: NSViewController {

    var passwordField: NSSecureTextField!
    var invalidPasswordLabel: NSTextField!
    
    var passwordText: NSTextField!
    var managerText: NSTextField!
    var productLabelStack: NSStackView!
    
    var productLabelTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Loaded")
        setupUI()
        setupContraints()
        handlePassword()
    }
    
    func setupUI(){
        // Product Label
        passwordText = NSTextField(labelWithString: "Passsword")
        passwordText.font = NSFont.systemFont(ofSize: 28)
        passwordText.textColor = accentColor
        
        managerText = NSTextField(labelWithString: "Manager")
        managerText.font = NSFont.systemFont(ofSize: 28)
        
        productLabelStack = NSStackView(views: [passwordText, managerText])
        productLabelStack.orientation = .horizontal
        productLabelStack.spacing = 10
        
        // passwordField
        passwordField = NSSecureTextField()
        passwordField.placeholderString = "Enter Your Password"
        passwordField.font = NSFont.systemFont(ofSize: 18)
        passwordField.bezelStyle = .roundedBezel
        passwordField.focusRingType = .none
        passwordField.action = #selector(handlePassword)
        
        // Invalid Password Label
        invalidPasswordLabel = NSTextField(labelWithString: "Access Denied")
        invalidPasswordLabel.font = NSFont.systemFont(ofSize: 16)
        invalidPasswordLabel.isBezeled = true
        invalidPasswordLabel.bezelStyle = .roundedBezel
        invalidPasswordLabel.alignment = .center
        invalidPasswordLabel.wantsLayer = true
        invalidPasswordLabel.layer?.cornerRadius = 5.0
        invalidPasswordLabel.isHidden = true
    }
    
    func setupContraints(){
        productLabelStack.translatesAutoresizingMaskIntoConstraints = false
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        invalidPasswordLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(productLabelStack)
        view.addSubview(passwordField)
        view.addSubview(invalidPasswordLabel)
        
        // Product Label
        productLabelTopConstraint = productLabelStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 50)
        productLabelStack.heightAnchor.constraint(equalToConstant: 35).isActive = true
//        productLabelStack.wantsLayer = true
//        productLabelStack.layer?.backgroundColor = NSColor.red.cgColor
        productLabelTopConstraint.isActive = true
        productLabelStack.centerX(view.centerXAnchor)
        
        // Password Field
        passwordField.anchor(bottom: view.bottomAnchor,  paddingBottom: 64, height: 40, width: 220)
        passwordField.centerX(view.centerXAnchor)
        
        // Invalid Password Label
        invalidPasswordLabel.anchor(bottom: passwordField.topAnchor, paddingBottom: 16, height: 30, width: 160)
        invalidPasswordLabel.centerX(view.centerXAnchor)
    }
    
    @objc func handlePassword(){
        invalidPasswordLabel.isHidden = false
//        if(!matchPassword(text: passwordField.stringValue)){
//            shakeView(passwordField)
//            return
//        }
        
        invalidPasswordLabel.textColor = accentColor
        invalidPasswordLabel.stringValue = "Access Granted"

        if let window = self.view.window {
            window.styleMask.update(with: .resizable)
            let frame = window.frame
            let dx: CGFloat = 100
            let dy: CGFloat = 100
            let newX = frame.origin.x - dx/2
            let newY = frame.origin.y - dy/2
            let newOrigin = CGPoint(x: newX, y: newY)
            let newSize = CGSize(width: frame.width + dx, height: frame.width + dy)
            let newFrame = NSRect(origin: newOrigin, size: newSize)
            
            // Animate Top Constaint of Product Label
            NSAnimationContext.runAnimationGroup( { _ in
                NSAnimationContext.current.duration = 1
                NSAnimationContext.current.timingFunction = CAMediaTimingFunction(name: .easeOut)
                self.productLabelTopConstraint.constant = 20
            })
            
            // Fade Out Other Elements
            NSAnimationContext.runAnimationGroup( { _ in
                NSAnimationContext.current.duration = 0.25
                NSAnimationContext.current.timingFunction = CAMediaTimingFunction(name: .linear)
                self.invalidPasswordLabel.animator().alphaValue = 0
                self.passwordField.animator().alphaValue = 0
            }, completionHandler:{
                self.invalidPasswordLabel.removeFromSuperview()
                self.passwordField.removeFromSuperview()
            })
            
            // Fade In New Elements
            addNewElements()
            
            window.setFrame(newFrame, display: true, animate: true)
        }
    }
    
    func addNewElements(){
//        let contentView = NSView()
//        view.addSubview(contentView)
        if let mainVC = self.storyboard?.instantiateController(withIdentifier: "MainViewController") as? MainViewController{
            self.addChild(mainVC)
            self.view.addSubview(mainVC.view)
            mainVC.view.anchor(top: productLabelStack.bottomAnchor, bottom: view.bottomAnchor, left: view.leadingAnchor, right: view.trailingAnchor, paddingTop: 5, paddingBottom: 5, paddingLeft: 5, paddingRight: 5)
//            mainVC.tableView.fillSuperView()
            print("Added Child")
        }
    }
    
    func matchPassword(text: String)->Bool{
        return (text == "123")
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func shakeView(_ shakeView: NSView) {
        let shake = CABasicAnimation(keyPath: "position")
        let xDelta = CGFloat(4)
        shake.duration = 0.06
        shake.repeatCount = 3
        shake.autoreverses = true


        let centerX = shakeView.frame.minX // + shakeView.frame.width / 2
        let from_point = NSPoint(x: centerX - xDelta, y: shakeView.frame.minY)
        let from_value = NSValue(point: from_point)

        let to_point = NSPoint(x: centerX + xDelta, y: shakeView.frame.minY)
        let to_value = NSValue(point: to_point)

        shake.fromValue = from_value
        shake.toValue = to_value
        shake.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        shakeView.layer?.add(shake, forKey: "position")
    }

}





// Shake Window
//    func shakeWindow(){
//        let numberOfShakes:Int = 4
//        let durationOfShake:Float = 0.5
//        let vigourOfShake:Float = 0.02
//
//        let frame:CGRect = view.window!.frame
//        let shakeAnimation = CAKeyframeAnimation()
//        let shakePath = CGMutablePath()
//        shakePath.move(to: CGPoint(x: NSMinX(frame), y: NSMinY(frame)))
//
//        for _ in 1...numberOfShakes {
//            shakePath.addLine(to: CGPoint(x:NSMinX(frame) - frame.size.width * CGFloat(vigourOfShake), y: NSMinY(frame)))
//            shakePath.addLine(to: CGPoint(x:NSMinX(frame) + frame.size.width * CGFloat(vigourOfShake), y: NSMinY(frame)))
//        }
//
//        shakePath.closeSubpath()
//        shakeAnimation.path = shakePath
//        shakeAnimation.duration = CFTimeInterval(durationOfShake)
//        view.window!.animations = ["frameOrigin":shakeAnimation]
//        view.window!.animator().setFrameOrigin(view.window!.frame.origin)
//    }
