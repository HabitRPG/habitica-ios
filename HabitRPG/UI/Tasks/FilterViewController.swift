//
//  FilterViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 03.09.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import UIKit
import SwiftUI
import Habitica_Models

class TaskFilterViewModel: ViewModel {
    private let taskRepository = TaskRepository()
    @Published var tags = [TagProtocol]()
    @Published var editedTags = [TagProtocol]()
    @Published var selectedTags = [String]()
    @Published var selectedFilterType = 0 {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(selectedFilterType, forKey: "\(taskType)Filter")
            NotificationCenter.default.post(name: Notification.Name("taskFilterChanged"), object: nil)
        }
    }
    
    @Published var isEditing = false
    
    var taskType: String = "" {
        didSet {
            let defaults = UserDefaults.standard
            selectedFilterType = defaults.integer(forKey: "\(taskType)Filter")
        }
    }
    
    func clearFilters() {
        selectedFilterType = 0
        selectedTags = []
    }
    
    func beginEditing() {
        editedTags = []
        tags.forEach { tag in
            if let editable = taskRepository.getEditableTag(id: tag.id ?? "") {
                editedTags.append(editable)
            }
        }
        isEditing = true
    }
    
    func cancelEditing() {
        isEditing = false
    }
    
    func save() {
        isEditing = false
    }
    
    func getNewTag() -> TagProtocol {
        return taskRepository.getNewTag()
    }
    
    func deleteTag(tag: TagProtocol) {
        if isEditing {
            editedTags.removeAll { removingTag in
                return removingTag.id == tag.id
            }
        } else {
            taskRepository.deleteTag(tag).observeCompleted {}
        }
    }
    
    func deleteTag(at index: Int) {
        if index < tags.count {
            deleteTag(tag: tags[index])
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

struct TagFormItemView: View {
    let tag: TagProtocol
    let onDelete: () -> Void
    @State var isFirstResponder = false
        
    init(tag: TagProtocol, onDelete: @escaping () -> Void, focusItemId: String?) {
        self.tag = tag
        self.onDelete = onDelete
        _isFirstResponder = State(initialValue: (tag.id == focusItemId))
    }

    private var text: Binding<String> {
        Binding<String>(get: { self.tag.text ?? "" }, set: {
            if !self.tag.isManaged {
                self.tag.text = $0
            }
        })
    }
    var body: some View {
        FocusableTextField(placeholder: "", text: text, isFirstResponder: $isFirstResponder)
    }
}

struct TaskFilterPage: View {
    @ObservedObject var viewModel: TaskFilterViewModel
    @State var focusItemId: String?

    var body: some View {
        VStack {
            VStack {
                Picker(selection: $viewModel.selectedFilterType) {
                    if viewModel.taskType == "habit" {
                        Text(L10n.all).tag(0)
                        Text(L10n.weak).tag(1)
                        Text(L10n.strong).tag(2)
                    } else if viewModel.taskType == "daily" {
                        Text(L10n.all).tag(0)
                        Text(L10n.due).tag(1)
                        Text(L10n.notDue).tag(2)
                    } else if viewModel.taskType == "todo" {
                        Text(L10n.active).tag(0)
                        Text(L10n.scheduled).tag(1)
                        Text(L10n.completed).tag(2)
                    }
                }.pickerStyle(.segmented)
            }.padding(.horizontal, 16)
            List {
                Section(L10n.tags) {
                    if viewModel.isEditing {
                        ForEach(viewModel.editedTags, id: \.id) { tag in
                            HStack(spacing: 18) {
                                Button {
                                    viewModel.deleteTag(tag: tag)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .scaledFont(size: 20)
                                        .foregroundStyle(Color(ThemeService.shared.theme.errorColor))
                                }
                                TagFormItemView(tag: tag, onDelete: {
                                    viewModel.deleteTag(tag: tag)
                                }, focusItemId: focusItemId)
                                .background(Color(ThemeService.shared.theme.windowBackgroundColor))
                            }
                        }.listRowBackground(Color(ThemeService.shared.theme.windowBackgroundColor))
                        HStack(spacing: 18) {
                            Image(systemName: "minus.circle.fill")
                                .scaledFont(size: 20)
                                .foregroundStyle(Color(ThemeService.shared.theme.errorColor))
                            Button(action: {
                                let tag = viewModel.getNewTag()
                                tag.id = UUID().uuidString
                                viewModel.editedTags.append(tag)
                                focusItemId = tag.id
                            }, label: {
                                Text(L10n.addTag).underline(UIAccessibility.buttonShapesEnabled)
                                    .foregroundStyle(Color(ThemeService.shared.theme.ternaryTextColor))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            })
                        }.listRowBackground(Color(ThemeService.shared.theme.windowBackgroundColor))
                    } else {
                        ForEach(viewModel.tags, id: \.id) { tag in
                            HStack {
                                Text(tag.text ?? "")
                                Spacer()
                                if viewModel.selectedTags.contains(where: { id in
                                    return id == tag.id
                                }) {
                                    Image(systemName: "check")
                                        .foregroundStyle(Color(ThemeService.shared.theme.tintColor))
                                }
                            }.listRowBackground(Color(ThemeService.shared.theme.windowBackgroundColor))
                        }.onDelete { set in
                            for item in set {
                                viewModel.deleteTag(at: item)
                            }
                        }.listRowBackground(Color(ThemeService.shared.theme.windowBackgroundColor))
                    }
                }
                
                if viewModel.isEditing {
                    Button {
                        viewModel.isEditing = false
                    } label: {
                        Text(L10n.save)
                            .frame(maxWidth: .infinity)
                    }.listRowBackground(Color(ThemeService.shared.theme.windowBackgroundColor))
                } else {
                    Button {
                        viewModel.isEditing = true
                    } label: {
                        Text(L10n.editTags)
                            .frame(maxWidth: .infinity)
                    }.listRowBackground(Color(ThemeService.shared.theme.windowBackgroundColor))
                }
            }.listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
        }
    }
}

class FilterViewController: BaseHostingViewController<TaskFilterPage> {
    let viewModel = TaskFilterViewModel()
    
    @IBOutlet var clearButton: UIBarButtonItem!
    @IBOutlet weak var doneNavbarButton: UIBarButtonItem!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: TaskFilterPage(viewModel: viewModel))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = L10n.filter
        self.clearButton.title = L10n.clear
        self.doneNavbarButton.title = L10n.done
        self.clearButton.tintColor = ThemeService.shared.theme.errorColor
    }
    
    @IBAction func clearTags(_ sender: UIBarButtonItem) {
        viewModel.clearFilters()
    }
}
