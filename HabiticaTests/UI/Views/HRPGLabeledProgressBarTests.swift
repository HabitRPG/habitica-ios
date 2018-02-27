//
// Created by Phillip Thelen on 27.02.18.
// Copyright (c) 2018 HabitRPG Inc. All rights reserved.
//


import XCTest
@testable import Habitica
import Nimble

class HRPGLabeledProgressBarTests: HabiticaTests {

    var progressBar = HRPGLabeledProgressBar()

    override func setUp() {
        progressBar = HRPGLabeledProgressBar()
        progressBar.maxValue = 50
    }

    func testValueRoundingDown() {
        progressBar.value = NSNumber(value: 49.9)
        expect(self.progressBar.labelView.text) == "49 / 50"
        progressBar.value = NSNumber(value: 9.9)
        expect(self.progressBar.labelView.text) == "9 / 50"
        progressBar.value = NSNumber(value: 1.9)
        expect(self.progressBar.labelView.text) == "1 / 50"
    }

    func testValueRoundingUp() {
        progressBar.value = NSNumber(value: 0.99)
        expect(self.progressBar.labelView.text) == "1 / 50"
        progressBar.value = NSNumber(value: 0.11)
        expect(self.progressBar.labelView.text) == "0.2 / 50"
    }

    func testValueRoundingDecimals() {
        progressBar.value = NSNumber(value: 0.09)
        expect(self.progressBar.labelView.text) == "0.1 / 50"
        progressBar.value = NSNumber(value: 0.0001)
        expect(self.progressBar.labelView.text) == "0.1 / 50"
    }

    func testValueRoundingNegative() {
        progressBar.value = NSNumber(value: -0.1)
        expect(self.progressBar.labelView.text) == "-1 / 50"
        progressBar.value = NSNumber(value: -2)
        expect(self.progressBar.labelView.text) == "-2 / 50"
    }

    func testValueDoesntRound() {
        progressBar.value = NSNumber(value: 20)
        expect(self.progressBar.labelView.text) == "20 / 50"
        progressBar.value = NSNumber(value: 0)
        expect(self.progressBar.labelView.text) == "0 / 50"
        progressBar.value = NSNumber(value: 0.9)
        expect(self.progressBar.labelView.text) == "0.9 / 50"
    }

}
