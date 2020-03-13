//
//  MainViewController.swift
//  Password Manager
//
//  Created by Yogesh Kumar on 10/12/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import Cocoa
import CoreData

class MainViewController: NSViewController{
    @IBOutlet weak var oldSearchTextField: NSSearchField!
    let searchTextField = NSSearchField()
    @IBOutlet var SPArrayController: NSArrayController!
    let splitView = NSSplitView()
    
    // List View
    let listView = NSView()
    let tableScrollView = NSScrollView()
    let tableView = NSTableView()

    // ToolBar
    var addButton: NSButton!
    var removeButton: NSButton!
    var toolbar: NSStackView!
    
    let cellID = "TableCell"
    let splitRatio: CGFloat = 0.4
    
    // DetailView
    let detailView = NSView()
    var detailVC: DetailViewController!
    var detailsVisible: Bool = false
    
    @objc let context: NSManagedObjectContext
    required init?(coder: NSCoder) {
        context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        setupUI()
        setupConstraints()
//        loadFromStorage()
        tableView.dataSource = self
        tableView.delegate = self
        searchTextField.delegate = self
        
        tableView.bind(.selectionIndexes, to: SPArrayController, withKeyPath: "selectionIndexes", options: nil)
        
    }
    
    func saveToStorage(){
        do{    try context.save() }
        catch{ print(error)       }
    }
    
    func loadFromStorage(){
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ServiceProvider")
        do {
            let serviceProviders = try context.fetch(fetchRequest) as! [ServiceProvider]
            print(serviceProviders)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func setupUI(){
        // Search Field
        searchTextField.focusRingType = .none
        searchTextField.font = .systemFont(ofSize: 16)
        
        // Toolbar
        addButton = NSButton(image: .init(imageLiteralResourceName: "NSAddTemplate"), target: self, action: #selector(addNewData))
        removeButton = NSButton(image: .init(imageLiteralResourceName: "NSRemoveTemplate"), target: self, action: #selector(removeData))
        
        toolbar = NSStackView(views: [addButton, removeButton])
        toolbar.alignment = .leading
        toolbar.spacing = 3
        toolbar.orientation = .horizontal
        
        // Table ScrollView
        tableScrollView.documentView = tableView
        tableScrollView.hasHorizontalRuler = true
        tableScrollView.hasVerticalRuler = true
        
        // Table View
        let nib = NSNib(nibNamed: cellID, bundle: nil)
        tableView.register(nib, forIdentifier: .init(rawValue: cellID))
        let col = NSTableColumn(identifier: .init(rawValue: cellID))
        tableView.addTableColumn(col)
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.headerView = nil
        tableView.bind(.content, to: SPArrayController, withKeyPath: "arrangedObjects", options: nil)
        tableView.bind(.sortDescriptors, to: SPArrayController, withKeyPath: "sortDescriptors", options: nil)
        
        // Detail View
        if let detailVC = self.storyboard?.instantiateController(withIdentifier: "DetailViewController") as? DetailViewController{
            self.detailVC = detailVC
            self.detailVC.delegate = self
            self.addChild(detailVC)
        }
        
        // Split View
        splitView.addSubview(listView)
        splitView.addSubview(detailView)
        splitView.isVertical = true
        splitView.dividerStyle = .thick
        splitView.adjustSubviews()
    }
    
    func setupConstraints(){
        view.addSubview(searchTextField)
        view.addSubview(splitView)
        listView.addSubview(tableScrollView)
        listView.addSubview(toolbar)

        // Search Text Field
        searchTextField.anchor(top: view.topAnchor, left: view.leadingAnchor, right: view.trailingAnchor, paddingTop: 30, paddingLeft: 10, paddingRight: 10, height: 40)
        
        // Split View
        splitView.anchor(top: searchTextField.bottomAnchor, bottom: view.bottomAnchor, left: view.leadingAnchor, right: view.trailingAnchor, paddingTop: 10, paddingBottom: 10, paddingLeft: 10, paddingRight: 10)
        
        listView.widthAnchor.constraint(greaterThanOrEqualToConstant: 180).isActive = true
        
        // Toolbar
        addButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        removeButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        removeButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        toolbar.anchor(bottom: listView.bottomAnchor, left: listView.leadingAnchor, right: listView.trailingAnchor, height: 24)
        
        // Table Scroll View
        tableScrollView.anchor(top: listView.topAnchor, bottom: toolbar.topAnchor, left: listView.leadingAnchor, right: listView.trailingAnchor, paddingTop: 10, paddingBottom: 10)
    }
    
    @objc func addNewData(){
        print("Adding New Data")
        let newData = ServiceProvider(context: context)
        newData.name = "Yogesh Kumar"
        newData.image = NSImage(imageLiteralResourceName: "Google").tiffRepresentation
        let credential = Credential(context: context)
        credential.key = "Email"
        credential.value = "a@b.com"
        credential.isSecureType = false
        newData.addToCredentials(credential)
        credential.serviceProvider = newData
        let tag = Tag(context: context)
        tag.string = "New Tag"
        newData.addToTags(tag)
        tag.serviceProvider = newData
//        serviceProviders.append(newData)
        SPArrayController.addObject(newData)
        saveToStorage()
//        tableView.reloadData()
    }
    
    @objc func removeData(){
        print("Removing")
//        context.delete(serviceProviders[tableView.selectedRow])
//        serviceProviders.remove(at: tableView.selectedRow)
//        tableView.reloadData()
        SPArrayController.remove(atArrangedObjectIndex: tableView.selectedRow)
        detailVC.view.removeFromSuperview()
        detailsVisible = false
        saveToStorage()
    }
    
    lazy var predicate: NSPredicate = {
        return NSPredicate(format: "(name contains[cd] $search) OR (ANY tags.string like[cd] $wildcardSearch)")
    }()
}

extension MainViewController: NSSearchFieldDelegate{
    func controlTextDidChange(_ obj: Notification) {
        handleSearch(searchTextField)
    }
    
    func handleSearch(_ sender: NSSearchField){
        if sender.stringValue.isEmpty {
            SPArrayController.filterPredicate = nil
            return
        }

        SPArrayController.filterPredicate = predicate.withSubstitutionVariables(["search" : sender.stringValue, "wildcardSearch": "\(sender.stringValue)*"])
    }
}

extension MainViewController: NSTableViewDelegate,NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
//        return serviceProviders.count
        return (SPArrayController.arrangedObjects as! [ServiceProvider]).count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: (tableColumn?.identifier)!, owner: self) as? TableCell{

//            cell.SPNameLabel.stringValue = serviceProviders[row].name ?? ""
//            if let imgData = serviceProviders[row].image{
//                cell.SPImageView.image = NSImage(data: imgData)
//            }
            cell.SPNameLabel.bind(.value, to: cell, withKeyPath: "objectValue.name", options: nil)
            cell.SPImageView.bind(.data, to: cell, withKeyPath: "objectValue.image", options: nil)
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if tableView.selectedRow >= 0, let selected = tableView.view(atColumn: 0, row: tableView.selectedRow, makeIfNecessary: false) as? TableCell{
            print(selected.SPNameLabel.stringValue)
            if(!detailsVisible){
                detailView.addSubview(detailVC.view)
                detailVC.view.fillSuperView()
                detailsVisible = true
            }
            
            detailVC.index = tableView.selectedRow
        }
        else{
            tableView.deselectRow(tableView.selectedRow)
        }
    }
}

