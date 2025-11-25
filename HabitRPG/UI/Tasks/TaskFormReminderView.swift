//
//  TaskFormReminderView.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import SwiftUI
import Habitica_Models

struct TaskFormReminderView: View {
    var showDate: Bool
    private let taskRepository = TaskRepository()
    @Binding var items: [ReminderProtocol]
    
    @State private var expandedItem: ReminderProtocol?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Tasks.Form.reminders.uppercased()).font(.system(size: 13, weight: .semibold)).foregroundColor(Color(ThemeService.shared.theme.quadTextColor)).padding(.leading, 14)
            VStack(spacing: 8) {
                ForEach(items, id: \.id) { item in
                    TaskFormReminderItemView(item: item, showDate: showDate) {
                        withAnimation {
                            if let index = items.firstIndex(where: { $0.id == item.id }) {
                                items.remove(at: index)
                            }
                        }
                    }.onTapGesture {
                        withAnimation {
                            if expandedItem?.id == item.id {
                                expandedItem = nil
                            } else {
                                expandedItem = item
                            }
                        }
                    }
                }
                Button(action: {
                    let item = taskRepository.getNewReminder()
                    item.id = UUID().uuidString
                    item.time = Date()
                    items.append(item)
                }, label: {
                    Text(L10n.Tasks.Form.newReminder).underline(UIAccessibility.buttonShapesEnabled)
                }).buttonStyle { configuration in
                    configuration.label
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(ThemeService.shared.theme.primaryTextColor))
                        .frame(maxWidth: .infinity).frame(height: 48)
                        .background(Color(ThemeService.shared.theme.windowBackgroundColor).cornerRadius(UIConstants.largeCornerRadius))
                }
            }
        }.animation(.easeInOut)
    }
}
