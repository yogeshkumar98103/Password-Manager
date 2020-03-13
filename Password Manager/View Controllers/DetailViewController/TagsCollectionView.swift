//
//  (tagsArrayController.arrangedObjects as! [Tag])CollectionView.swift
//  Password Manager
//
//  Created by Yogesh Kumar on 14/12/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import Cocoa

class PointerTextField: NSTextField{
    var trackingArea: NSTrackingArea?
    override func resetCursorRects() {
        self.discardCursorRects()
        self.addCursorRect(self.bounds, cursor: NSCursor.arrow)
    }
    
    override func becomeFirstResponder() -> Bool {
        return super.becomeFirstResponder()
        
    }
}

class TagCell: NSCollectionViewItem{
    let label = PointerTextField()
    var cancelImage:NSButton!
    let container = NSView()
    var delegate: DetailViewController?
    
    override func loadView() {
        self.view = NSView()
        let image = NSImage(imageLiteralResourceName: "Cross2").with(tintColor: NSColor(calibratedWhite: 0.9, alpha: 0.8))
        cancelImage = NSButton(image: image, target: self, action: #selector(handleCancel))
        cancelImage.bezelStyle = .shadowlessSquare
        cancelImage.wantsLayer = true
        cancelImage.layer?.backgroundColor = .clear
        cancelImage.layer?.cornerRadius = 8
        view.addSubview(container)
        container.addSubview(label)
        view.addSubview(cancelImage)
        
        container.wantsLayer = true
        container.layer?.cornerRadius = 8
        
        container.anchor(top: view.topAnchor, bottom: view.bottomAnchor, left: view.leadingAnchor, right: view.trailingAnchor, paddingTop: 6, paddingRight: 6)
        
        label.alignment = .center
        label.font = .systemFont(ofSize: 14)
        label.focusRingType = .none
        label.isBezeled = false
        label.backgroundColor = .clear
        
        label.anchor(left: container.leadingAnchor, right:
            container.trailingAnchor, paddingLeft: 0, paddingRight: 0)
        label.centerY(container.centerYAnchor)
        cancelImage.anchor(top: view.topAnchor, right: view.trailingAnchor, paddingTop: 4, paddingRight: 4, height: 16, width: 16)
        
//        let gesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick))
//        label.addGestureRecognizer(gesture)
    }
    
    @objc func handleCancel(){
        delegate?.removeTag(index: cancelImage.tag)
    }
    
    @objc func handleClick(){
//        print("Clicked")
//        self.label.isSelectable = true
        self.label.becomeFirstResponder()
    }
}


extension DetailViewController: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout, NSTextFieldDelegate{
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        print((tagsArrayController.arrangedObjects as! [Tag]).count)
        return (tagsArrayController.arrangedObjects as! [Tag]).count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .init(tagsCellID), for: indexPath) as! TagCell
        item.container.layer?.backgroundColor = NSColor.darkGray.cgColor
//        item.label.stringValue = (tagsArrayController.arrangedObjects as! [Tag])[indexPath.item].string ?? ""
        item.label.delegate = self
        item.delegate = self
        item.cancelImage.tag = indexPath.item
        item.label.tag = indexPath.item
        item.label.bind(.value, to: item, withKeyPath: "representedObject.string", options: nil)
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
//        let data = (tagsArrayController.arrangedObjects as! [Tag])[indexPath.item].string ?? ""
        let data = tags[indexPath.item]
        let estimatedFrame = NSString(string: data).boundingRect(with: NSSize(width: 200, height: 30), options: .usesLineFragmentOrigin, attributes: [.font: NSFont.systemFont(ofSize: 14)], context: nil)
        let width = max(estimatedFrame.width, 60) + 20
        return NSSize.init(width: width, height: 36)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, insetForSectionAt section: Int) -> NSEdgeInsets {
        return NSEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
}
