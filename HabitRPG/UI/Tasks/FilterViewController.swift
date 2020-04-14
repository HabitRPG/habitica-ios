//
//  FilterViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 03.09.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class FilterViewController: BaseTableViewController {
    
    var selectedTags = [String]()
    var taskType: String?
    
    private let dataSource = FilterTableViewDataSource()
    
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var clearButton: UIBarButtonItem!
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var toolBarSpace: UIBarButtonItem!
    
    private let headerView = UIView()
    private var filterTypeControl = UISegmentedControl()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = L10n.filter
        self.clearButton.title = L10n.clear
        
        dataSource.tableView = tableView
        dataSource.selectedTagIds = selectedTags
                
        if taskType == "habit" {
            filterTypeControl = UISegmentedControl(items: [L10n.all, L10n.weak, L10n.strong])
        } else if taskType == "daily" {
            filterTypeControl = UISegmentedControl(items: [L10n.all, L10n.due, L10n.grey])
        } else if taskType == "todo" {
            filterTypeControl = UISegmentedControl(items: [L10n.active, L10n.dated, L10n.done])
        }
        let defaults = UserDefaults.standard
        filterTypeControl.selectedSegmentIndex = defaults.integer(forKey: "\(taskType ?? "")Filter")
        
        filterTypeControl.addTarget(self, action: #selector(filterTypeChanged), for: .valueChanged)
        headerView.addSubview(filterTypeControl)
        tableView.tableHeaderView = headerView
        
        doneButtonTapped(doneButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 46)
        filterTypeControl.frame = CGRect(x: 8, y: headerView.frame.size.height - 30, width: headerView.frame.size.width - 16, height: 30)
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        tableView.backgroundColor = theme.contentBackgroundColor
        navigationController?.navigationBar.barTintColor = theme.contentBackgroundColor
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: theme.primaryTextColor
        ]
        navigationController?.navigationBar.tintColor = theme.tintColor
        navigationController?.toolbar?.barTintColor = theme.contentBackgroundColor
        navigationController?.toolbar?.tintColor = theme.tintColor
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            let tag = dataSource.tagAt(indexPath: indexPath)
            showFormAlertFor(tag: tag)
        } else {
            dataSource.selectTag(at: indexPath)
        }
    }
    
    @IBAction func clearTags(_ sender: UIBarButtonItem) {
	    resetFilterTypeControl()
        dataSource.clearTags()
    }

	private func resetFilterTypeControl() {
	    filterTypeControl.selectedSegmentIndex = 0
	}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        selectedTags = dataSource.selectedTagIds
    }
    
    @objc
    private func filterTypeChanged() {
        let defaults = UserDefaults.standard
        defaults.set(filterTypeControl.selectedSegmentIndex, forKey: "\(taskType ?? "")Filter")
        NotificationCenter.default.post(name: Notification.Name("taskFilterChanged"), object: nil)
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        setEditing(true, animated: true)
        toolbarItems = [doneButton]
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        setEditing(false, animated: true)
        toolbarItems = [editButton, toolBarSpace, clearButton]
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        showFormAlert()
    }
    
    private func showFormAlert() {
        showFormAlertFor(tag: nil)
    }
    
    private func showFormAlertFor(tag: TagProtocol?) {
        var title: String?
        if tag != nil {
            title = L10n.editTag
        } else {
            title = L10n.createTag
        }
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.cancelAction())
        alertController.addAction(UIAlertAction(title: L10n.save, style: .default, handler: { (_) in
            let textField = alertController.textFields?[0]
            let newTagName = textField?.text ?? ""
            if tag != nil {
                self.dataSource.updateTag(id: tag?.id ?? "", text: newTagName)
            } else {
                self.dataSource.createTag(text: newTagName)
            }
        }))
        
        alertController.addTextField { (textField) in
            if tag != nil {
                textField.text = tag?.text
            }
        }
        present(alertController, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections(in: tableView)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return dataSource.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dataSource.deleteTag(at: indexPath)
        }
    }
}
