//
//  FilterViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 03.09.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import UIKit
import SwiftUI
import ReactiveSwift
import Habitica_Models

class TaskFilterViewModel: ViewModel {
    private let taskRepository = TaskRepository()
    @Published var tags = [TagProtocol]()
    @Published var editedTags = [TagProtocol]()
    @Published var deletedTags: [(TagProtocol, Int)] = []
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

    private var originalTags = [TagProtocol]()
    
    var onDismiss: (() -> Void)?
    
    var hasActiveFilters: Bool {
        return selectedFilterType != 0 || !selectedTags.isEmpty
    }
    
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
        var newOriginalTags = [TagProtocol]()
        tags.forEach { tag in
            if let editable = taskRepository.getEditableTag(id: tag.id ?? ""),
               let original = taskRepository.getEditableTag(id: tag.id ?? "") {
                newEditedTags.append(editable)
                newOriginalTags.append(original)
            }
        }
        originalTags = newOriginalTags
        withAnimation(.bouncy) {
            editedTags = newEditedTags
            isEditing = true
        }
    }
    
    func cancelEditing() {
        withAnimation(.interactiveSpring) {
            isEditing = false
            deletedTags = []
        }
    }
    
    func save() {
        if isSaving {
            return
        }
        isSaving = true
        deletedTags = []
        let tagsToDelete = originalTags.filter { tag in
            return !editedTags.contains { editedTag in
                return editedTag.id == tag.id
            }
        }
        let tagsToCreate = editedTags.filter { editedTag in
            if editedTag.id?.isEmpty != false {
                return true
            }
            return !originalTags.contains { tag in
                return editedTag.id == tag.id
            }
        }
        let tagsToUpdate = editedTags.filter { editedTag in
            guard editedTag.text?.isEmpty == false,
                  let original = originalTags.first(where: { tag in
                return editedTag.id == tag.id
            }) else {
                return false
            }
            return original.text != editedTag.text
        }
        var operations = [SignalProducer<Void, Never>]()
        for tag in tagsToDelete {
            operations.append(serialTagOperation { [weak self] in
                self?.taskRepository.deleteTag(tag).map { _ in () }
            })
        }
        var nextOrder = (tags.map { $0.order }.max() ?? -1) + 1
        for tag in tagsToCreate where tag.text?.isEmpty == false {
            tag.order = nextOrder
            nextOrder += 1
            operations.append(serialTagOperation { [weak self] in
                guard let self = self else { return nil }
                let newTag = self.taskRepository.getNewTag(id: tag.id)
                newTag.text = tag.text
                newTag.order = tag.order
                return self.taskRepository.createTag(newTag).map { _ in () }
            })
        }
        for tag in tagsToUpdate {
            if let id = tag.id, let text = tag.text {
                operations.append(serialTagOperation { [weak self] in
                    guard let self = self, let updated = self.taskRepository.getEditableTag(id: id) else {
                        return nil
                    }
                    updated.text = text
                    return self.taskRepository.updateTag(updated).map { _ in () }
                })
            }
        }
        let finish = { [weak self] in
            guard let self = self else { return }
            withAnimation {
                self.tags = self.editedTags.compactMap { tag in
                    if tag.text?.isEmpty == false {
                        return tag
                    }
                    return self.originalTags.first { $0.id == tag.id }
                }
                self.isEditing = false
                self.isSaving = false
            }
        }
        if operations.isEmpty {
            finish()
            return
        }
        disposable.add(SignalProducer(operations)
            .flatten(.concat)
            .observe(on: QueueScheduler.main)
            .startWithCompleted {
                finish()
            })
    }

    private func serialTagOperation(_ makeSignal: @escaping () -> Signal<Void, Never>?) -> SignalProducer<Void, Never> {
        return SignalProducer { observer, lifetime in
            guard let signal = makeSignal() else {
                observer.sendCompleted()
                return
            }
            let operationDisposable = signal.observeCompleted {
                observer.sendCompleted()
            }
            lifetime.observeEnded {
                operationDisposable?.dispose()
            }
        }
    }
    
    func getNewTag() -> TagProtocol {
        return taskRepository.getNewTag()
    }
    
    func undoDelete() {
        guard let (tag, index) = deletedTags.popLast() else {
            return
        }
        withAnimation {
            editedTags.insert(tag, at: index)
        }
    }
    
    func deleteTag(tag: TagProtocol) {
        if isEditing && !isSaving {
            withAnimation {
                let index: Int = editedTags.firstIndex { removingTag in
                    return removingTag.id == tag.id
                } ?? -1
                if index >= 0 {
                    editedTags.remove(at: index)
                    deletedTags.append((tag, index))
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
    @ObservedObject var themeService = ThemeService.shared
    @ObservedObject var viewModel: TaskFilterViewModel
    @State var focusItemId: String?

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                Group {
                    if viewModel.taskType == "habit" {
                        Text(L10n.taskHealth)
                    } else {
                        Text(L10n.taskStatus)
                    }
                }.foregroundStyle(Color(themeService.theme.secondaryTextColor))
                    .scaledFont(size: 15, weight: .semibold)
                    .padding(.leading, 16)
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
                Section(content: {
                    ForEach((viewModel.isEditing ? viewModel.editedTags : viewModel.tags), id: \.id) { tag in
                        let isSelected = viewModel.isSelected(tag: tag)
                        HStack(spacing: 18) {
                            if viewModel.isEditing {
                                Button {
                                    viewModel.deleteTag(tag: tag)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .scaledFont(size: 20)
                                        .foregroundStyle(Color(themeService.theme.errorColor))
                                }
                                .contentShape(Rectangle())
                                .frame(width: 24, height: 22)
                                .transition(.asymmetric(insertion: .push(from: .leading), removal: .push(from: .trailing)))
                                TagFormItemView(tag: tag, focusItemId: focusItemId)
                            } else {
                                Text(tag.text ?? "")
                                    .scaledFont(size: 17, weight: isSelected ? .semibold : .regular)
                                    .foregroundStyle(Color(isSelected ? themeService.theme.tintedMainText : themeService.theme.primaryTextColor))
                                Spacer()
                            }
                            if isSelected && !viewModel.isEditing {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color(themeService.theme.tintColor))
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .animation(.spring, value: viewModel.isEditing)
                        .contentShape(Rectangle())
                        .listRowBackground(Color(themeService.theme.windowBackgroundColor))
                        .onTapGesture(disabled: viewModel.isEditing, perform: {
                            viewModel.tagTapped(tag: tag)
                        })
                    }.onDelete { set in
                        for item in set {
                            viewModel.deleteTag(at: item)
                        }
                    }.listRowBackground(Color(themeService.theme.windowBackgroundColor))
                    if viewModel.isEditing {
                        HStack(spacing: 18) {
                            Image(systemName: "minus.circle.fill")
                                .scaledFont(size: 20)
                                .foregroundStyle(Color(themeService.theme.errorColor))
                            Button(action: {
                                let tag = viewModel.getNewTag()
                                tag.id = UUID().uuidString
                                withAnimation {
                                    viewModel.editedTags.append(tag)
                                }
                                focusItemId = tag.id
                            }, label: {
                                Text(L10n.addTag).underline(UIAccessibility.buttonShapesEnabled)
                                    .foregroundStyle(Color(themeService.theme.ternaryTextColor))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            })
                        }.listRowBackground(Color(themeService.theme.windowBackgroundColor))
                    }
                }, header: {
                    Text(L10n.tags).foregroundStyle(Color(themeService.theme.secondaryTextColor))
                        .scaledFont(size: 15, weight: .semibold)
                })

                Group {
                    if viewModel.isSaving {
                        HabiticaProgressView().frame(height: 60)
                    } else if viewModel.isEditing {
                        Button {
                            focusItemId = nil
                            viewModel.save()
                        } label: {
                            Text(L10n.save)
                                .frame(maxWidth: .infinity)
                        }.listRowBackground(Color(themeService.theme.windowBackgroundColor))
                    } else {
                        Button {
                            viewModel.beginEditing()
                        } label: {
                            Text(L10n.editTags)
                                .frame(maxWidth: .infinity)
                        }.listRowBackground(Color(themeService.theme.windowBackgroundColor))
                    }
                }
            }.listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.immediately)
                .disabled(viewModel.isSaving)
        }
        .toolbar {
            if !viewModel.deletedTags.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.undoDelete()
                    } label: {
                        Text(L10n.undo)
                    }
                }
            }
            if viewModel.isEditing {
                ToolbarItem(placement: .topBarLeading) {
                    if #available(iOS 26.0, *) {
                        Button(role: .cancel) {
                            focusItemId = nil
                            viewModel.cancelEditing()
                        }.disabled(viewModel.isSaving)
                    } else {
                        Button {
                            focusItemId = nil
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
                            .opacity(viewModel.hasActiveFilters ? 1 : 0.5)
                            .disabled(!viewModel.hasActiveFilters)
                    } else {
                        Button {
                            viewModel.clearFilters()
                        } label: {
                            Text(L10n.clear)
                        }.tint(.red100)
                            .disabled(!viewModel.hasActiveFilters)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if #available(iOS 26.0, *) {
                        Button(role: .confirm) {
                            viewModel.dismiss()
                        }.buttonStyle(.glassProminent)
                            .tint(Color(themeService.theme.fixedTintColor))
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

    @objc
    private func keyboardChanged(_ notification: Notification) {
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let scrollView = findListScrollView(in: view) else {
            return
        }
        let keyboardFrame = view.convert(value.cgRectValue, from: nil)
        let overlap = max(0, view.bounds.intersection(keyboardFrame).height)
        let extra = max(0, overlap - view.safeAreaInsets.bottom)
        scrollView.contentInset.bottom = extra
        scrollView.verticalScrollIndicatorInsets.bottom = extra
    }

    @objc
    private func keyboardHidden(_ notification: Notification) {
        if let scrollView = findListScrollView(in: view) {
            scrollView.contentInset.bottom = 0
            scrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }

    @objc
    private func textFieldFocused(_ notification: Notification) {
        guard let field = notification.object as? UITextField, field.isDescendant(of: view) else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
            self?.scrollToActionsIfNearEnd(field)
        }
    }

    private func scrollToActionsIfNearEnd(_ field: UITextField) {
        guard field.isFirstResponder, let scrollView = findListScrollView(in: view) else {
            return
        }
        let fieldFrame = field.convert(field.bounds, to: scrollView)
        guard scrollView.contentSize.height - fieldFrame.maxY < 220 else {
            return
        }
        let bottomY = scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom
        let offset = CGPoint(x: 0, y: max(-scrollView.adjustedContentInset.top, bottomY))
        scrollView.setContentOffset(offset, animated: false)
    }

    private func findListScrollView(in root: UIView) -> UIScrollView? {
        for subview in root.subviews {
            if let scroll = subview as? UIScrollView {
                return scroll
            }
            if let found = findListScrollView(in: subview) {
                return found
            }
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldFocused(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
        self.navigationItem.title = L10n.filter
    }
}
