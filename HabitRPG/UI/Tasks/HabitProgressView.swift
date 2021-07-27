//
//  HabitProgressView.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.07.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Habitica_Models
import enum Accelerate.vDSP

struct AnimatableVector: VectorArithmetic {
    static var zero = AnimatableVector(values: [0.0])

    static func + (lhs: AnimatableVector, rhs: AnimatableVector) -> AnimatableVector {
        let count = min(lhs.values.count, rhs.values.count)
        return AnimatableVector(values: vDSP.add(lhs.values[0..<count], rhs.values[0..<count]))
    }

    static func += (lhs: inout AnimatableVector, rhs: AnimatableVector) {
        let count = min(lhs.values.count, rhs.values.count)
        vDSP.add(lhs.values[0..<count], rhs.values[0..<count], result: &lhs.values[0..<count])
    }

    static func - (lhs: AnimatableVector, rhs: AnimatableVector) -> AnimatableVector {
        let count = min(lhs.values.count, rhs.values.count)
        return AnimatableVector(values: vDSP.subtract(lhs.values[0..<count], rhs.values[0..<count]))
    }

    static func -= (lhs: inout AnimatableVector, rhs: AnimatableVector) {
        let count = min(lhs.values.count, rhs.values.count)
        vDSP.subtract(lhs.values[0..<count], rhs.values[0..<count], result: &lhs.values[0..<count])
    }

    var values: [Double]

    mutating func scale(by rhs: Double) {
        values = vDSP.multiply(rhs, values)
    }

    var magnitudeSquared: Double {
        vDSP.sum(vDSP.multiply(values, values))
    }
    
}

struct LineGraph: Shape {
    var values: AnimatableVector
    var middle: CGFloat = 0.5
    var animatableData: AnimatablePair<AnimatableVector, CGFloat> {
        get {
            return AnimatablePair(values, middle)
        }
        set {
            values = newValue.first
            middle = newValue.second
        }
    }

    private func minValue() -> CGFloat {
        var min = min(CGFloat(values.values.min { first, second in
            return first < second
        } ?? -5), -5)
        if middle == 1 {
            min = 0
        }
        return min
    }
    
    private func maxValue() -> CGFloat {
        var max = max(CGFloat(values.values.max { first, second in
            return first < second
        } ?? 5), 5)
        if middle == 0 {
            max = 0
        }
        return max
    }
    
    private func getScale(height: CGFloat, minValue: CGFloat, maxValue: CGFloat) -> CGFloat {
        var length = maxValue - minValue
        if middle == 0.5 {
            length = 2 * max(abs(minValue), abs(maxValue))
        }
        if length == 0 {
            return 1
        }
        return height / CGFloat(length)
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let xStep = rect.width / CGFloat(values.values.count - 1)
            let scale = getScale(height: rect.height, minValue: minValue(), maxValue: maxValue())
            var currentX: CGFloat = 0
            path.move(to: CGPoint(x: 0, y: (rect.height * middle) - (scale * CGFloat(values.values.first ?? 0))))
            values.values.forEach {
                path.addLine(to: CGPoint(x: currentX, y: (rect.height * middle) - (scale * CGFloat($0))))
                currentX += xStep
            }
        }
    }
}

struct HabitProgressView: View {
    let history: [TaskHistoryProtocol]
    let up: Bool
    let down: Bool
    var numberOfDays = 7
    
    private let theme = ThemeService.shared.theme
    private let today = Date()
    private let calendar = Calendar.current
    
    @State private var values: AnimatableVector = AnimatableVector(values: [0])
    
    private var lastXDays: [TaskHistoryProtocol] {
        let day = Date().addingTimeInterval(-Double(numberOfDays) * 24 * 60 * 60)
        let index = history.firstIndex { item in
            if let timestamp = item.timestamp {
                return timestamp > day
            }
            return false
        } ?? 0
        return Array(history[index..<history.count])
    }
    
    private func minValue() -> CGFloat {
        var min = min(CGFloat(lastXDays.min { first, second in
            return first.value < second.value
        }?.value ?? -5), -5)
        if up && !down {
            min = 0
        }
        return min
    }
    
    private func maxValue() -> CGFloat {
        var max = max(CGFloat(lastXDays.max { first, second in
            return first.value < second.value
        }?.value ?? 5), 5)
        if down && !up {
            max = 0
        }
        return max
    }
    
    private func gradientColors(minValue: CGFloat, maxValue: CGFloat) -> [Color] {
        let minRef = up && down ? -max(abs(minValue), abs(maxValue)) : minValue
        let maxRef = up && down ? max(abs(minValue), abs(maxValue)) : maxValue
        var values = [
            Color(.yellow100)
        ]
        if minRef < -1 {
            values.append(Color(.orange100))
        }
        if minRef < -10 {
            values.append(Color(.red100))
        }
        if minRef < -20 {
            values.append(Color(.maroon50))
        }
        if maxRef > 1 {
            values.insert(Color(.green100), at: 0)
        }
        if maxRef > 10 {
            values.insert(Color(.teal100), at: 0)
        }
        if maxRef > 20 {
            values.insert(Color(.blue100), at: 0)
        }
        return values
    }
    
    private func value(for day: Date) -> Double {
        if let day = history.last(where: { calendar.isDate(day, inSameDayAs: $0.timestamp ?? Date()) }) {
            return Double(day.value)
        }
        if let day = history.last(where: { day > ($0.timestamp ?? Date()) }) {
            return Double(day.value)
        }
        return 0
    }
    
    private func getValues() -> [Double] {
        var values = [Double]()
        for offset in 0..<numberOfDays {
            let examinedDay = today.addingTimeInterval(-(Double((numberOfDays-1-offset) * 24 * 60 * 60)))
            values.append(value(for: examinedDay))
        }
        return values
    }
    
    private func lastScoring() -> String {
        guard let timestamp =  history.last(where: { item in
            return item.scoredUp > 0 || item.scoredDown > 0
        })?.timestamp else {
            return "--"
        }
        let today = Date()
        if calendar.isDateInToday(timestamp) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: timestamp)
        }
        if calendar.component(.year, from: today) == calendar.component(.year, from: timestamp) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: timestamp)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: timestamp)
        }
    }
    
    private func timesScored() -> Int {
        return history.filter { item in
            return item.scoredUp > 0 || item.scoredDown > 0
        }.map { $0.scoredUp + $0.scoredDown }.reduce(0, +)
    }
    
    var body: some View {
        VStack(spacing: 15) {
            VStack(spacing: 0) {
                LineGraph(values: AnimatableVector(values: getValues()), middle: up && down ? 0.5 : up ? 1 : 0)
                    .stroke(LinearGradient(gradient: Gradient(colors: gradientColors(minValue: minValue(), maxValue: maxValue())), startPoint: .top, endPoint: .bottom),
                                                 style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .animation(.spring())
                .padding(.bottom, 12)
                .padding(.horizontal, 30)
                .frame(maxHeight: .infinity)
                Rectangle()
                    .foregroundColor(Color(theme.separatorColor))
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 30)
                HStack {
                    ForEach(0..<numberOfDays) { offset in
                        let examinedDay = today.addingTimeInterval(-(Double((6-offset) * 24 * 60 * 60)))
                        let day = calendar.component(.day, from: examinedDay)
                        VStack {
                            Rectangle()
                                .foregroundColor(Color(theme.separatorColor))
                                .frame(width: 2, height: 4)
                            Text(String(day))
                                .font(.system(size: 12))
                                .foregroundColor(Color(theme.ternaryTextColor))
                            
                        }.frame(maxWidth: .infinity)
                    }
                }.padding(.horizontal, 8)
            }
            .padding(.vertical, 16)
            .frame(height: 180)
            .background(Color(theme.windowBackgroundColor)).cornerRadius(8)
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text(String(timesScored())).font(.system(size: 28)).foregroundColor(Color(theme.primaryTextColor))
                    Text(L10n.Tasks.Form.timesScored).font(.system(size: 15)).foregroundColor(Color(theme.ternaryTextColor))
                }.frame(height: 88).frame(maxWidth: .infinity)
                .background(Color(theme.windowBackgroundColor)).cornerRadius(8)
                VStack(spacing: 8) {
                    Text(lastScoring()).font(.system(size: 28)).foregroundColor(Color(theme.primaryTextColor))
                    Text(L10n.Tasks.Form.lastScored).font(.system(size: 15)).foregroundColor(Color(theme.ternaryTextColor))
                }.frame(height: 88).frame(maxWidth: .infinity)
                .background(Color(theme.windowBackgroundColor)).cornerRadius(8)
            }
        }
        .onTapGesture {
            withAnimation {
                values = AnimatableVector(values: getValues().shuffled())
            }
        }
        .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation {
                    values = AnimatableVector(values: getValues())
                }
            }
        })
    }
}

struct HabitProgressView_Previews: PreviewProvider {
    
    static var history: [TaskHistoryProtocol] = {
        var items = [TaskHistoryProtocol]()
        let today = Date()
        for offset in 0..<20 {
            var item = PreviewTaskHistory()
            item.timestamp = today.addingTimeInterval(-Double(offset) * 12 * 60 * 60)
            item.value = Float.random(in: -20...20)
            item.scoredUp = Int.random(in: -2...3)
            items.append(item)
        }
        return items
    }()
    
    static var previews: some View {
        HabitProgressView(history: history, up: true, down: false)
    }
}

private class PreviewTaskHistory: TaskHistoryProtocol {
    var value: Float = 0
    var isValid: Bool = true
    var timestamp: Date?
    var taskID: String?
    var scoredUp: Int = 0
    var scoredDown: Int = 0
}
