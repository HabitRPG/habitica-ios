//
//  DailyProgressView.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import SwiftUI
import Habitica_Models

struct DailyProgressView: View {
    let history: [TaskHistoryProtocol]
    
    private let theme = ThemeService.shared.theme
    private let today = Date()
    private let calendar = Calendar.current
    
    private let gray = Color(UIColor.gray400)
    
    @State private var dayItemHeight: CGFloat = 40
    
    @ViewBuilder
    private func icon(wasCompleted: Bool, wasActive: Bool) -> some View {
        if wasActive {
            if wasCompleted {
                Image(Asset.checkmarkSmall.name)
            } else {
                Image(Asset.close.name)
            }
        } else {
            if wasCompleted {
                Image(Asset.checkmarkSmall.name)
            } else {
                Text("")
            }
        }
    }
    
    @ViewBuilder
    private func dayItem(size: CGFloat, offset: Int) -> some View {
        let examinedDay = today.addingTimeInterval(-(Double(offset * 24 * 60 * 60)))
        
        let historyEntry = history.last { item in
            if let timestamp = item.timestamp {
                return Calendar.current.isDate(timestamp, inSameDayAs: examinedDay)
            }
            return false
        }
        let wasActive = historyEntry?.isDue ?? false
        let wasCompleted = historyEntry?.completed ?? false
        
        let day = calendar.component(.day, from: examinedDay)
        let color = wasCompleted ? Color(UIColor.green100) : Color(UIColor.red100)
        let borderColor = wasActive ? color : gray
        let width: CGFloat = wasActive ? 2 : 1
        VStack(alignment: .center, spacing: 5) {
            icon(wasCompleted: wasCompleted, wasActive: wasActive).frame(width: 8, height: 8).foregroundStyle(color).padding(.top, 2)
            Text(String(day)).font(.system(size: 11)).foregroundStyle(borderColor)
        }.frame(width: size, height: size, alignment: .center)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(borderColor, lineWidth: width)
        )
    }
    
    var body: some View {
        VStack {
            GeometryReader { reader in
                let size = (reader.size.width - 62) / 7
                HStack(spacing: 7) {
                    ForEach(0..<7) { offset in
                        dayItem(size: size, offset: 6 - offset)
                    }
                }.padding(.horizontal, 10).padding(.vertical, 10).background(Color(theme.windowBackgroundColor).cornerRadius(UIConstants.largeCornerRadius))
                .background(GeometryReader { _ -> Color in
                    DispatchQueue.main.async {
                        self.dayItemHeight = size
                    }
                    return Color.clear
                })
            }.frame(height: dayItemHeight + 20)
        }
    }
}
