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
    @Published var isSaving = false
    
    var onDismiss: (() -> Void)?
    
    override init() {
        super.init()
        disposable.add(taskRepository.getTags().on(value: { tags in
            self.tags = tags.value.compactMap({[weak self] tag in
                return self?.taskRepository.getEditableTag(id: tag.id ?? "")
            })
        }).start())
    }
    
    var taskType: String = "" {
        didSet {
            let defaults = UserDefaults.standard
            selectedFilterType = defaults.integer(forKey: "\(taskType)Filter")
        }
    }
    
    func dismiss() {
        if let action = onDismiss {
            action()
        }
    }
    
    func isSelected(tag: TagProtocol) -> Bool {
        return selectedTags.contains(where: { id in
            return id == tag.id
        })
    }
    
    func tagTapped(tag: TagProtocol) {
        withAnimation(.interactiveSpring(duration: 0.2)) {
            if isSelected(tag: tag) {
                selectedTags.removeAll { id in
                    return id == tag.id
                }
            } else if let id = tag.id {
                selectedTags.append(id)
            }
            selectedTags = selectedTags
        }
    }
    
    func clearFilters() {
        withAnimation {
            selectedFilterType = 0
            selectedTags = []
        }
    }
    
    func beginEditing() {
        var newEditedTags = [TagProtocol]()
        tags.forEach { tag in
            if let editable = taskRepository.getEditableTag(id: tag.id ?? "") {
                newEditedTags.append(editable)
            }
        }
        withAnimation(.bouncy) {
            editedTags = newEditedTags
            isEditing = true
        }
    }
    
    func cancelEditing() {
        withAnimation(.interactiveSpring) {
            isEditing = false
        }
    }
    
    func save() {
        if isSaving {
            return
        }
        isSaving = true
        let tagsToDelete = tags.filter { tag in
            return !editedTags.contains { editedTag in
                return editedTag.id == tag.id
            }
        }
        let tagsToCreate = editedTags.filter { editedTag in
            if editedTag.id?.isEmpty != false {
                return true
            }
            return !tags.contains { tag in
                return editedTag.id == tag.id
            }
        }
        let tagsToUpdate = editedTags.filter { editedTag in
            let original = tags.first { tag in
                return editedTag.id == tag.id
            }
            return original?.text != editedTag.text
        }
        for tag in tagsToDelete {
            deleteTag(tag: tag)
        }
        for tag in tagsToCreate {
            if let text = tag.text {
                createTag(text: text)
            }
        }
        for tag in tagsToUpdate {
            if let id = tag.id, let text = tag.text {
                updateTag(id: id, text: text)
            }
        }
        withAnimation {
            isEditing = false
            isSaving = false
        }
    }
    
    func getNewTag() -> TagProtocol {
        return taskRepository.getNewTag()
    }
    
    func deleteTag(tag: TagProtocol) {
        if isEditing && !isSaving {
            withAnimation {
                editedTags.removeAll { removingTag in
                    return removingTag.id == tag.id
                }
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
    @State var isFirstResponder = false
        
    init(tag: TagProtocol, focusItemId: String?) {
        self.tag = tag
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
                    ForEach((viewModel.isEditing ? viewModel.editedTags : viewModel.tags), id: \.id) { tag in
                        let isSelected = viewModel.isSelected(tag: tag)
                        HStack(spacing: 18) {
                            if viewModel.isEditing {
                                Button {
                                    viewModel.deleteTag(tag: tag)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .scaledFont(size: 20)
                                        .foregroundStyle(Color(ThemeService.shared.theme.errorColor))
                                }
                                .frame(width: 22, height: 22)
                                .transition(.asymmetric(insertion: .push(from: .leading), removal: .push(from: .trailing)))
                                TagFormItemView(tag: tag, focusItemId: focusItemId)
                            } else {
                                Text(tag.text ?? "")
                                    .scaledFont(size: 17, weight: isSelected ? .semibold : .regular)
                                    .foregroundStyle(Color(isSelected ? ThemeService.shared.theme.tintedMainText : ThemeService.shared.theme.primaryTextColor))
                                Spacer()
                            }
                            if isSelected && !viewModel.isEditing {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color(ThemeService.shared.theme.tintColor))
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .animation(.spring, value: viewModel.isEditing)
                        .contentShape(Rectangle())
                        .listRowBackground(Color(ThemeService.shared.theme.windowBackgroundColor))
                            .onTapGesture {
                                viewModel.tagTapped(tag: tag)
                            }
                    }.onDelete { set in
                        for item in set {
                            viewModel.deleteTag(at: item)
                        }
                    }.listRowBackground(Color(ThemeService.shared.theme.windowBackgroundColor))
                    if viewModel.isEditing {
                        HStack(spacing: 18) {
                            Image(systemName: "minus.circle.fill")
                                .scaledFont(size: 20)
                                .foregroundStyle(Color(ThemeService.shared.theme.errorColor))
                            Button(action: {
                                let tag = viewModel.getNewTag()
                                tag.id = UUID().uuidString
                                withAnimation {
                                    viewModel.editedTags.append(tag)
                                }
                                focusItemId = tag.id
                            }, label: {
                                Text(L10n.addTag).underline(UIAccessibility.buttonShapesEnabled)
                                    .foregroundStyle(Color(ThemeService.shared.theme.ternaryTextColor))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            })
                        }.listRowBackground(Color(ThemeService.shared.theme.windowBackgroundColor))
                    }
                }
                
                if viewModel.isSaving {
                    HabiticaProgressView().frame(height: 60)
                } else if viewModel.isEditing {
                    Button {
                        viewModel.save()
                    } label: {
                        Text(L10n.save)
                            .frame(maxWidth: .infinity)
                    }.listRowBackground(Color(ThemeService.shared.theme.windowBackgroundColor))
                } else {
                    Button {
                        viewModel.beginEditing()
                    } label: {
                        Text(L10n.editTags)
                            .frame(maxWidth: .infinity)
                    }.listRowBackground(Color(ThemeService.shared.theme.windowBackgroundColor))
                }
            }.listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
        }
        .toolbar {
            if viewModel.isEditing {
                ToolbarItem(placement: .topBarLeading) {
                    if #available(iOS 26.0, *) {
                        Button(role: .cancel) {
                            viewModel.cancelEditing()
                        }.disabled(viewModel.isSaving)
                    } else {
                        Button {
                            viewModel.cancelEditing()
                        } label: {
                            Text(L10n.cancel)
                        }.disabled(viewModel.isSaving)
                    }
                }
            } else {
                ToolbarItem(placement: .topBarLeading) {
                    if #available(iOS 26.0, *) {
                        Button {
                            viewModel.clearFilters()
                        } label: {
                            Text(L10n.clear).foregroundStyle(Color.red100)
                        }.buttonStyle(.glassProminent)
                            .tint(.red100.opacity(0.14))
                    } else {
                        Button {
                            viewModel.clearFilters()
                        } label: {
                            Text(L10n.clear)
                        }.buttonStyle(.borderedProminent)
                            .tint(.red100)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if #available(iOS 26.0, *) {
                        Button(role: .confirm) {
                            viewModel.dismiss()
                        }.buttonStyle(.glassProminent)
                    } else {
                        Button {
                            viewModel.dismiss()
                        } label: {
                            Text(L10n.done)
                        }
                    }
                }
            }
        }
    }
}

class FilterViewController: BaseHostingViewController<TaskFilterPage> {
    let viewModel = TaskFilterViewModel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: TaskFilterPage(viewModel: viewModel))
        viewModel.onDismiss = {
            self.perform(segue: StoryboardSegue.Main.filterChangedSegue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = L10n.filter
    }
}
