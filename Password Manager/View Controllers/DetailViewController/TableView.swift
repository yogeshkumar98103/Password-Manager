//
//  TableView.swift
//  Password Manager
//
//  Created by Yogesh Kumar on 14/12/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import Cocoa

class TrackableTableView: NSTableView{
    var isEditing: Bool?
    
    func editingMode(_ allowEditing: Bool){
        if(isEditing != nil && isEditing! == allowEditing){ return }
        for i in 0 ..< numberOfRows{
            if let cell = super.rowView(atRow: i, makeIfNecessary: false)?.view(atColumn: 1) as? CredentialInputCell{
                cell.input.isEditable = allowEditing
            }
            
            if let cell = super.rowView(atRow: i, makeIfNecessary: false)?.view(atColumn: 0) as? CredentialLabelCell{
                cell.label.isEditable = allowEditing
            }
        }
        
        isEditing = allowEditing
        if(!allowEditing){
            window?.makeFirstResponder(self)
        }
    }
    
    override func validateProposedFirstResponder(_ responder: NSResponder, for event: NSEvent?) -> Bool {
        return true
    }
}


extension DetailViewController: NSTableViewDelegate, NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        print((credArrayController.arrangedObjects as! [Credential]).count)
        return (credArrayController.arrangedObjects as! [Credential]).count
    }
    
    override func mouseDown(with event: NSEvent) {
        print("Add Credential")
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let identifier = tableColumn?.identifier else {return nil}
        
        print("Rendering", isEditing)
        let credentials = (credArrayController.arrangedObjects as! [Credential])
        switch identifier.rawValue{
        case cellLabelID:
            if let cell = tableView.makeView(withIdentifier: identifier, owner: self) as? CredentialLabelCell{
//                cell.label.stringValue = credentials[row].key ?? ""
                cell.label.bind(.value, to: cell, withKeyPath: "objectValue.key", options: nil)
                cell.shouldApplyTopPadding = (row == 0)
                cell.shouldApplyBottomPadding = (row == credentials.count - 1)
                cell.label.isEditable = isEditing
                return cell
            }
            
        case cellInputID:
            
            if credentials[row].isSecureType{
                let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellSafeInputID), owner: self) as! SafeCredentialInputCell
//                cell.input.normalInput.stringValue = credentials[row].value ?? ""
//                cell.input.secureInput.stringValue = credentials[row].value ?? ""
                cell.input.normalInput.bind(.value, to: cell, withKeyPath: "objectValue.value", options: nil)
                cell.input.secureInput.bind(.value, to: cell, withKeyPath: "objectValue.value", options: nil)
                cell.checkBox.state = .off
                cell.handleSecureButton()
                cell.input.delegate = self.tableView
                cell.input.selectionIndexDelegate = self
                cell.input.index = row
                cell.shouldApplyTopPadding = (row == 0)
                cell.shouldApplyBottomPadding = (row == credentials.count - 1)
                cell.input.isEditable = isEditing
                if(!isEditing){
                    if(row == selectedRow){
                        cell.input.layer?.borderWidth = 2
                    }
                    else{
                        cell.input.layer?.borderWidth = 0
                    }
                }
                return cell
            }
            else{
                let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellNormalInputID), owner: self) as! NormalCredentialInputCell
                
//                cell.input.normalInput.stringValue = credentials[row].value ?? ""
//                cell.input.secureInput.stringValue = credentials[row].value ?? ""
                cell.input.normalInput.bind(.value, to: cell, withKeyPath: "objectValue.value", options: nil)
                cell.input.secureInput.bind(.value, to: cell, withKeyPath: "objectValue.value", options: nil)
                cell.input.delegate = self.tableView
                cell.input.selectionIndexDelegate = self
                cell.input.index = row
                cell.shouldApplyTopPadding = (row == 0)
                cell.shouldApplyBottomPadding = (row == credentials.count - 1)
                cell.input.isEditable = isEditing
                if(!isEditing){
                    cell.input.shouldHighlight(false)
                }
                return cell
            }
            
        default: return nil
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        var height: CGFloat = 44
        if(row == 0){ height += 5}
        if(row == (credArrayController.arrangedObjects as! [Credential]).count - 1){ height += 5}
        return height
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if(isEditing){
            let cell = tableView.rowView(atRow: row, makeIfNecessary: false)?.view(atColumn: 1) as! CredentialInputCell
            cell.input.shouldHighlight(true)
//            self.selectedRow = row
        }
        return isEditing
    }
    
    func selectionShouldChange(in tableView: NSTableView) -> Bool{
        if(isEditing && tableView.selectedRow != -1){
            let cell = tableView.rowView(atRow: tableView.selectedRow, makeIfNecessary: false)?.view(atColumn: 1) as! CredentialInputCell
            cell.input.shouldHighlight(false)
//            self.selectedRow = -1
        }
        return isEditing
    }
}
