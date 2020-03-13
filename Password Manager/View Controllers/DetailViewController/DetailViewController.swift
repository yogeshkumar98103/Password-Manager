//
//  DetailViewController.swift
//  Password Manager
//
//  Created by Yogesh Kumar on 11/12/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import Cocoa

class DetailViewController: NSViewController{
    var tags: [String] = []
    var index: Int = 0{
        didSet{
            loadData()
        }
    }
    
    var selectedRow: Int = -1{
        willSet{
            print("Old Value : ", selectedRow)
            if selectedRow >= 0 && selectedRow < tableView.numberOfRows, let cell = tableView.rowView(atRow: selectedRow, makeIfNecessary: false)?.view(atColumn: 1) as? CredentialInputCell{
                cell.input.layer?.borderWidth = 0
            }
            else{
                
            }
        }
        didSet{
            print("New Value : ", selectedRow)
            if selectedRow >= 0 && selectedRow < tableView.numberOfRows, let cell = tableView.rowView(atRow: selectedRow, makeIfNecessary: false)?.view(atColumn: 1) as? CredentialInputCell{
                cell.input.layer?.borderWidth = 2
            }
        }
    }
    
    @IBOutlet var tagsArrayController: NSArrayController!
    @IBOutlet var credArrayController: NSArrayController!
    
    var credentials: [Credential] = []
    
    // Service Provider Details
    var SPImage = NSImageView()
    var SPName = NSTextField()
    
    // Credentials
    var tableScrollView = NSScrollView()
    var tableView = TrackableTableView()
    var credControlStack: NSStackView!
    var addCredButton: NSButton!
    var removeCredButton: NSButton!
    
    // Tags
    var tagsScrollView = NSScrollView()
    var tagsCollectionView = CustomCollectionView()
    var tagsLabel = NSTextField()
    var tagControlStack: NSStackView!
    var addTagButton: NSButton!
    var removeTagButton: NSButton!
    
    // Controls
    var editButton: NSButton!
    var saveButton: NSButton!
    var cancelButton: NSButton!
    
    // Cell ID
    let cellLabelID = "CredentialLabelCell"
    let cellInputID = "CredentialInputCell"
    let cellSafeInputID = "SafeCredentialInputCell"
    let cellNormalInputID = "NormalCredentialInputCell"
    let tagsCellID = "TagCell"
    let tagsHeaderID = "TagHeaderCell"
    
    // Panels
    lazy var imageSelectionPanel: NSOpenPanel = {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["png", "jpg", "jpeg"]
        return panel
    }()
    
    // State
    var isEditing: Bool = false{
        didSet{
            tableView.editingMode(isEditing)
            editButton.isHidden = isEditing
            saveButton.isHidden = !isEditing
            cancelButton.isHidden = !isEditing
            credControlStack.isHidden = !isEditing
            SPName.isEditable = isEditing
            SPImage.isEditable = isEditing
        }
    }
    
    func saveToStorage(){
        do{    try context.save() }
        catch{ print(error)       }
    }
    
    @objc let context: NSManagedObjectContext
    required init?(coder: NSCoder) {
        context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        super.init(coder: coder)
    }
    
    var delegate: MainViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        print("Detail Loaded")
        
        tableView.bind(.content, to: credArrayController, withKeyPath: "arrangedObjects", options: nil)
        tagsCollectionView.bind(.content, to: tagsArrayController, withKeyPath: "arrangedObjects", options: nil)
        tagsCollectionView.clickDelegate = self
        tableView.selectionHighlightStyle = .none
        tableView.allowsEmptySelection = true
//        tagsCollectionView.bind(.selectionIndexes, to: tagsArrayController, withKeyPath: "selectionIndexes", options: nil)
//        credArrayController.bind(.contentSet, to: delegate.SPArrayController, withKeyPath: "selection.credentials", options: nil)
        
        setupUI()
        setupConstraints()
        tableView.delegate = self
        tableView.dataSource = self
        
        tagsCollectionView.delegate = self
        tagsCollectionView.dataSource = self
        
        isEditing = false
    }
    
    
    func setupUI(){
        // Service Provider Details
        SPName.isBezeled = false
        SPName.backgroundColor = .clear
        SPName.alignment = .center
        SPName.font = .systemFont(ofSize: 20)
        SPName.focusRingType = .none
        SPName.isEditable = false
        SPName.delegate = self
        
        SPImage.isEditable = isEditing
        SPImage.focusRingType = .none
        SPImage.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(selectImage)))
        
        // Table ScrollView
        tableScrollView.documentView = tableView
        tableScrollView.hasHorizontalRuler = false
        tableScrollView.hasVerticalRuler = true
       
        // Table View
        let labelNib = NSNib(nibNamed: cellLabelID, bundle: nil)
        tableView.register(labelNib, forIdentifier: .init(rawValue: cellLabelID))
        let labelCol = NSTableColumn(identifier: .init(rawValue: cellLabelID))
        labelCol.width = 85
        
        let inputNib = NSNib(nibNamed: cellInputID, bundle: Bundle.main)
        tableView.register(inputNib, forIdentifier: .init(rawValue: cellSafeInputID))
        tableView.register(inputNib, forIdentifier: .init(rawValue: cellNormalInputID))
        
        let inputCol = NSTableColumn(identifier: .init(rawValue: cellInputID))
        
        tableView.addTableColumn(labelCol)
        tableView.addTableColumn(inputCol)
        tableView.headerView = nil
        
        // Tags Scroll View
        tagsScrollView.documentView = tagsCollectionView
        tagsScrollView.hasHorizontalRuler = false
        tagsScrollView.hasVerticalRuler = true
        
        // Credential Control Stack
        addCredButton = NSButton(image: .init(imageLiteralResourceName: "NSAddTemplate"), target: self, action: #selector(addNewCred))
        removeCredButton = NSButton(image: .init(imageLiteralResourceName: "NSRemoveTemplate"), target: self, action: #selector(removeCred))
        
        credControlStack = NSStackView(views: [addCredButton, removeCredButton])
        credControlStack.alignment = .trailing
        credControlStack.spacing = 3
        credControlStack.orientation = .horizontal
        credControlStack.edgeInsets = NSEdgeInsets(top: 3, left: 5, bottom: 5, right: 5)
        credControlStack.wantsLayer = true
        credControlStack.layer?.backgroundColor = NSColor(red:0.16, green:0.15, blue:0.13, alpha:1.0).cgColor
        credControlStack.isHidden = true
        
        // Tags Collection View
        let layout = NSCollectionViewFlowLayout()
        layout.minimumLineSpacing = 4
        layout.sectionHeadersPinToVisibleBounds = true
        tagsCollectionView.collectionViewLayout = layout
        tagsCollectionView.isSelectable = true
        tagsCollectionView.register(TagCell.self, forItemWithIdentifier: .init(tagsCellID))
        tagsCollectionView.allowsMultipleSelection = false
        
        // Tag Controls
        addTagButton = NSButton(image: .init(imageLiteralResourceName: "NSAddTemplate"), target: self, action: #selector(addNewTag))
//        removeTagButton = NSButton(image: .init(imageLiteralResourceName: "NSRemoveTemplate"), target: self, action: nil)
        tagsLabel.stringValue = "Tags"
        tagsLabel.font = .systemFont(ofSize: 17)
        tagsLabel.isBezeled = false
        tagsLabel.backgroundColor = .clear
        tagsLabel.isSelectable = false

        tagControlStack = NSStackView(views: [addTagButton, tagsLabel])
//        tagControlStack = NSStackView(views: [addTagButton, removeTagButton, tagsLabel])
        tagControlStack.alignment = .leading
        tagControlStack.spacing = 3
        tagControlStack.orientation = .horizontal
        tagControlStack.edgeInsets = NSEdgeInsets(top: 3, left: 5, bottom: 0, right: 5)
        tagControlStack.wantsLayer = true
        tagControlStack.layer?.backgroundColor = NSColor(red:0.16, green:0.15, blue:0.13, alpha:1.0).cgColor
        
        // Control Buttons
        editButton = NSButton(title: "Edit", target: self, action: #selector(handleEditMode))
        saveButton = NSButton(title: "Save", target: self, action: #selector(saveChanges))
        cancelButton = NSButton(title: "Cancel", target: self, action: #selector(cancelChanges))
    }
    
    func setupConstraints(){
        view.addSubview(SPImage)
        view.addSubview(SPName)
        view.addSubview(tableScrollView)
        view.addSubview(credControlStack)
        view.addSubview(editButton)
        view.addSubview(tagControlStack)
        view.addSubview(tagsScrollView)
        view.addSubview(saveButton)
        view.addSubview(cancelButton)
        
        SPImage.anchor(top: view.topAnchor, left: view.leadingAnchor, paddingTop: 5, paddingLeft: 20, height: 40, width: 40)
        SPName.anchor(left: SPImage.trailingAnchor, right: view.trailingAnchor, paddingLeft: 20, paddingRight: 20)
        SPName.centerY(SPImage.centerYAnchor)
        
        tableScrollView.anchor(top: SPImage.bottomAnchor, left: view.leadingAnchor, right: view.trailingAnchor, paddingTop: 20, paddingLeft: 10, paddingRight: 5, height: 240)
        
        
        credControlStack.anchor(top: tableScrollView.bottomAnchor, right: tableScrollView.trailingAnchor)
        addCredButton.anchor(height: 24, width: 24)
        removeCredButton.anchor(height: 24, width: 24)
        addCredButton.bottomAnchor.constraint(equalTo: credControlStack.bottomAnchor, constant: -5).isActive = true
        removeCredButton.bottomAnchor.constraint(equalTo: credControlStack.bottomAnchor, constant: -5).isActive = true
        
        addTagButton.anchor(height: 24, width: 24)
//        removeTagButton.anchor(height: 24, width: 24)
        
        tagControlStack.anchor(top: tableScrollView.bottomAnchor, left: view.leadingAnchor, right: cancelButton.leadingAnchor, paddingTop: 10, paddingLeft: 10, paddingRight: 10, height: 28)
        
        tagsScrollView.anchor(top: tagControlStack.bottomAnchor, bottom: view.bottomAnchor, left: view.leadingAnchor, right: cancelButton.leadingAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 10, paddingRight: 10)
        
        editButton.anchor(top: tableScrollView.bottomAnchor, right: view.trailingAnchor, paddingTop: 8, paddingRight: 0, height: 30)
        saveButton.anchor(bottom: view.bottomAnchor, right: view.trailingAnchor, paddingBottom: 0, paddingRight: 0, height: 30)
        cancelButton.anchor(bottom: saveButton.topAnchor, right: view.trailingAnchor, paddingBottom: 0, paddingRight: 0, height: 30)
        saveButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor, multiplier: 1).isActive = true
        editButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor, multiplier: 1).isActive = true
    }
}
