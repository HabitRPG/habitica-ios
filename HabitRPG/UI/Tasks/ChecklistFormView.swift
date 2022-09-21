//
//  ChecklistFormView.swift
//  Habitica
//
//  Created by Phillip Thelen on 20.09.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Habitica_Models

struct TaskFormChecklistItemView: View {
    var item: ChecklistItemProtocol {
        didSet {
            text = item.text ?? ""
        }
    }
    let onDelete: () -> Void
    @State var isFirstResponder = false
    
    init(item: ChecklistItemProtocol, onDelete: @escaping () -> Void, focusItemId: String?) {
        self.item = item
        self.onDelete = onDelete
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
                    .background(Circle().fill(Color.accentColor).frame(width: 21, height: 21))
                    .frame(width: 48, height: 48)
            })
            FocusableTextField(placeholder: "Enter your checklist line", text: textProxy, isFirstResponder: $isFirstResponder)
            Image(uiImage: Asset.grabIndicator.image).foregroundColor(Color(ThemeService.shared.theme.tableviewSeparatorColor))
                    .padding(.trailing, 13)
        }.background(Color(ThemeService.shared.theme.windowBackgroundColor).cornerRadius(8))
        .transition(.opacity)
    }
}

struct TaskFormChecklistView: View {
    private let taskRepository = TaskRepository()
    @Binding var items: [ChecklistItemProtocol]
    @State var focusItemId: String?
    
    var addButton: some View { Button(action: {
        let item = taskRepository.getNewChecklistItem()
            item.id = UUID().uuidString
            items.append(item)
            focusItemId = item.id
        }, label: {
            Text(L10n.Tasks.Form.newChecklistItem).font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(ThemeService.shared.theme.primaryTextColor))
                .frame(maxWidth: .infinity).frame(height: 48)
                .background(Color(ThemeService.shared.theme.windowBackgroundColor).cornerRadius(8))
        })
    }
    @State var draggedItem: ChecklistItemProtocol?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Tasks.Form.checklist.uppercased()).font(.system(size: 13, weight: .semibold)).foregroundColor(Color(ThemeService.shared.theme.quadTextColor)).padding(.leading, 14)
                LazyVStack {
                    ForEach(items, id: \.id) { item in
                        TaskFormChecklistItemView(item: item, onDelete: {
                            withAnimation {
                                if let index = items.firstIndex(where: { $0.id == item.id }) {
                                    items.remove(at: index)
                                }
                            }
                        }, focusItemId: focusItemId).onDrag({
                            self.draggedItem = item
                            return NSItemProvider(item: nil, typeIdentifier: "checklistitem")
                        }) .onDrop(of: ["checklistitem"], delegate: ChecklistDropDelegate(item: item, items: $items, draggedItem: $draggedItem))
                    }
                    .onMove { source, destination in
                        items.move(fromOffsets: source, toOffset: destination)
                    }
                    addButton
                }
        }
    }
}

struct ChecklistDropDelegate: DropDelegate {

    let item: ChecklistItemProtocol
    @Binding var items: [ChecklistItemProtocol]
    @Binding var draggedItem: ChecklistItemProtocol?

    func performDrop(info: DropInfo) -> Bool {
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
            withAnimation(.default) {
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
