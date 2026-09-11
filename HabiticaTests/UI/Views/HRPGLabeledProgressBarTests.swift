//
// Created by Phillip Thelen on 27.02.18.
// Copyright (c) 2018 HabitRPG Inc. All rights reserved.
//


import XCTest
@testable import Habitica
import Nimble

class LabeledProgressBarTests: XCTestCase {

    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 1
        formatter.minimumIntegerDigits = 1
        return formatter
    }()

    var progressBar = LabeledProgressBar()

    override func setUp() {
        progressBar = LabeledProgressBar()
        progressBar.maxValue = 50
    }

    private func expectedLabel(_ value: Float) -> String {
        let current = numberFormatter.string(from: NSNumber(value: value)) ?? "0"
        let maximum = numberFormatter.string(from: NSNumber(value: progressBar.maxValue)) ?? "0"
        return "\(current) / \(maximum)"
    }

    func testValueRoundingDown() {
        progressBar.value = 49.9
        expect(self.progressBar.labelView.text) == expectedLabel(49)
        progressBar.value = 9.9
        expect(self.progressBar.labelView.text) == expectedLabel(9)
        progressBar.value = 1.9
        expect(self.progressBar.labelView.text) == expectedLabel(1)
    }

    func testValueRoundingUp() {
        progressBar.value = 0.99
        expect(self.progressBar.labelView.text) == expectedLabel(1)
        progressBar.value = 0.11
        expect(self.progressBar.labelView.text) == expectedLabel(0.2)
    }

    func testValueRoundingDecimals() {
        progressBar.value = 0.09
        expect(self.progressBar.labelView.text) == expectedLabel(0.1)
        progressBar.value = 0.0001
        expect(self.progressBar.labelView.text) == expectedLabel(0.1)
    }

    func testValueRoundingNegative() {
        progressBar.value = -0.1
        expect(self.progressBar.labelView.text) == expectedLabel(-1)
        progressBar.value = -2
        expect(self.progressBar.labelView.text) == expectedLabel(-2)
    }

    func testValueDoesntRound() {
        progressBar.value = 20
        expect(self.progressBar.labelView.text) == expectedLabel(20)
        progressBar.value = 0
        expect(self.progressBar.labelView.text) == expectedLabel(0)
        progressBar.value = 0.9
        expect(self.progressBar.labelView.text) == expectedLabel(0.9)
    }

}
