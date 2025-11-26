//
//  FormSheetSelector.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import SwiftUI
import Habitica_Models

struct FormSheetSelector<TYPE: Equatable & Hashable>: View {
    @ObservedObject var themeService = ThemeService.shared
    let title: Text
    @Binding var value: TYPE
    let options: [LabeledFormValue<TYPE>]
    
    @State var isOpen = false
    
    var body: some View {
        HStack {
            title
            Spacer()
            Picker(selection: $value, content: {
                ForEach(options) { option in
                    Text(option.label).tag(option.value)
                }
            }, label: {
                Text(options.first(where: { $0.value == value })?.label ?? "")
            })
            .tint(Color(themeService.theme.primaryTextColor))
            .background(Color(themeService.theme.offsetBackgroundColor))
            .cornerRadius(UIConstants.largeCornerRadius)
            .menuIndicator(.hidden)
        }.frame(height: 45).padding(.leading, 26).padding(.trailing, 12)
    }
}
