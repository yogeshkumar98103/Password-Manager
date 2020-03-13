//
//  TableCell.swift
//  Password Manager
//
//  Created by Yogesh Kumar on 11/12/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import Cocoa

class TableData: NSObject{
    let image: NSImage?
    @objc let name: String
    @objc var tags: String = ""
    
    init(name: String, tags: [String]? = nil, image: NSImage? = nil) {
        self.name = name
        self.image = image
        guard let tags = tags else{return}
        for tag in tags{
            self.tags += (tag + " ")
        }
    }
}

//var count2 = 1

class TableCell: NSTableCellView{
    var SPImageView = NSImageView()
    var SPNameLabel = NSTextField()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    func setupConstraints(){
        let padding: CGFloat = 5.0
        SPImageView.anchor(top: self.topAnchor, bottom: self.bottomAnchor, left: self.leadingAnchor, paddingTop: padding, paddingBottom: padding, paddingLeft: padding)
        SPImageView.widthAnchor.constraint(equalTo: SPImageView.heightAnchor, multiplier: 1).isActive = true
        
        SPNameLabel.anchor(left: SPImageView.trailingAnchor, right: self.trailingAnchor, paddingLeft: 15, paddingRight: 15)
        SPNameLabel.centerY(self.centerYAnchor)
        
    }
    
    
    required init?(coder decoder: NSCoder) {
        super.init(frame: .zero)
        self.addSubview(SPImageView)
        self.addSubview(SPNameLabel)
        SPNameLabel.backgroundColor = .clear
        SPNameLabel.isBezeled = false
        SPNameLabel.font = NSFont.systemFont(ofSize: 14)
//        SPNameLabel.isEditable = false
        
        setupConstraints()
    }
}
