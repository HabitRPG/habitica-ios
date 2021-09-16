//
//  DueDateFormView.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.09.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct DueDateFormView: View {
    @Binding var date: Date?
    
    var body: some View {
        VStack(spacing: 0) {
            FormDatePicker(title: Text(L10n.Tasks.Form.dueDate), value: $date)
            if date != nil {
                Separator()
                Button(action: {
                    withAnimation {
                        date = nil
                    }
                }, label: {
                    Text(L10n.Tasks.Form.clear).font(.system(size: 15, weight: .semibold)).foregroundColor(.accentColor)
                }).frame(maxWidth: .infinity).frame(height: 48).background(Color(ThemeService.shared.theme.windowBackgroundColor).cornerRadius(8))
            }
        }
    }
}
