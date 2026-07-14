//
//  ChecklistFormView.swift
//  Habitica
//
//  Created by Phillip Thelen on 20.09.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Habitica_Models

private final class ChecklistDragSession {
    var generation: Int = 0
}

private final class ChecklistItemProvider: NSItemProvider {
    var onCleanup: (() -> Void)?

    deinit {
        let cleanup = onCleanup
        DispatchQueue.main.async {
            cleanup?()
        }
    }
}

struct TaskFormChecklistItemView: View {
    @ObservedObject var themeService = ThemeService.shared
    var item: ChecklistItemProtocol {
        didSet {
            text = item.text ?? ""
        }
    }
    let onDelete: () -> Void
    let onNewItem: () -> Void
    @State var isFirstResponder = false
    
    init(item: ChecklistItemProtocol, onDelete: @escaping () -> Void, onNewItem: @escaping () -> Void, focusItemId: String?) {
        self.item = item
        self.onDelete = onDelete
        self.onNewItem = onNewItem
        _text = State(initialValue: item.text ?? "")
        _isFirstResponder = State(initialValue: (item.id == focusItemId))
    }
    
    @State private var text: String = ""
    private var textProxy: Binding<String> {
        Binding<String>(get: { self.text }, set: {
            self.text = $0
            if !self.item.isManaged {
                self.item.text = $0
            }
        })
    }
    var body: some View {
        HStack {
            Button(action: {
                onDelete()
            }, label: {
                Rectangle().fill(Color.white).frame(width: 9, height: 2)
                    .background(Circle().fill(.tint).frame(width: 21, height: 21))
                    .frame(width: 44, height: 44)
            }).buttonStyle { configuration in
                if UIAccessibility.buttonShapesEnabled {
                    configuration.label
                        .background(Color(themeService.theme.offsetBackgroundColor))
                        .cornerRadius(UIConstants.largeCornerRadius)
                        .padding(4)
                } else {
                    configuration.label.padding(4)
                }
            }
            FocusableTextField(placeholder: "Enter your checklist line", text: textProxy, isFirstResponder: $isFirstResponder, onReturnPressed: {
                if !text.isEmpty {
                    onNewItem()
                }
            })
            Image(uiImage: Asset.grabIndicator.image).foregroundStyle(Color(themeService.theme.tableviewSeparatorColor))
                    .padding(.trailing, 13)
        }.background(Color(themeService.theme.windowBackgroundColor).cornerRadius(UIConstants.largeCornerRadius))
            .contentShape([.dragPreview], RoundedRectangle(cornerRadius: UIConstants.largeCornerRadius))
        .transition(.opacity)
    }
}

struct TaskFormChecklistView: View {
    @ObservedObject var themeService = ThemeService.shared
    private let taskRepository = TaskRepository()
    @Binding var items: [ChecklistItemProtocol]
    @State var focusItemId: String?
    
    func addNewItem() {
        let item = taskRepository.getNewChecklistItem()
        item.id = UUID().uuidString
        if let id = focusItemId, let index = items.firstIndex(where: { item in
            return item.id == id
        }) {
            items.insert(item, at: index + 1)
        } else {
            items.append(item)
        }
        focusItemId = item.id
    }
    
    var addButton: some View { Button(action: {
            addNewItem()
        }, label: {
            Text(L10n.Tasks.Form.newChecklistItem).underline(UIAccessibility.buttonShapesEnabled)
        }).buttonStyle { configuration in
            configuration.label
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(themeService.theme.primaryTextColor))
                .frame(maxWidth: .infinity).frame(height: 48)
                .background(Color(themeService.theme.windowBackgroundColor).cornerRadius(UIConstants.largeCornerRadius))
        }
    }
    @State var draggedItem: ChecklistItemProtocol?
    @State var isDragging: Bool = false

    @State private var dragSession = ChecklistDragSession()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Tasks.Form.checklist.localizedCapitalized).font(.system(size: 13, weight: .semibold)).foregroundStyle(Color(themeService.theme.quadTextColor)).padding(.leading, 14)
            if items.first?.isValid == true {
                LazyVStack {
                    ForEach(items, id: \.id) { item in
                        TaskFormChecklistItemView(item: item, onDelete: {
                            withAnimation {
                                if let index = items.firstIndex(where: { $0.id == item.id }) {
                                    items.remove(at: index)
                                }
                            }
                        }, onNewItem: {
                            addNewItem()
                        }, focusItemId: focusItemId).onDrag({
                            let session = dragSession
                            session.generation += 1
                            let myGeneration = session.generation
                            let itemBinding = $draggedItem
                            let draggingBinding = $isDragging
                            itemBinding.wrappedValue = item
                            draggingBinding.wrappedValue = true
                            let provider = ChecklistItemProvider(item: nil, typeIdentifier: "checklistitem")
                            provider.onCleanup = {
                                guard session.generation == myGeneration else { return }
                                itemBinding.wrappedValue = nil
                                draggingBinding.wrappedValue = false
                            }
                            return provider
                        }).opacity(item.id == draggedItem?.id && isDragging ? 0 : 1)
                            .onDrop(of: ["checklistitem"], delegate: ChecklistDropDelegate(item: item, items: $items, draggedItem: $draggedItem, isDragging: $isDragging))
                    }
                    .onMove { source, destination in
                        items.move(fromOffsets: source, toOffset: destination)
                    }
                    addButton
                }
            }
        }
    }
}

struct ChecklistDropDelegate: DropDelegate {
    let item: ChecklistItemProtocol
    @Binding var items: [ChecklistItemProtocol]
    @Binding var draggedItem: ChecklistItemProtocol?
    @Binding var isDragging: Bool

    func performDrop(info: DropInfo) -> Bool {
        isDragging = false
        draggedItem = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else {
            return
        }

        if draggedItem.id != item.id {
            guard let from = items.firstIndex(where: { thisItem in
                return thisItem.id == draggedItem.id
            }) else {
                return
            }
            guard let to = items.firstIndex(where: { thisItem in
                return thisItem.id == item.id
            }) else {
                return
            }
            withAnimation(.bouncy) {
                self.items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
        }
    }
}

struct ChecklistFormPreview: PreviewProvider {
    static var item: ChecklistItemProtocol {
        let item = PreviewChecklistItem()
        item.text = "this is a long item that will overflow because it is so long"
        return item
    }
    static var previews: some View {
        TaskFormChecklistView(items: .constant([item])).padding()
    }
}
