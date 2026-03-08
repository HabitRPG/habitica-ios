//
//  DailySchedulingView.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import SwiftUI
import Habitica_Models

struct DailySchedulingView: View {
    @ObservedObject var themeService = ThemeService.shared
    var isEditable: Bool
    @Binding var startDate: Date?
    @Binding var frequency: String
    @Binding var everyX: Int
    
    @Binding var monday: Bool
    @Binding var tuesday: Bool
    @Binding var wednesday: Bool
    @Binding var thursday: Bool
    @Binding var friday: Bool
    @Binding var saturday: Bool
    @Binding var sunday: Bool
    @Binding var daysOfMonth: [Int]
    @Binding var weeksOfMonth: [Int]
    @Binding var dayOrWeekMonth: String
    
    var tintColor: Color
    
    private static let dailyRepeatOptions = [
        LabeledFormValue<String>(value: "daily", label: L10n.daily),
        LabeledFormValue<String>(value: "weekly", label: L10n.weekly),
        LabeledFormValue<String>(value: "monthly", label: L10n.monthly),
        LabeledFormValue<String>(value: "yearly", label: L10n.yearly)
    ]
    
    private var suffix: String {
        switch frequency {
        case "daily":
            if everyX == 1 {
                return L10n.day
            } else {
                return L10n.days
            }
        case "weekly":
            if everyX == 1 {
                return L10n.week
            } else {
                return L10n.weeks
            }
        case "monthly":
            if everyX == 1 {
                return L10n.month
            } else {
                return L10n.months
            }
        case "yearly":
            if everyX == 1 {
                return L10n.year
            } else {
                return L10n.years
            }
        default:
            return ""
        }
    }
    
    private func weekOption(initial: String, isEnabled: Binding<Bool>) -> some View {
        let option = Text(initial).font(.system(size: 15))
            .foregroundStyle(isEnabled.wrappedValue ? .white : Color(themeService.theme.dimmedTextColor))
            .frame(width: 32, height: 32)
            .onTapGesture {
                UISelectionFeedbackGenerator.oneShotSelectionChanged()
                withAnimation {
                    isEnabled.wrappedValue.toggle()
                }
            }
        
        if #available(iOS 26.0, *) {
            return option.glassEffect(.regular.interactive().tint(isEnabled.wrappedValue ? tintColor : .clear))
                .animation(.easeInOut, value: isEnabled.wrappedValue)
                .frame(maxWidth: .infinity)
        } else {
            return option
                .border(Color(themeService.theme.dimmedColor), width: isEnabled.wrappedValue ? 0 : 1, cornerRadius: UIConstants.largeCornerRadius, antialiased: true)
                .background(Circle().fill(isEnabled.wrappedValue ? tintColor : .clear))
                .animation(.easeInOut, value: isEnabled.wrappedValue)
                .frame(maxWidth: .infinity)
        }
    }
    
    var body: some View {
        let separator = Group {
            if UIAccessibility.buttonShapesEnabled {
                EmptyView()
            } else {
                Divider()
            }
        }
        VStack(spacing: 0) {
            if isEditable {
                FormDatePicker(title: Text(L10n.Tasks.Form.startDate), value: $startDate)
                    .animation(.snappy, value: frequency)
                separator
                FormSheetSelector(title: Text(L10n.Tasks.Form.repeats), value: $frequency, options: DailySchedulingView.dailyRepeatOptions)
                    .animation(.none, value: frequency)
                separator
                NumberPickerFormView(title: Text(L10n.Tasks.Form.every), value: $everyX, minValue: 0, maxValue: 400, formatter: { value in
                    return "\(value) \(suffix.localizedCapitalized)"
                }).animation(.snappy, value: frequency)
                if frequency == "weekly" {
                    separator
                    HStack {
                        weekOption(initial: "M", isEnabled: $monday)
                        weekOption(initial: "T", isEnabled: $tuesday)
                        weekOption(initial: "W", isEnabled: $wednesday)
                        weekOption(initial: "T", isEnabled: $thursday)
                        weekOption(initial: "F", isEnabled: $friday)
                        weekOption(initial: "S", isEnabled: $saturday)
                        weekOption(initial: "S", isEnabled: $sunday)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.horizontal, 14).padding(.top, 10)
                    .padding(.bottom, 2)
                }
                if frequency == "monthly" {
                    separator
                    TaskFormPicker(options: [
                        LabeledFormValue(value: "day", label: L10n.Tasks.Form.dayOfMonth),
                        LabeledFormValue(value: "week", label: L10n.Tasks.Form.dayOfWeek)
                    ], selection: $dayOrWeekMonth)
                    .tint(tintColor)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.horizontal, 12).padding(.top, 10)
                }
            }
            Text(TaskRepeatablesSummaryInteractor().repeatablesSummary(frequency: frequency,
                                                                       everyX: everyX,
                                                                       monday: monday,
                                                                       tuesday: tuesday,
                                                                       wednesday: wednesday,
                                                                       thursday: thursday,
                                                                       friday: friday,
                                                                       saturday: saturday,
                                                                       sunday: sunday,
                                                                       startDate: startDate,
                                                                       daysOfMonth: nil,
                                                                       weeksOfMonth: nil))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(themeService.theme.ternaryTextColor))
        }                .animation(.bouncy(), value: frequency)
    }
}
