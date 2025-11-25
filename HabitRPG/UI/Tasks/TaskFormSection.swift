//
//  TaskFormSection.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import SwiftUI
import Habitica_Models

struct TaskFormSection<Header: View, Content: View>: View {
    let header: Header
    let content: Content
    var backgroundColor: Color = Color(ThemeService.shared.theme.windowBackgroundColor)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header.font(.system(size: 13, weight: .semibold)).foregroundColor(Color(ThemeService.shared.theme.quadTextColor)).padding(.leading, 14)
            content.frame(maxWidth: .infinity).background(backgroundColor.cornerRadius(UIConstants.largeCornerRadius))
        }
    }
}
