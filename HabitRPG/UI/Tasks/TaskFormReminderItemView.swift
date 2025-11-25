//
//  TaskFormReminderItemView.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import SwiftUI
import Habitica_Models

struct TaskFormReminderItemView: View {
    var item: ReminderProtocol
    var showDate: Bool
    var onDelete: () -> Void
    
    @State private var time: Date

    @ViewBuilder
    private func buildPicker(value: Binding<Date>) -> some View {
        DatePicker(selection: value,
                   displayedComponents: showDate ? [.hourAndMinute, .date] : [.hourAndMinute],
                          label: {
                   Text("")
                          })
        .onTapGesture(count: 99, perform: {
            // fix iOS 17.1 bug
        })
            .foregroundColor(Color(ThemeService.shared.theme.primaryTextColor))
    }
    
    init(item: ReminderProtocol, showDate: Bool, onDelete: @escaping () -> Void) {
        self.item = item
        self.showDate = showDate
        self.onDelete = onDelete
        _time = State(initialValue: item.time ?? Calendar.current.date(bySetting: .second, value: 0, of: Date()) ?? Date())
    }
    
    private var timeProxy: Binding<Date> {
        Binding<Date>(get: { self.time }, set: {
            self.time = $0
            if !self.item.isManaged {
                self.item.time = $0
            }
        })
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    onDelete()
                }, label: {
                    Rectangle().fill(Color.white).frame(width: 9, height: 2)
                        .background(Circle().fill(Color.accentColor).frame(width: 21, height: 21))
                        .frame(width: 40, height: 40)
                }).buttonStyle { configuration in
                    if UIAccessibility.buttonShapesEnabled {
                        configuration.label
                            .background(Color(ThemeService.shared.theme.offsetBackgroundColor))
                            .cornerRadius(UIConstants.largeCornerRadius).padding(4)
                    } else {
                        configuration.label.padding(4)
                    }
                }
                buildPicker(value: timeProxy)
            }.padding(.trailing, 8)
        }.frame(maxWidth: .infinity).background(Color(ThemeService.shared.theme.windowBackgroundColor).cornerRadius(UIConstants.largeCornerRadius))
        .transition(.opacity)
    }
}
