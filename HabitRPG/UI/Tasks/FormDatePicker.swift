//
//  FormDatePicker.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import SwiftUI
import Habitica_Models

struct FormDatePicker<TitleView: View>: View {
    let title: TitleView
    @Binding var value: Date?

    @State var isOpen = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private var dateProxy: Binding<Date> {
        Binding<Date>(get: { self.value ?? Date() }, set: {
            self.value = $0
        })
    }
    
    private var valueText: String {
        if let date = value {
            return dateFormatter.string(from: date)
        } else {
            return L10n.Tasks.Form.none
        }
    }
    
    var body: some View {
        HStack {
            title
            Spacer()
            if value == nil {
                Button {
                    value = Date()
                } label: {
                    Text(L10n.add).font(.system(size: 15, weight: .bold))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(ThemeService.shared.theme.offsetBackgroundColor))
                .cornerRadius(UIConstants.largeCornerRadius)
            } else {
                DatePicker(selection: dateProxy,
                         displayedComponents: [.date],
                         label: {
                         })
                .datePickerStyle(.compact)
            }
        }

        .padding(.leading, 26).padding(.trailing, 12)
        .frame(height: 50)
    }
}
