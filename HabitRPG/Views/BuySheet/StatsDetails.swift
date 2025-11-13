//
//  StatsDetails.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.09.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import SwiftUI
import Habitica_Models
import ReactiveSwift
import Habitica_Database

struct StatsLabel: View {
    let label: String
    let value: Int?
    
    var body: some View {
        HStack {
            Text("\(label):").foregroundStyle((value ?? 0) > 0 ? Color(ThemeService.shared.theme.primaryTextColor) : Color(ThemeService.shared.theme.dimmedTextColor))
            Spacer()
            if let value = value {
                Text("+\(value)").foregroundStyle(value > 0 ? Color(ThemeService.shared.theme.successColor) : Color(ThemeService.shared.theme.dimmedTextColor))
            }
        }
    }
}

struct StatsDetails: View {
    let gear: GearProtocol?
    
    var body: some View {
        VStack {
            HStack(spacing: 29) {
                StatsLabel(label: "STR", value: gear?.strength)
                StatsLabel(label: "PER", value: gear?.perception)
            }
            HStack(spacing: 29) {
                StatsLabel(label: "CON", value: gear?.constitution)
                StatsLabel(label: "INT", value: gear?.intelligence)
            }
        }
        .scaledFont(size: 17, weight: .semibold)
        .padding(.vertical, 25)
            .padding(.horizontal, 33)
            .background(Color(ThemeService.shared.theme.windowBackgroundColor))
            .cornerRadius(UIConstants.largeCornerRadius)
            .padding(.top, 16)
            .padding(.horizontal, 44)
    }
}
