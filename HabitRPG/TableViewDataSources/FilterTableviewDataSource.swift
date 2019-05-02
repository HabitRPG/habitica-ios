//
//  FilterTableviewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

@objc
protocol FilterTableViewDataSourceProtocol {
    @objc var tableView: UITableView? { get set }
    @objc var selectedTagIds: [String] { get set }
    @objc
    func tagAt(indexPath: IndexPath) -> TagProtocol?
    @objc
    func selectTag(at indexPath: IndexPath)
    @objc
    func clearTags()
    @objc
    func createTag(text: String)
    @objc
    func updateTag(id: String, text: String)
    @objc
    func deleteTag(at indexPath: IndexPath)
    @objc(numberOfSectionsInTableView:)
    func numberOfSections(in tableView: UITableView) -> Int
    @objc
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    @objc(tableView:cellForRowAtIndexPath:)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
}

@objc
class FilterTableViewDataSourceInstantiator: NSObject {
    
    @objc
    static func instantiate() -> FilterTableViewDataSourceProtocol {
        return FilterTableViewDataSource()
    }
}

class FilterTableViewDataSource: BaseReactiveTableViewDataSource<TagProtocol>, FilterTableViewDataSourceProtocol, UITableViewDelegate {
    
    private let userRepository = UserRepository()
    private let taskRepository = TaskRepository()
    
    @objc var selectedTagIds = [String]()
    
    override func didSetTableView() {
        tableView?.reloadData()
    }
    
    func tagAt(indexPath: IndexPath) -> TagProtocol? {
        return item(at: indexPath)
    }
    
    override init() {
        super.init()
        self.sections.append(ItemSection<TagProtocol>())
        disposable.inner.add(userRepository.getTags().on(value: {[weak self](tags, changes) in
            self?.sections[0].items = tags
            self?.notify(changes: changes)
        }).start())
    }
    
    @objc(tableView:cellForRowAtIndexPath:)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let tag = item(at: indexPath) {
            let label = cell.viewWithTag(1) as? UILabel
            label?.text = tag.text
            
            let checkboxView = cell.viewWithTag(2) as? CheckboxView
            checkboxView?.boxCornerRadius = (checkboxView?.size ?? 0) / 2
            checkboxView?.isUserInteractionEnabled = false
            checkboxView?.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
            if selectedTagIds.contains(tag.id ?? "") {
                checkboxView?.checkColor = UIColor(white: 1, alpha: 0.7)
                checkboxView?.boxBorderColor = ThemeService.shared.theme.backgroundTintColor
                checkboxView?.boxFillColor = ThemeService.shared.theme.backgroundTintColor
            } else {
                checkboxView?.checkColor = .clear
                checkboxView?.boxBorderColor = ThemeService.shared.theme.backgroundTintColor
                checkboxView?.boxFillColor = .clear
            }
            checkboxView?.checked = selectedTagIds.contains(tag.id ?? "")
            checkboxView?.layer.setNeedsDisplay()
        }
        return cell
    }
    
    func selectTag(at indexPath: IndexPath) {
        if let tag = item(at: indexPath), let tagID = tag.id {
            if let index = selectedTagIds.firstIndex(of: tagID) {
                selectedTagIds.remove(at: index)
            } else {
                selectedTagIds.append(tagID)
            }
        }
        self.tableView?.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func clearTags() {
        selectedTagIds.removeAll()
        tableView?.reloadData()
    }
    
    func deleteTag(at indexPath: IndexPath) {
        if let tag = item(at: indexPath) {
            taskRepository.deleteTag(tag).observeCompleted {}
        }
    }
    
    func createTag(text: String) {
        let tag = taskRepository.getNewTag()
        tag.text = text
        taskRepository.createTag(tag).observeCompleted {}
    }
    
    func updateTag(id: String, text: String) {
        if let tag = taskRepository.getEditableTag(id: id) {
            tag.text = text
            taskRepository.updateTag(tag).observeCompleted {}
        }
    }
}
