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
        .transition(.opacity)
    }
}

private struct ChecklistDrag {
    var itemID: String
    var startSlot: Int
    var translation: CGFloat
}

private struct ChecklistRowHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct TaskFormChecklistView: View {
    @ObservedObject var themeService = ThemeService.shared
    private let taskRepository = TaskRepository()
    @Binding var items: [ChecklistItemProtocol]
    @State var focusItemId: String?

    private static let rowSpacing: CGFloat = 8
    @State private var rowHeight: CGFloat = 48
    @GestureState private var drag: ChecklistDrag?

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

    private var rowStride: CGFloat {
        return rowHeight + TaskFormChecklistView.rowSpacing
    }

    private func targetSlot(count: Int) -> Int? {
        guard let drag = drag else {
            return nil
        }
        let delta = Int((drag.translation / rowStride).rounded())
        return min(max(drag.startSlot + delta, 0), count - 1)
    }

    private func rowOffset(slot: Int, itemID: String?, count: Int) -> CGFloat {
        guard let drag = drag else {
            return 0
        }
        if drag.itemID == itemID {
            let minOffset = -CGFloat(drag.startSlot) * rowStride
            let maxOffset = CGFloat(count - 1 - drag.startSlot) * rowStride
            return min(max(drag.translation, minOffset), maxOffset)
        }
        guard let target = targetSlot(count: count) else {
            return 0
        }
        if drag.startSlot < target && slot > drag.startSlot && slot <= target {
            return -rowStride
        }
        if drag.startSlot > target && slot < drag.startSlot && slot >= target {
            return rowStride
        }
        return 0
    }

    private func moveItem(fromSlot: Int, toSlot: Int, visibleItems: [ChecklistItemProtocol]) {
        guard fromSlot != toSlot,
              visibleItems.indices.contains(fromSlot),
              visibleItems.indices.contains(toSlot),
              let from = items.firstIndex(where: { $0.id == visibleItems[fromSlot].id }),
              let to = items.firstIndex(where: { $0.id == visibleItems[toSlot].id }) else {
            return
        }
        withAnimation(.bouncy) {
            items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
        }
    }

    private func dragGesture(for item: ChecklistItemProtocol, slot: Int) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .updating($drag) { value, state, _ in
                if state == nil {
                    state = ChecklistDrag(itemID: item.id ?? "", startSlot: slot, translation: 0)
                }
                state?.translation = value.translation.height
            }
            .onEnded { value in
                let visible = items.filter { $0.isValid }
                guard let currentSlot = visible.firstIndex(where: { $0.id == item.id }) else {
                    return
                }
                let delta = Int((value.translation.height / rowStride).rounded())
                let target = min(max(currentSlot + delta, 0), visible.count - 1)
                moveItem(fromSlot: currentSlot, toSlot: target, visibleItems: visible)
            }
    }

    var body: some View {
        let visibleItems = items.filter { $0.isValid }
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Tasks.Form.checklist.localizedCapitalized).font(.system(size: 13, weight: .semibold)).foregroundStyle(Color(themeService.theme.quadTextColor)).padding(.leading, 14)
            LazyVStack(spacing: TaskFormChecklistView.rowSpacing) {
                ForEach(Array(visibleItems.enumerated()), id: \.element.id) { slot, item in
                    TaskFormChecklistItemView(item: item, onDelete: {
                        withAnimation {
                            if let index = items.firstIndex(where: { $0.id == item.id }) {
                                items.remove(at: index)
                            }
                        }
                    }, onNewItem: {
                        addNewItem()
                    }, focusItemId: focusItemId)
                    .background(GeometryReader { geometry in
                        Color.clear.preference(key: ChecklistRowHeightKey.self, value: geometry.size.height)
                    })
                    .overlay(alignment: .trailing) {
                        Color.clear
                            .frame(width: 34)
                            .frame(maxHeight: .infinity)
                            .contentShape(Rectangle())
                            .gesture(dragGesture(for: item, slot: slot))
                    }
                    .offset(y: rowOffset(slot: slot, itemID: item.id, count: visibleItems.count))
                    .zIndex(drag?.itemID == item.id ? 10 : 0)
                    .shadow(color: .black.opacity(drag?.itemID == item.id ? 0.15 : 0), radius: 8, y: 2)
                    .animation(.bouncy, value: targetSlot(count: visibleItems.count))
                }
                addButton
            }
            .onPreferenceChange(ChecklistRowHeightKey.self) { height in
                if height > 0 {
                    rowHeight = height
                }
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
