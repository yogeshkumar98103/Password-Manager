//
//  Event Handlers.swift
//  Password Manager
//
//  Created by Yogesh Kumar on 14/12/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import Cocoa

protocol CustomTextFieldDelegate: class{
    func addNewTag()
}

class CustomCollectionView: NSCollectionView{
    var clickDelegate: CustomTextFieldDelegate?
    
    override func mouseDown(with event: NSEvent) {
        clickDelegate?.addNewTag()
        super.mouseDown(with: event)
    }
}

extension DetailViewController: NextProtocol, CustomTextFieldDelegate{
 
    func loadData(){
        credArrayController.content = nil
        credArrayController.add(contentsOf: ((delegate.SPArrayController.arrangedObjects as! [ServiceProvider])[index].credentials?.array)!)
        tagsArrayController.content = nil
        tagsArrayController.add(contentsOf: ((delegate.SPArrayController.arrangedObjects as! [ServiceProvider])[index].tags?.array)! as! [Tag])
        self.tags = []
        for tag in tagsArrayController.arrangedObjects as! [Tag]{
            tags.append(tag.string ?? "")
        }
        
        let data = (delegate.SPArrayController.arrangedObjects as! [ServiceProvider])[index]
        SPName.stringValue = data.name ?? ""
        if let image = data.image{
            SPImage.image = NSImage(data: image)
        }
//        tableView.reloadData()
    }
    
    @objc func handleEditMode(){
        isEditing = true
    }
    
    @objc func addNewCred(){
        selectedRow = -1
        performSegue(withIdentifier: "AddNewCred", sender: self)
    }

    @objc func removeCred(){
        print("Removing Credential")
        if(tableView.selectedRow >= 0){
            credArrayController.remove(atArrangedObjectIndex: tableView.selectedRow)
            selectedRow = -1
        }
    }
    
    @objc func selectImage(){
        guard let window = view.window else { return }
        if(!SPImage.isEditable){ return}
        
        imageSelectionPanel.beginSheetModal(for: window) { (result) in
            if result == NSApplication.ModalResponse.OK {
                let selectedImageURL = self.imageSelectionPanel.urls[0]
                self.SPImage.image = NSImage(byReferencing: selectedImageURL)
                (self.delegate.SPArrayController.arrangedObjects as! [ServiceProvider])[self.index].image = self.SPImage.image?.tiffRepresentation
            }
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destinationController as? AddCredViewController{
            destinationVC.delegate = self
        }
    }
    
    func sendBack(_ data: Credential) {
        (delegate.SPArrayController.arrangedObjects as! [ServiceProvider])[index].addToCredentials(data)
//        delegate.serviceProviders[index].addToCredentials(data)
        data.serviceProvider = (delegate.SPArrayController.arrangedObjects as! [ServiceProvider])[index]
        credArrayController.addObject(data)
//        credentials.append(data)
//        tableView.reloadData()
    }
    
    @objc func addNewTag(){
        print("Creating New Tag")
        let newTag = Tag(context: context)
        newTag.string = ""
        newTag.serviceProvider = (delegate.SPArrayController.arrangedObjects as! [ServiceProvider])[index]
        (delegate.SPArrayController.arrangedObjects as! [ServiceProvider])[index].addToTags(newTag)
        tags.append("")
        tagsArrayController.addObject(newTag)
        saveToStorage()
        
        let count = tagsCollectionView.numberOfItems(inSection: 0)
        if let cell = tagsCollectionView.item(at: IndexPath(item: count - 1, section: 0)) as? TagCell{
            DispatchQueue.main.async{
                self.view.window?.makeFirstResponder(cell.label)
            }
        }
//        tagsCollectionView.reloadData()
    }
    
    @objc func removeTag(index: Int){
        print("Delete")
        tagsArrayController.remove(atArrangedObjectIndex: index)
        tags.remove(at: index)
        saveToStorage()
    }
    
    // Save Tags
    func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? PointerTextField{
            tags[textField.tag] = textField.stringValue
            tagsCollectionView.collectionViewLayout?.invalidateLayout()
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        if let textField = obj.object as? NSTextField{
            if(textField == SPName){
                (self.delegate.SPArrayController.arrangedObjects as! [ServiceProvider])[self.index].name = SPName.stringValue
            }
            else{
                tagsCollectionView.window?.makeFirstResponder(self)
                print("Saving Tag")
            }
            saveToStorage()
        }
    }

    @objc func saveChanges(){
        isEditing = false
        selectedRow = -1
        saveToStorage()
    }
    
    @objc func cancelChanges(){
        isEditing = false
        selectedRow = -1
        context.rollback()
        context.refresh((delegate.SPArrayController.arrangedObjects as! [ServiceProvider])[index], mergeChanges: false)
        loadData()
    }
}
