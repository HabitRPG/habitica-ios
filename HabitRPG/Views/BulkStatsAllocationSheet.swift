//
//  BulkStatsAllocationSheet.swift
//  Habitica
//
//  Created by Phillip Thelen on 15.10.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct StatsAllocationRow<Title: View>: View {
    @ObservedObject var themeService = ThemeService.shared
    @Environment(\.sizeCategory)
    var sizeCategory
    
    var title: Title
    var color: Color
    @Binding var amount: Float
    var initialAmount: Float
    var maxAmount: Float
    
    var body: some View {
        HStack(spacing: 0) {
            title
                .scaledFont(size: 17, weight: .semibold)
                .frame(width: UIFontMetrics.default.scaledValue(for: 50))
            Text("\(amount + initialAmount, format: .number.precision(.fractionLength(0)))")
                .contentTransition(.numericText())
                .animation(.default, value: amount)
                .frame(width: 40, alignment: .trailing)
                .foregroundStyle(Color(themeService.theme.quadTextColor))
                .padding(.trailing, 17)
            Slider(value: $amount, in: 0...maxAmount).tint(color)
            HStack(spacing: 8) {
                Text("+")
                    .foregroundStyle(Color(themeService.theme.quadTextColor))
                Text("\(amount + initialAmount, format: .number.precision(.fractionLength(0)))")
                    .contentTransition(.numericText())
                    .animation(.default, value: amount)
                    .foregroundStyle(Color(themeService.theme.secondaryTextColor))
            }.frame(width: 64, height: 48)
                .background(Color(themeService.theme.windowBackgroundColor))
                .cornerRadius(UIConstants.mediumCornerRadius)
                .overlay {
                    RoundedRectangle(cornerRadius: UIConstants.mediumCornerRadius)
                        .stroke(Color(themeService.theme.offsetBackgroundColor))
                }
                .padding(.leading, 13)
        }
        .scaledFont(size: 17)
    }
}

struct BulkStatsAllocationSheet: View, Dismissable {
    let userRepository = UserRepository()
    @ObservedObject var themeService = ThemeService.shared
    var dismisser = Dismisser()
    
    @State var strength: Float = 0
    @State var intelligence: Float = 0
    @State var constitution: Float = 0
    @State var perception: Float = 0
    
    let initialStrength: Float
    let initialIntelligence: Float
    let initialConstitution: Float
    let initialPerception: Float
    let maxToAllocate: Float
    
    private var totalAllocated: Float {
        return strength + intelligence + constitution + perception
    }
    
    init(initialStrength: Int, initialIntelligence: Int, initialConstitution: Int, initialPerception: Int, maxToAllocate: Int) {
        self.initialStrength = Float(initialStrength)
        self.initialIntelligence = Float(initialIntelligence)
        self.initialConstitution = Float(initialConstitution)
        self.initialPerception = Float(initialPerception)
        self.maxToAllocate = Float(maxToAllocate)
    }
    
    private func redistribute(exclude: String) {
        var highestValueState: State<Float>?
        if exclude != "str" {
            highestValueState = _strength
        }
        if exclude != "int" && intelligence > (highestValueState?.wrappedValue ?? 0) {
            highestValueState = _intelligence
        }
        if exclude != "con" && constitution > (highestValueState?.wrappedValue ?? 0) {
            highestValueState = _constitution
        }
        if exclude != "per" && perception > (highestValueState?.wrappedValue ?? 0) {
            highestValueState = _perception
        }
        if let highestValueState = highestValueState {
            highestValueState.wrappedValue = max(0, highestValueState.wrappedValue - 1)
        }
    }
    
    private func allocate() {
        userRepository.bulkAllocate(strength: Int(strength), intelligence: Int(intelligence), constitution: Int(constitution), perception: Int(perception))
            .observeCompleted {
                
            }
        dismisser.dismiss()
    }
    
    var body: some View {
        BottomSheetView(dismisser: dismisser, title: BottomSheetHeaderBar(title: Text(L10n.stats), leftAction: Button {
                dismisser.dismiss()
            } label: {
                Image(systemName: .xmark)
                    .scaledFont(size: 24)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color(themeService.theme.primaryTextColor))
            }, rightAction: Button {
                allocate()
            } label: {
                Image(systemName: .checkmark)
                    .scaledFont(size: 24)
                    .frame(width: 24, height: 24)
            }), content: VStack {
                VStack(spacing: 2) {
                    Text("\(totalAllocated, format: .number.precision(.fractionLength(0)))/\(maxToAllocate, format: .number.precision(.fractionLength(0)))")
                        .contentTransition(.numericText())
                        .animation(.default, value: totalAllocated)
                    .foregroundStyle(Color(ThemeService.shared.theme.fixedTintColor))
                    .scaledFont(size: 28, weight: .bold)
                Text(L10n.allocated)
                    .foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
                    .scaledFont(size: 17, weight: .semibold)
            }
                StatsAllocationRow(title: Text("STR").foregroundStyle(themeService.theme.isDark ? Color.red500 : Color.maroon100),
                                   color: .red100,
                                   amount: $strength,
                                   initialAmount: initialStrength,
                                   maxAmount: maxToAllocate)
                .onChange(of: strength) { _ in
                    if totalAllocated > maxToAllocate {
                        redistribute(exclude: "str")
                    }
                }
                StatsAllocationRow(title: Text("INT").foregroundStyle(themeService.theme.isDark ? Color.blue500 : Color.blue10),
                                   color: .blue100,
                                   amount: $intelligence,
                                   initialAmount: initialIntelligence,
                                   maxAmount: maxToAllocate)
                .onChange(of: intelligence) { _ in
                    if totalAllocated > maxToAllocate {
                        redistribute(exclude: "int")
                    }
                }
                StatsAllocationRow(title: Text("CON").foregroundStyle(themeService.theme.isDark ? Color.yellow500 : Color.yellow10),
                                   color: .yellow100,
                                   amount: $constitution,
                                   initialAmount: initialConstitution,
                                   maxAmount: maxToAllocate)
                .onChange(of: constitution) { _ in
                    if totalAllocated > maxToAllocate {
                        redistribute(exclude: "con")
                    }
                }
                StatsAllocationRow(title: Text("PER").foregroundStyle(themeService.theme.isDark ? Color.purple500 : Color.purple300),
                                   color: .purple400,
                                   amount: $perception,
                                   initialAmount: initialPerception,
                                   maxAmount: maxToAllocate)
                .onChange(of: perception) { _ in
                    if totalAllocated > maxToAllocate {
                        redistribute(exclude: "per")
                    }
                }
            }).sheetBackground(Color(themeService.theme.contentBackgroundColor))
    }
}

#Preview {
    BulkStatsAllocationSheet(initialStrength: 10, initialIntelligence: 0, initialConstitution: 20, initialPerception: 5, maxToAllocate: 20)
}
