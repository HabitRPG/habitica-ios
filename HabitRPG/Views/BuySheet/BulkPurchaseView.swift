//
//  BulkPurchaseView.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import SwiftUI
import Habitica_Models
import ReactiveSwift
import Habitica_Database

struct PlusMinusStepperView<Icon: View>: View {
    @ObservedObject var themeService = ThemeService.shared
    @Binding var amount: Int
    let icon: Icon
    var isActive: Bool = true
    var minAmount = 1
    
    var body: some View {
        HStack {
            Button {
                withAnimation {
                    amount -= 1
                }
            } label: {
                Image(systemName: "minus")
                    .scaledFont(size: 22, weight: .semibold)
            }.disabled(amount <= minAmount || !isActive)
            HStack(spacing: 4) {
                icon
                Text("\(amount)")
                    .contentTransition(.numericText())
                    .scaledFont(size: 22, weight: .bold)
                    .foregroundStyle(Color(isActive ? themeService.theme.primaryTextColor : themeService.theme.ternaryTextColor))
            }
                .padding(.vertical, 11)
                .padding(.horizontal, 31)
                .frame(minWidth: 112, minHeight: 50)
                .background(Color(themeService.theme.windowBackgroundColor))
                .clipShape(.capsule)
            Button {
                withAnimation {
                    amount += 1
                }
            } label: {
                Image(systemName: "plus")
                    .scaledFont(size: 22, weight: .semibold)
            }.disabled(!isActive)
        }
    }
}
