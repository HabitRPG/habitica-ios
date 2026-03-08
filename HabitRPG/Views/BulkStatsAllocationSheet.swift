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
    var statType: StatType
    @Binding var amount: Float
    var initialAmount: Float
    var maxAmount: Float

    @State private var numberScale: CGFloat = 1.0
    @State private var glowOpacity: CGFloat = 0.0
    @State private var glowScale: CGFloat = 1.0
    @State private var particleTrigger: Int = 0
    @State private var previousAmount: Float = 0

    var body: some View {
        HStack(spacing: 0) {
            title
                .scaledFont(size: 17, weight: .semibold)
                .frame(width: UIFontMetrics.default.scaledValue(for: 50))

            ZStack {
                Circle()
                    .stroke(color.opacity(glowOpacity), lineWidth: 2)
                    .scaleEffect(glowScale)
                    .frame(width: 36, height: 36)

                ParticleBurstView(
                    color: statType.lightColor,
                    trigger: particleTrigger,
                    particleCount: StatAllocationHaptics.shared.currentTapVelocity > 5 ? 10 : 6
                )
                .frame(width: 80, height: 80)
                .allowsHitTesting(false)

                Text("\(amount + initialAmount, format: .number.precision(.fractionLength(0)))")
                    .contentTransition(.numericText())
                    .animation(StatAnimationConstants.numberSpring, value: amount)
                    .scaleEffect(numberScale)
            }
            .frame(width: 40, alignment: .center)
            .foregroundStyle(Color(themeService.theme.quadTextColor))
            .padding(.trailing, 17)

            Slider(value: $amount, in: 0...maxAmount).tint(color)

            HStack(spacing: 8) {
                Text("+")
                    .foregroundStyle(Color(themeService.theme.quadTextColor))
                Text("\(amount, format: .number.precision(.fractionLength(0)))")
                    .contentTransition(.numericText())
                    .animation(StatAnimationConstants.numberSpring, value: amount)
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
        .onChange(of: amount) { oldValue, newValue in
            if newValue > oldValue {
                triggerAllocationAnimations()
            }
            previousAmount = newValue
        }
        .onAppear {
            previousAmount = amount
        }
    }

    private func triggerAllocationAnimations() {
        StatAllocationHaptics.shared.triggerAllocationHaptic()

        withAnimation(StatAnimationConstants.quickSpring) {
            numberScale = StatAnimationConstants.numberPopScale
        }
        withAnimation(StatAnimationConstants.settleSpring.delay(0.1)) {
            numberScale = 1.0
        }

        glowOpacity = 0.6
        glowScale = 1.0
        withAnimation(.easeOut(duration: StatAnimationConstants.glowDuration)) {
            glowOpacity = 0.0
            glowScale = 2.0
        }

        particleTrigger += 1
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
            }).tint(Color(themeService.theme.fixedTintColor)), content: ScrollView { VStack {
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
                                   statType: .strength,
                                   amount: $strength,
                                   initialAmount: initialStrength,
                                   maxAmount: maxToAllocate)
                .onChange(of: strength) {
                    if totalAllocated > maxToAllocate {
                        redistribute(exclude: "str")
                    }
                }
                StatsAllocationRow(title: Text("INT").foregroundStyle(themeService.theme.isDark ? Color.blue500 : Color.blue10),
                                   color: .blue100,
                                   statType: .intelligence,
                                   amount: $intelligence,
                                   initialAmount: initialIntelligence,
                                   maxAmount: maxToAllocate)
                .onChange(of: intelligence) {
                    if totalAllocated > maxToAllocate {
                        redistribute(exclude: "int")
                    }
                }
                StatsAllocationRow(title: Text("CON").foregroundStyle(themeService.theme.isDark ? Color.yellow500 : Color.yellow10),
                                   color: .yellow100,
                                   statType: .constitution,
                                   amount: $constitution,
                                   initialAmount: initialConstitution,
                                   maxAmount: maxToAllocate)
                .onChange(of: constitution) {
                    if totalAllocated > maxToAllocate {
                        redistribute(exclude: "con")
                    }
                }
                StatsAllocationRow(title: Text("PER").foregroundStyle(themeService.theme.isDark ? Color.purple500 : Color.purple300),
                                   color: .purple400,
                                   statType: .perception,
                                   amount: $perception,
                                   initialAmount: initialPerception,
                                   maxAmount: maxToAllocate)
                .onChange(of: perception) {
                    if totalAllocated > maxToAllocate {
                        redistribute(exclude: "per")
                    }
                }
            }}).sheetBackground(Color(themeService.theme.contentBackgroundColor))
    }
}

#Preview {
    BulkStatsAllocationSheet(initialStrength: 10, initialIntelligence: 0, initialConstitution: 20, initialPerception: 5, maxToAllocate: 20)
}
